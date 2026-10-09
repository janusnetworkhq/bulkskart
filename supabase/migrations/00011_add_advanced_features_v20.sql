
-- ============================================================
-- STEP 1: New ENUM types
-- ============================================================
DO $$ BEGIN
  CREATE TYPE dispute_status AS ENUM ('open','under_review','resolved','closed');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE dispute_reason AS ENUM ('quality_issue','delivery_delay','payment_issue','communication_issue','other');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE order_milestone AS ENUM (
    'rfq_created','quote_received','quote_accepted',
    'order_processing','production','ready_for_dispatch',
    'dispatched','delivered','completed','cancelled'
  );
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE fraud_severity AS ENUM ('low','medium','high');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE verification_doc_status AS ENUM ('pending','approved','rejected');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE withdrawal_status AS ENUM ('pending','approved','rejected');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- ============================================================
-- STEP 2: Extend existing tables with new columns (all additive)
-- ============================================================

-- companies: verification expiry, bank details, factory doc, re-verify tracking, wallet
ALTER TABLE companies
  ADD COLUMN IF NOT EXISTS verification_expiry_at     timestamptz,
  ADD COLUMN IF NOT EXISTS pan_number                 text,
  ADD COLUMN IF NOT EXISTS pan_doc_url                text,
  ADD COLUMN IF NOT EXISTS factory_doc_url            text,
  ADD COLUMN IF NOT EXISTS bank_doc_url               text,
  ADD COLUMN IF NOT EXISTS bank_account_name          text,
  ADD COLUMN IF NOT EXISTS bank_account_number        text,
  ADD COLUMN IF NOT EXISTS bank_ifsc                  text,
  ADD COLUMN IF NOT EXISTS bank_name                  text,
  ADD COLUMN IF NOT EXISTS bank_branch                text,
  ADD COLUMN IF NOT EXISTS verified_by                uuid REFERENCES profiles(id),
  ADD COLUMN IF NOT EXISTS rejection_reason           text,
  ADD COLUMN IF NOT EXISTS wallet_balance             numeric NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS withdrawable_balance       numeric NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS total_revenue              numeric NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS response_rate              numeric NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS avg_response_hours         numeric NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS is_blocked                 boolean NOT NULL DEFAULT false;

-- buyer_profiles: KYC verification columns
ALTER TABLE buyer_profiles
  ADD COLUMN IF NOT EXISTS verification_status        text NOT NULL DEFAULT 'unverified',
  ADD COLUMN IF NOT EXISTS pan_number                 text,
  ADD COLUMN IF NOT EXISTS registration_number        text,
  ADD COLUMN IF NOT EXISTS gst_doc_url                text,
  ADD COLUMN IF NOT EXISTS pan_doc_url                text,
  ADD COLUMN IF NOT EXISTS reg_doc_url                text,
  ADD COLUMN IF NOT EXISTS verified_at                timestamptz,
  ADD COLUMN IF NOT EXISTS verified_by                uuid REFERENCES profiles(id),
  ADD COLUMN IF NOT EXISTS rejection_reason           text;

-- quotations: extended fields for professional quotations
ALTER TABLE quotations
  ADD COLUMN IF NOT EXISTS quantity                   integer,
  ADD COLUMN IF NOT EXISTS total_price                numeric,
  ADD COLUMN IF NOT EXISTS production_days            integer,
  ADD COLUMN IF NOT EXISTS delivery_terms             text,
  ADD COLUMN IF NOT EXISTS attachment_urls            text[] DEFAULT '{}',
  ADD COLUMN IF NOT EXISTS pdf_url                    text,
  ADD COLUMN IF NOT EXISTS is_draft                   boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS change_request             text;

-- orders: extended status + milestone
ALTER TABLE orders
  ADD COLUMN IF NOT EXISTS milestone                  order_milestone NOT NULL DEFAULT 'rfq_created',
  ADD COLUMN IF NOT EXISTS requirement_id             uuid REFERENCES requirements(id),
  ADD COLUMN IF NOT EXISTS supplier_id                uuid REFERENCES profiles(id),
  ADD COLUMN IF NOT EXISTS notes                      text,
  ADD COLUMN IF NOT EXISTS cancelled_reason           text,
  ADD COLUMN IF NOT EXISTS cancelled_by               uuid REFERENCES profiles(id);

-- requirements: rfq match count
ALTER TABLE requirements
  ADD COLUMN IF NOT EXISTS matched_count              integer NOT NULL DEFAULT 0;

