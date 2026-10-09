-- ============================================================
-- 1. Add product_id to conversations for product context
-- ============================================================
ALTER TABLE conversations
  ADD COLUMN IF NOT EXISTS product_id uuid REFERENCES products(id) ON DELETE SET NULL;

-- Unique constraint: one conversation per (buyer + supplier + product)
-- Handles both product-based and requirement-based chats
CREATE UNIQUE INDEX IF NOT EXISTS idx_conv_buyer_supplier_product
  ON conversations(buyer_id, supplier_id, product_id)
  WHERE product_id IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS idx_conv_buyer_supplier_requirement
  ON conversations(buyer_id, supplier_id, requirement_id)
  WHERE requirement_id IS NOT NULL AND product_id IS NULL;

-- ============================================================
-- 2. buyer_subscriptions table — buyers also need subscriptions for live chat
-- ============================================================
CREATE TABLE IF NOT EXISTS buyer_subscriptions (
  id           uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id      uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  tier         text NOT NULL DEFAULT 'basic' CHECK (tier IN ('basic','premium','enterprise')),
  status       text NOT NULL DEFAULT 'active' CHECK (status IN ('active','expired','cancelled','trial')),
  starts_at    timestamptz NOT NULL DEFAULT now(),
  ends_at      timestamptz,
  created_at   timestamptz NOT NULL DEFAULT now(),
  updated_at   timestamptz NOT NULL DEFAULT now(),
  UNIQUE(user_id)
);

-- RLS
ALTER TABLE buyer_subscriptions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "buyer_sub_select_own" ON buyer_subscriptions
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "buyer_sub_insert_own" ON buyer_subscriptions
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "buyer_sub_update_own" ON buyer_subscriptions
  FOR UPDATE USING (auth.uid() = user_id);

-- Admins full access
CREATE POLICY "buyer_sub_admin_all" ON buyer_subscriptions
  FOR ALL USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

-- ============================================================
-- 3. SECURITY DEFINER helper: check_chat_eligible
--    Returns TRUE if the given user_id has an active subscription
--    (either as supplier via companies.subscriptions, or as buyer via buyer_subscriptions)
-- ============================================================
CREATE OR REPLACE FUNCTION is_chat_eligible(p_user_id uuid)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_role text;
  v_eligible boolean := false;
BEGIN
  SELECT role INTO v_role FROM profiles WHERE id = p_user_id;

  IF v_role = 'supplier' OR v_role = 'admin' THEN
    -- Check active subscription via companies
    SELECT EXISTS (
      SELECT 1
      FROM companies c
      JOIN subscriptions s ON s.company_id = c.id
      WHERE c.owner_id = p_user_id
        AND s.status = 'active'
        AND (s.ends_at IS NULL OR s.ends_at > now())
    ) INTO v_eligible;
  ELSE
    -- buyer: check buyer_subscriptions
    SELECT EXISTS (
      SELECT 1
      FROM buyer_subscriptions bs
      WHERE bs.user_id = p_user_id
        AND bs.status = 'active'
        AND (bs.ends_at IS NULL OR bs.ends_at > now())
    ) INTO v_eligible;
  END IF;

  RETURN v_eligible;
END;
$$;

-- ============================================================
-- 4. Update conversations RLS — participants + subscription check
-- ============================================================
DROP POLICY IF EXISTS "conversations_select_parties" ON conversations;
DROP POLICY IF EXISTS "conversations_insert_parties" ON conversations;
DROP POLICY IF EXISTS "conversations_update_parties" ON conversations;

-- SELECT: only participants
CREATE POLICY "conversations_select_parties" ON conversations
  FOR SELECT USING (
    auth.uid() = buyer_id OR auth.uid() = supplier_id
  );

-- INSERT: both parties must be eligible
CREATE POLICY "conversations_insert_parties" ON conversations
  FOR INSERT WITH CHECK (
    auth.uid() = buyer_id
    AND is_chat_eligible(buyer_id)
    AND is_chat_eligible(supplier_id)
  );

