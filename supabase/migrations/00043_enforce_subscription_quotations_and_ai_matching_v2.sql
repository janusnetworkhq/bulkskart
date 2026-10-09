-- 1. Create or replace is_supplier_subscribed with exact signature
CREATE OR REPLACE FUNCTION public.is_supplier_subscribed(p_user_id uuid DEFAULT auth.uid())
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
DECLARE
  v_role text;
  v_subscribed boolean := false;
BEGIN
  IF p_user_id IS NULL THEN
    RETURN false;
  END IF;

  SELECT role INTO v_role FROM profiles WHERE id = p_user_id;

  -- Admins are always allowed
  IF v_role = 'admin' THEN
    RETURN true;
  END IF;

  -- Only suppliers need a subscription to submit quotations
  IF v_role <> 'supplier' THEN
    RETURN false;
  END IF;

  SELECT EXISTS (
    SELECT 1
    FROM companies c
    JOIN subscriptions s ON s.company_id = c.id
    WHERE c.owner_id = p_user_id
      AND s.status = 'active'
      AND (s.ends_at IS NULL OR s.ends_at > now())
  ) INTO v_subscribed;

  RETURN v_subscribed;
END;
$function$;

-- 2. Function to check if company has AI Product Matching feature unlocked (₹5,000+ package)
CREATE OR REPLACE FUNCTION public.can_supplier_use_ai_matching(p_company_id uuid, p_user_id uuid DEFAULT auth.uid())
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
DECLARE
  v_sub record;
  v_user_role text;
BEGIN
  -- If user_id provided, check if admin
  IF p_user_id IS NOT NULL THEN
    SELECT role INTO v_user_role FROM profiles WHERE id = p_user_id;
    IF v_user_role = 'admin' THEN
      RETURN jsonb_build_object(
        'allowed', true,
        'tier', 'enterprise',
        'has_ai_matching', true,
        'message', 'Admin access granted'
      );
    END IF;
  END IF;

  IF p_company_id IS NULL THEN
    RETURN jsonb_build_object(
      'allowed', false,
      'tier', null,
      'has_ai_matching', false,
      'reason', 'no_company',
      'message', 'Registered company required'
    );
  END IF;

  -- Find active subscription
  SELECT * INTO v_sub
  FROM subscriptions
  WHERE company_id = p_company_id
    AND status = 'active'
    AND (ends_at IS NULL OR ends_at > now())
  ORDER BY created_at DESC
  LIMIT 1;

  IF NOT FOUND THEN
    RETURN jsonb_build_object(
      'allowed', false,
      'tier', null,
      'has_ai_matching', false,
      'reason', 'no_subscription',
      'message', 'Active paid subscription required. Upgrade to ₹5,000 Business Package to unlock AI Product Matching.'
    );
  END IF;

  -- Check tier: business (₹5,000), growth (₹10,000), enterprise unlock AI matching
  IF v_sub.tier IN ('business', 'growth', 'enterprise') THEN
    RETURN jsonb_build_object(
      'allowed', true,
      'tier', v_sub.tier,
      'has_ai_matching', true,
      'message', 'AI Product Matching is unlocked'
    );
  ELSE
    RETURN jsonb_build_object(
      'allowed', false,
      'tier', v_sub.tier,
      'has_ai_matching', false,
      'reason', 'upgrade_required',
      'message', 'AI Product Matching requires the ₹5,000 Business Package or higher.'
    );
  END IF;
END;
$function$;

-- 3. Trigger function to enforce active paid subscription on quotations insertion
CREATE OR REPLACE FUNCTION public.trg_check_quotation_subscription()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
DECLARE
  v_role text;
  v_has_sub boolean := false;
BEGIN
  -- Check user role
  IF NEW.supplier_id IS NOT NULL THEN
    SELECT role INTO v_role FROM profiles WHERE id = NEW.supplier_id;
    IF v_role = 'admin' THEN
      RETURN NEW;
    END IF;
  END IF;

  -- Check if supplier has active subscription by company or supplier_id
  IF NEW.supplier_company_id IS NOT NULL THEN
    SELECT EXISTS (
      SELECT 1
      FROM subscriptions
      WHERE company_id = NEW.supplier_company_id
        AND status = 'active'
        AND (ends_at IS NULL OR ends_at > now())
    ) INTO v_has_sub;
  END IF;

  IF NOT v_has_sub AND NEW.supplier_id IS NOT NULL THEN
    SELECT EXISTS (
      SELECT 1
      FROM companies c
      JOIN subscriptions s ON s.company_id = c.id
      WHERE c.owner_id = NEW.supplier_id
        AND s.status = 'active'
        AND (s.ends_at IS NULL OR s.ends_at > now())
    ) INTO v_has_sub;
  END IF;

  IF NOT v_has_sub THEN
    RAISE EXCEPTION 'Active paid subscription required to send quotations to Live Buying Requirements. Please upgrade to the ₹5,000 Business Package.'
      USING ERRCODE = 'P0001';
  END IF;

  RETURN NEW;
END;
$function$;

-- Drop existing trigger if exists and recreate
DROP TRIGGER IF EXISTS trg_verify_quotation_subscription ON public.quotations;
CREATE TRIGGER trg_verify_quotation_subscription
  BEFORE INSERT ON public.quotations
  FOR EACH ROW
  EXECUTE FUNCTION public.trg_check_quotation_subscription();