-- messages: file support + read tracking
ALTER TABLE messages
  ADD COLUMN IF NOT EXISTS attachment_type            text,
  ADD COLUMN IF NOT EXISTS attachment_name            text,
  ADD COLUMN IF NOT EXISTS is_file                    boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS read_at                    timestamptz;

-- conversations: block flag
ALTER TABLE conversations
  ADD COLUMN IF NOT EXISTS buyer_blocked              boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS supplier_blocked           boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS order_id                   uuid REFERENCES orders(id);

-- notifications: reference_id for deep links
ALTER TABLE notifications
  ADD COLUMN IF NOT EXISTS reference_id               uuid,
  ADD COLUMN IF NOT EXISTS reference_type             text;

-- ============================================================
-- STEP 3: New tables
-- ============================================================

-- Order milestone history log
CREATE TABLE IF NOT EXISTS order_milestones (
  id              uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_id        uuid NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  milestone       order_milestone NOT NULL,
  changed_by      uuid NOT NULL REFERENCES profiles(id),
  notes           text,
  created_at      timestamptz NOT NULL DEFAULT now()
);

-- Saved/followed manufacturers
CREATE TABLE IF NOT EXISTS saved_manufacturers (
  id              uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  buyer_id        uuid NOT NULL DEFAULT auth.uid() REFERENCES profiles(id) ON DELETE CASCADE,
  company_id      uuid NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
  created_at      timestamptz NOT NULL DEFAULT now(),
  UNIQUE(buyer_id, company_id)
);

-- RFQ match log (prevents duplicate notifications)
CREATE TABLE IF NOT EXISTS rfq_match_log (
  id              uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  requirement_id  uuid NOT NULL REFERENCES requirements(id) ON DELETE CASCADE,
  company_id      uuid NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
  relevance_score numeric NOT NULL DEFAULT 0,
  notified_at     timestamptz NOT NULL DEFAULT now(),
  UNIQUE(requirement_id, company_id)
);

-- Disputes
CREATE TABLE IF NOT EXISTS disputes (
  id              uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_id        uuid NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  raised_by       uuid NOT NULL DEFAULT auth.uid() REFERENCES profiles(id),
  against_user_id uuid REFERENCES profiles(id),
  reason          dispute_reason NOT NULL DEFAULT 'other',
  description     text NOT NULL,
  evidence_urls   text[] DEFAULT '{}',
  status          dispute_status NOT NULL DEFAULT 'open',
  resolution      text,
  resolved_by     uuid REFERENCES profiles(id),
  resolved_at     timestamptz,
  admin_notes     text,
  created_at      timestamptz NOT NULL DEFAULT now(),
  updated_at      timestamptz NOT NULL DEFAULT now()
);

-- Dispute action audit trail
CREATE TABLE IF NOT EXISTS dispute_actions (
  id              uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  dispute_id      uuid NOT NULL REFERENCES disputes(id) ON DELETE CASCADE,
  actor_id        uuid NOT NULL REFERENCES profiles(id),
  action          text NOT NULL,
  notes           text,
  created_at      timestamptz NOT NULL DEFAULT now()
);

-- Fraud / abuse alerts
CREATE TABLE IF NOT EXISTS fraud_alerts (
  id              uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id         uuid REFERENCES profiles(id),
  company_id      uuid REFERENCES companies(id),
  alert_type      text NOT NULL,
  description     text NOT NULL,
  severity        fraud_severity NOT NULL DEFAULT 'low',
  is_resolved     boolean NOT NULL DEFAULT false,
  resolved_by     uuid REFERENCES profiles(id),
  resolved_at     timestamptz,
  admin_notes     text,
  created_at      timestamptz NOT NULL DEFAULT now()
);

-- Global audit log
CREATE TABLE IF NOT EXISTS audit_logs (
  id              uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  actor_id        uuid REFERENCES profiles(id),
  action_type     text NOT NULL,
  target_table    text,
  target_id       uuid,
  details         jsonb,
  ip_address      text,
  created_at      timestamptz NOT NULL DEFAULT now()
);

-- Withdrawal requests
CREATE TABLE IF NOT EXISTS withdrawal_requests (
  id              uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  company_id      uuid NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
  amount          numeric NOT NULL,
  status          withdrawal_status NOT NULL DEFAULT 'pending',
  notes           text,
  processed_by    uuid REFERENCES profiles(id),
  processed_at    timestamptz,
  created_at      timestamptz NOT NULL DEFAULT now()
);

-- Blocked users
CREATE TABLE IF NOT EXISTS blocked_users (
  id              uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  blocker_id      uuid NOT NULL DEFAULT auth.uid() REFERENCES profiles(id) ON DELETE CASCADE,
  blocked_id      uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  created_at      timestamptz NOT NULL DEFAULT now(),
  UNIQUE(blocker_id, blocked_id)
);