-- UPDATE: only participants (unread counts etc.)
CREATE POLICY "conversations_update_parties" ON conversations
  FOR UPDATE USING (
    auth.uid() = buyer_id OR auth.uid() = supplier_id
  );

-- ============================================================
-- 5. Update messages RLS — sender must be eligible
-- ============================================================
DROP POLICY IF EXISTS "messages_insert_parties" ON messages;

CREATE POLICY "messages_insert_parties" ON messages
  FOR INSERT WITH CHECK (
    sender_id = auth.uid()
    AND is_chat_eligible(auth.uid())
    AND EXISTS (
      SELECT 1 FROM conversations c
      WHERE c.id = conversation_id
        AND (c.buyer_id = auth.uid() OR c.supplier_id = auth.uid())
    )
  );

-- ============================================================
-- 6. Enable realtime on conversations (messages already enabled)
-- ============================================================
ALTER PUBLICATION supabase_realtime ADD TABLE conversations;

-- ============================================================
-- 7. Function: get_or_create_chat_conversation (atomic, no duplicates)
-- ============================================================
CREATE OR REPLACE FUNCTION get_or_create_chat_conversation(
  p_buyer_id          uuid,
  p_supplier_id       uuid,
  p_supplier_company_id uuid,
  p_product_id        uuid DEFAULT NULL,
  p_requirement_id    uuid DEFAULT NULL
)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_conv_id uuid;
BEGIN
  -- Look up existing
  IF p_product_id IS NOT NULL THEN
    SELECT id INTO v_conv_id
    FROM conversations
    WHERE buyer_id = p_buyer_id
      AND supplier_id = p_supplier_id
      AND product_id = p_product_id
    LIMIT 1;
  ELSIF p_requirement_id IS NOT NULL THEN
    SELECT id INTO v_conv_id
    FROM conversations
    WHERE buyer_id = p_buyer_id
      AND supplier_id = p_supplier_id
      AND requirement_id = p_requirement_id
    LIMIT 1;
  ELSE
    SELECT id INTO v_conv_id
    FROM conversations
    WHERE buyer_id = p_buyer_id
      AND supplier_id = p_supplier_id
    ORDER BY created_at ASC
    LIMIT 1;
  END IF;

  IF v_conv_id IS NOT NULL THEN
    RETURN v_conv_id;
  END IF;

  -- Create new
  INSERT INTO conversations(
    buyer_id, supplier_id, supplier_company_id, product_id, requirement_id
  )
  VALUES(
    p_buyer_id, p_supplier_id, p_supplier_company_id, p_product_id, p_requirement_id
  )
  RETURNING id INTO v_conv_id;

  RETURN v_conv_id;
END;
$$;

-- ============================================================
-- 8. Function: update_conversation_last_message (called after insert)
-- ============================================================
CREATE OR REPLACE FUNCTION update_conv_on_message()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_buyer_id uuid;
  v_supplier_id uuid;
BEGIN
  SELECT buyer_id, supplier_id INTO v_buyer_id, v_supplier_id
  FROM conversations WHERE id = NEW.conversation_id;

  UPDATE conversations SET
    last_message    = LEFT(NEW.content, 120),
    last_message_at = NEW.created_at,
    buyer_unread    = CASE WHEN NEW.sender_id = v_supplier_id THEN buyer_unread + 1 ELSE buyer_unread END,
    supplier_unread = CASE WHEN NEW.sender_id = v_buyer_id    THEN supplier_unread + 1 ELSE supplier_unread END
  WHERE id = NEW.conversation_id;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_update_conv_on_message ON messages;
CREATE TRIGGER trg_update_conv_on_message
  AFTER INSERT ON messages
  FOR EACH ROW EXECUTE FUNCTION update_conv_on_message();