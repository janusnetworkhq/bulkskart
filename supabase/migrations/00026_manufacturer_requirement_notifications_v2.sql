
-- ─────────────────────────────────────────────────────────────
-- 1. Enable pg_net for async HTTP calls from DB triggers
-- ─────────────────────────────────────────────────────────────
CREATE EXTENSION IF NOT EXISTS pg_net WITH SCHEMA extensions;

-- ─────────────────────────────────────────────────────────────
-- 2. Add urgency_label to notifications
-- ─────────────────────────────────────────────────────────────
ALTER TABLE notifications
  ADD COLUMN IF NOT EXISTS urgency_label text;

-- ─────────────────────────────────────────────────────────────
-- 3. Trigger: new buyer requirement → call run-rfq-matching EF
-- ─────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION trigger_rfq_matching_on_new_req()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  IF NEW.status <> 'active' THEN
    RETURN NEW;
  END IF;

  PERFORM extensions.http_post(
    'https://ewnftvshvsrhawluloty.supabase.co/functions/v1/run-rfq-matching',
    jsonb_build_object('rfq_id', NEW.id)::text,
    'application/json'
  );

  RETURN NEW;
EXCEPTION WHEN OTHERS THEN
  -- Never block the INSERT if EF call fails
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_rfq_matching_on_new_req ON requirements;
CREATE TRIGGER trg_rfq_matching_on_new_req
  AFTER INSERT ON requirements
  FOR EACH ROW EXECUTE FUNCTION trigger_rfq_matching_on_new_req();

-- ─────────────────────────────────────────────────────────────
-- 4. Trigger: new company → call match-new-manufacturer EF
-- ─────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION trigger_match_on_new_manufacturer()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  PERFORM extensions.http_post(
    'https://ewnftvshvsrhawluloty.supabase.co/functions/v1/match-new-manufacturer',
    jsonb_build_object('company_id', NEW.id)::text,
    'application/json'
  );

  RETURN NEW;
EXCEPTION WHEN OTHERS THEN
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_match_on_new_manufacturer ON companies;
CREATE TRIGGER trg_match_on_new_manufacturer
  AFTER INSERT ON companies
  FOR EACH ROW EXECUTE FUNCTION trigger_match_on_new_manufacturer();