-- ============================================================
-- STEP 4: Storage buckets via SQL
-- ============================================================
INSERT INTO storage.buckets (id, name, public)
VALUES
  ('verification-docs', 'verification-docs', false),
  ('chat-files', 'chat-files', false),
  ('dispute-evidence', 'dispute-evidence', false),
  ('quotation-pdfs', 'quotation-pdfs', false)
ON CONFLICT (id) DO NOTHING;

-- ============================================================
-- STEP 5: Enable Realtime on messages + notifications
-- ============================================================
ALTER PUBLICATION supabase_realtime ADD TABLE messages;
ALTER PUBLICATION supabase_realtime ADD TABLE notifications;

-- ============================================================
-- STEP 6: RLS — enable on new tables
-- ============================================================
ALTER TABLE order_milestones       ENABLE ROW LEVEL SECURITY;
ALTER TABLE saved_manufacturers    ENABLE ROW LEVEL SECURITY;
ALTER TABLE rfq_match_log          ENABLE ROW LEVEL SECURITY;
ALTER TABLE disputes               ENABLE ROW LEVEL SECURITY;
ALTER TABLE dispute_actions        ENABLE ROW LEVEL SECURITY;
ALTER TABLE fraud_alerts           ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_logs             ENABLE ROW LEVEL SECURITY;
ALTER TABLE withdrawal_requests    ENABLE ROW LEVEL SECURITY;
ALTER TABLE blocked_users          ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- STEP 7: SECURITY DEFINER helpers (bypass RLS for lookups)
-- ============================================================
CREATE OR REPLACE FUNCTION get_my_role()
RETURNS text LANGUAGE sql STABLE SECURITY DEFINER AS $$
  SELECT role::text FROM profiles WHERE id = auth.uid();
$$;

CREATE OR REPLACE FUNCTION get_conversation_parties(conv_id uuid)
RETURNS TABLE(buyer_id uuid, supplier_id uuid) LANGUAGE sql STABLE SECURITY DEFINER AS $$
  SELECT buyer_id, supplier_id FROM conversations WHERE id = conv_id;
$$;

CREATE OR REPLACE FUNCTION get_order_parties(ord_id uuid)
RETURNS TABLE(buyer_id uuid, supplier_id uuid, supplier_company_id uuid) LANGUAGE sql STABLE SECURITY DEFINER AS $$
  SELECT buyer_id, supplier_id, supplier_company_id FROM orders WHERE id = ord_id;
$$;

CREATE OR REPLACE FUNCTION is_company_owner(comp_id uuid)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER AS $$
  SELECT EXISTS(SELECT 1 FROM companies WHERE id = comp_id AND owner_id = auth.uid());
$$;

-- ============================================================
-- STEP 8: RLS Policies
-- ============================================================

-- order_milestones: parties + admin full access
CREATE POLICY "order_milestones_select" ON order_milestones FOR SELECT TO authenticated
  USING (
    get_my_role() = 'admin'
    OR EXISTS (
      SELECT 1 FROM orders o WHERE o.id = order_id
        AND (o.buyer_id = auth.uid() OR o.supplier_id = auth.uid())
    )
  );
CREATE POLICY "order_milestones_insert" ON order_milestones FOR INSERT TO authenticated
  WITH CHECK (
    get_my_role() = 'admin'
    OR EXISTS (
      SELECT 1 FROM orders o WHERE o.id = order_id
        AND (o.buyer_id = auth.uid() OR o.supplier_id = auth.uid())
    )
  );

-- saved_manufacturers
CREATE POLICY "saved_select" ON saved_manufacturers FOR SELECT TO authenticated
  USING (buyer_id = auth.uid() OR get_my_role() = 'admin');
CREATE POLICY "saved_insert" ON saved_manufacturers FOR INSERT TO authenticated
  WITH CHECK (buyer_id = auth.uid());
CREATE POLICY "saved_delete" ON saved_manufacturers FOR DELETE TO authenticated
  USING (buyer_id = auth.uid());

-- rfq_match_log: manufacturers see their own; admin sees all
CREATE POLICY "rfq_match_select" ON rfq_match_log FOR SELECT TO authenticated
  USING (
    get_my_role() = 'admin'
    OR is_company_owner(company_id)
  );
CREATE POLICY "rfq_match_insert" ON rfq_match_log FOR INSERT TO authenticated
  WITH CHECK (get_my_role() = 'admin');

