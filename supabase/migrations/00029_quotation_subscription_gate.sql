
-- ─────────────────────────────────────────────────────────────
-- 1. SECURITY DEFINER helper: is the calling user a subscribed supplier?
-- ─────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION is_supplier_subscribed(p_user_id uuid DEFAULT auth.uid())
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_role text;
  v_subscribed boolean := false;
BEGIN
  SELECT role INTO v_role FROM profiles WHERE id = p_user_id;

  -- Admins are always allowed
  IF v_role = 'admin' THEN RETURN true; END IF;

  -- Only suppliers need a subscription to submit quotations
  IF v_role <> 'supplier' THEN RETURN false; END IF;

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
$$;

-- ─────────────────────────────────────────────────────────────
-- 2. Drop old permissive insert policy, replace with
--    subscription-gated one (server-side, cannot be bypassed)
-- ─────────────────────────────────────────────────────────────
DROP POLICY IF EXISTS "quotations_insert_supplier" ON quotations;

CREATE POLICY "quotations_insert_subscribed_supplier" ON quotations
  FOR INSERT
  WITH CHECK (
    supplier_id = auth.uid()
    AND is_supplier_subscribed(auth.uid())
  );

-- ─────────────────────────────────────────────────────────────
-- 3. Grant execute on the helper to authenticated role
-- ─────────────────────────────────────────────────────────────
GRANT EXECUTE ON FUNCTION is_supplier_subscribed(uuid) TO authenticated;
