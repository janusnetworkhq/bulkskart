ALTER TABLE subscriptions 
  ADD COLUMN IF NOT EXISTS has_ai_access boolean
    DEFAULT false; ALTER TABLE companies 
  ADD COLUMN IF NOT EXISTS has_ai_access boolean
    DEFAULT false; ALTER TABLE companies 
  ADD COLUMN IF NOT EXISTS flash_sell_until timestamp with time zone; CREATE OR REPLACE FUNCTION public.can_supplier_use_ai_matching(
  p_company_id uuid,
  p_user_id uuid DEFAULT auth.uid()
) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path TO public AS $$
DECLARE
  v_sub record;
  v_comp record;
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

  -- Check company direct flag
  SELECT * INTO v_comp FROM companies WHERE id = p_company_id;
  IF FOUND AND v_comp.has_ai_access = true THEN
    RETURN jsonb_build_object(
      'allowed', true,
      'tier', 'addon_ai',
      'has_ai_matching', true,
      'message', 'AI Accessibility Add-on active'
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
      'message', 'Active paid subscription required. Upgrade to ₹7,500 Business Package or ₹7,500 AI Accessibility Add-on.'
    );
  END IF;

  -- Check tier: business (₹7,500), growth (₹15,000), enterprise or has_ai_access flag
  IF v_sub.tier IN ('business', 'growth', 'enterprise') OR v_sub.has_ai_access = true THEN
    RETURN jsonb_build_object(
      'allowed', true,
      'tier', v_sub.tier,
      'has_ai_matching', true,
      'message', 'AI Product Matching & Assistant unlocked'
    );
  ELSE
    RETURN jsonb_build_object(
      'allowed', false,
      'tier', v_sub.tier,
      'has_ai_matching', false,
      'reason', 'upgrade_required',
      'message', 'AI Accessibility requires the ₹7,500 Business Package or the ₹7,500 AI Add-on.'
    );
  END IF;
END;
$$;