-- disputes
CREATE POLICY "disputes_select" ON disputes FOR SELECT TO authenticated
  USING (
    raised_by = auth.uid()
    OR against_user_id = auth.uid()
    OR get_my_role() = 'admin'
  );
CREATE POLICY "disputes_insert" ON disputes FOR INSERT TO authenticated
  WITH CHECK (raised_by = auth.uid());
CREATE POLICY "disputes_update" ON disputes FOR UPDATE TO authenticated
  USING (raised_by = auth.uid() OR get_my_role() = 'admin');

-- dispute_actions
CREATE POLICY "dispute_actions_select" ON dispute_actions FOR SELECT TO authenticated
  USING (
    get_my_role() = 'admin'
    OR actor_id = auth.uid()
    OR EXISTS (
      SELECT 1 FROM disputes d WHERE d.id = dispute_id
        AND (d.raised_by = auth.uid() OR d.against_user_id = auth.uid())
    )
  );
CREATE POLICY "dispute_actions_insert" ON dispute_actions FOR INSERT TO authenticated
  WITH CHECK (actor_id = auth.uid() OR get_my_role() = 'admin');

-- fraud_alerts: admin only
CREATE POLICY "fraud_alerts_admin" ON fraud_alerts FOR ALL TO authenticated
  USING (get_my_role() = 'admin')
  WITH CHECK (get_my_role() = 'admin');

-- audit_logs: admin only
CREATE POLICY "audit_logs_admin" ON audit_logs FOR SELECT TO authenticated
  USING (get_my_role() = 'admin');
CREATE POLICY "audit_logs_insert" ON audit_logs FOR INSERT TO authenticated
  WITH CHECK (true);

-- withdrawal_requests
CREATE POLICY "withdrawal_select" ON withdrawal_requests FOR SELECT TO authenticated
  USING (
    get_my_role() = 'admin'
    OR is_company_owner(company_id)
  );
CREATE POLICY "withdrawal_insert" ON withdrawal_requests FOR INSERT TO authenticated
  WITH CHECK (is_company_owner(company_id));
CREATE POLICY "withdrawal_update_admin" ON withdrawal_requests FOR UPDATE TO authenticated
  USING (get_my_role() = 'admin');

-- blocked_users
CREATE POLICY "blocked_select" ON blocked_users FOR SELECT TO authenticated
  USING (blocker_id = auth.uid() OR blocked_id = auth.uid());
CREATE POLICY "blocked_insert" ON blocked_users FOR INSERT TO authenticated
  WITH CHECK (blocker_id = auth.uid());
CREATE POLICY "blocked_delete" ON blocked_users FOR DELETE TO authenticated
  USING (blocker_id = auth.uid());

-- Storage policies for new buckets
CREATE POLICY "verification_docs_owner" ON storage.objects FOR ALL TO authenticated
  USING (bucket_id = 'verification-docs' AND (storage.foldername(name))[1] = auth.uid()::text)
  WITH CHECK (bucket_id = 'verification-docs' AND (storage.foldername(name))[1] = auth.uid()::text);

CREATE POLICY "verification_docs_admin" ON storage.objects FOR SELECT TO authenticated
  USING (bucket_id = 'verification-docs' AND get_my_role() = 'admin');

CREATE POLICY "chat_files_parties" ON storage.objects FOR ALL TO authenticated
  USING (bucket_id = 'chat-files' AND (storage.foldername(name))[1] = auth.uid()::text)
  WITH CHECK (bucket_id = 'chat-files' AND (storage.foldername(name))[1] = auth.uid()::text);

CREATE POLICY "dispute_evidence_parties" ON storage.objects FOR ALL TO authenticated
  USING (bucket_id = 'dispute-evidence' AND (storage.foldername(name))[1] = auth.uid()::text)
  WITH CHECK (bucket_id = 'dispute-evidence' AND (storage.foldername(name))[1] = auth.uid()::text);

CREATE POLICY "quotation_pdfs_parties" ON storage.objects FOR ALL TO authenticated
  USING (bucket_id = 'quotation-pdfs')
  WITH CHECK (bucket_id = 'quotation-pdfs');

-- ============================================================
-- STEP 9: Helper RPC functions for analytics
-- ============================================================

-- Manufacturer response analytics
CREATE OR REPLACE FUNCTION get_manufacturer_analytics(p_company_id uuid)
RETURNS json LANGUAGE plpgsql STABLE SECURITY DEFINER AS $$
DECLARE
  v_rfqs_received  int;
  v_quotes_sent    int;
  v_orders_done    int;
  v_response_rate  numeric;
  v_avg_hours      numeric;
