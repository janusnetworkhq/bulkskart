
-- ─────────────────────────────────────────────────────────────
-- 1. Update is_chat_eligible: buyers are always eligible (free)
-- ─────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION is_chat_eligible(p_user_id uuid)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_role text;
BEGIN
  SELECT role INTO v_role FROM profiles WHERE id = p_user_id;

  -- Admins and buyers are always eligible (buyers use platform for free)
  IF v_role IN ('admin', 'buyer') THEN RETURN true; END IF;

  -- Suppliers must have an active subscription
  RETURN EXISTS (
    SELECT 1
    FROM companies c
    JOIN subscriptions s ON s.company_id = c.id
    WHERE c.owner_id = p_user_id
      AND s.status = 'active'
      AND (s.ends_at IS NULL OR s.ends_at > now())
  );
END;
$$;

-- ─────────────────────────────────────────────────────────────
-- 2. Update is_supplier_subscribed: buyers return false (not a supplier gate)
--    No change needed — it already filters by role = 'supplier'.
-- ─────────────────────────────────────────────────────────────

-- ─────────────────────────────────────────────────────────────
-- 3. Fix conversations RLS: remove buyer subscription requirement
--    Buyers can always start conversations (they pay nothing).
-- ─────────────────────────────────────────────────────────────
DROP POLICY IF EXISTS "conversations_insert_parties" ON conversations;

CREATE POLICY "conversations_insert_parties" ON conversations
  FOR INSERT WITH CHECK (
    auth.uid() = buyer_id
    AND is_chat_eligible(supplier_id)   -- only supplier must be subscribed
  );