BEGIN
  SELECT COUNT(*) INTO v_rfqs_received FROM rfq_match_log WHERE company_id = p_company_id;
  SELECT COUNT(*) INTO v_quotes_sent FROM quotations WHERE supplier_company_id = p_company_id AND is_draft = false;
  SELECT COUNT(*) INTO v_orders_done FROM orders
    WHERE supplier_company_id = p_company_id AND milestone = 'completed';

  v_response_rate := CASE WHEN v_rfqs_received > 0
    THEN ROUND((v_quotes_sent::numeric / v_rfqs_received) * 100, 1)
    ELSE 0 END;

  SELECT COALESCE(AVG(EXTRACT(EPOCH FROM (q.created_at - r.created_at)) / 3600), 0)
  INTO v_avg_hours
  FROM quotations q
  JOIN requirements r ON r.id = q.requirement_id
  WHERE q.supplier_company_id = p_company_id AND q.is_draft = false;

  RETURN json_build_object(
    'rfqs_received', v_rfqs_received,
    'quotes_sent', v_quotes_sent,
    'orders_completed', v_orders_done,
    'response_rate', v_response_rate,
    'avg_response_hours', ROUND(v_avg_hours, 1)
  );
END;
$$;

-- Update company analytics on quotation insert
CREATE OR REPLACE FUNCTION update_company_response_rate()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_rfqs int; v_quotes int;
BEGIN
  SELECT COUNT(*) INTO v_rfqs FROM rfq_match_log WHERE company_id = NEW.supplier_company_id;
  SELECT COUNT(*) INTO v_quotes FROM quotations
    WHERE supplier_company_id = NEW.supplier_company_id AND is_draft = false;
  UPDATE companies SET
    response_rate = CASE WHEN v_rfqs > 0 THEN ROUND((v_quotes::numeric/v_rfqs)*100,1) ELSE 0 END,
    total_quotes_sent = v_quotes
  WHERE id = NEW.supplier_company_id;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_update_response_rate ON quotations;
CREATE TRIGGER trg_update_response_rate
  AFTER INSERT OR UPDATE ON quotations
  FOR EACH ROW EXECUTE FUNCTION update_company_response_rate();

-- Auto-log order milestone on status change
CREATE OR REPLACE FUNCTION log_order_milestone()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  IF NEW.milestone IS DISTINCT FROM OLD.milestone THEN
    INSERT INTO order_milestones(order_id, milestone, changed_by)
    VALUES(NEW.id, NEW.milestone, auth.uid());
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_log_milestone ON orders;
CREATE TRIGGER trg_log_milestone
  AFTER UPDATE ON orders
  FOR EACH ROW EXECUTE FUNCTION log_order_milestone();

-- Notify followers when manufacturer updates products
CREATE OR REPLACE FUNCTION notify_followers_on_product()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  r RECORD;
BEGIN
  FOR r IN
    SELECT sm.buyer_id FROM saved_manufacturers sm WHERE sm.company_id = NEW.company_id
  LOOP
    INSERT INTO notifications(user_id, title, message, type, link, reference_id, reference_type)
    SELECT r.buyer_id,
      'New product from followed manufacturer',
      (SELECT company_name FROM companies WHERE id = NEW.company_id) || ' added a new product: ' || NEW.name,
      'product_update',
      '/companies/' || (SELECT slug FROM companies WHERE id = NEW.company_id),
      NEW.id,
      'product';
  END LOOP;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_notify_followers ON products;
CREATE TRIGGER trg_notify_followers
  AFTER INSERT ON products
  FOR EACH ROW EXECUTE FUNCTION notify_followers_on_product();

-- ============================================================
-- STEP 10: Indexes for performance
-- ============================================================
CREATE INDEX IF NOT EXISTS idx_order_milestones_order ON order_milestones(order_id);
CREATE INDEX IF NOT EXISTS idx_saved_manufacturers_buyer ON saved_manufacturers(buyer_id);
CREATE INDEX IF NOT EXISTS idx_saved_manufacturers_company ON saved_manufacturers(company_id);
CREATE INDEX IF NOT EXISTS idx_rfq_match_log_req ON rfq_match_log(requirement_id);
CREATE INDEX IF NOT EXISTS idx_rfq_match_log_company ON rfq_match_log(company_id);
CREATE INDEX IF NOT EXISTS idx_disputes_order ON disputes(order_id);
CREATE INDEX IF NOT EXISTS idx_disputes_raised_by ON disputes(raised_by);
CREATE INDEX IF NOT EXISTS idx_fraud_alerts_user ON fraud_alerts(user_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_actor ON audit_logs(actor_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_created ON audit_logs(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_notifications_user ON notifications(user_id, is_read, created_at DESC);
