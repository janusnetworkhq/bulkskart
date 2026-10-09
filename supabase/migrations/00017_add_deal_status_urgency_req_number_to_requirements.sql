-- Add deal_status, urgency flag, and human-readable requirement number
ALTER TABLE requirements
  ADD COLUMN IF NOT EXISTS deal_status   text NOT NULL DEFAULT 'active'
    CHECK (deal_status IN ('active','responses_received','negotiation','deal_finalized','fulfilled','closed')),
  ADD COLUMN IF NOT EXISTS is_urgent     boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS req_number    text UNIQUE;

-- Auto-generate req_number like RFQ-000123
CREATE OR REPLACE FUNCTION generate_req_number()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.req_number IS NULL THEN
    NEW.req_number := 'RFQ-' || LPAD(NEXTVAL('req_number_seq')::text, 6, '0');
  END IF;
  RETURN NEW;
END;
$$;

CREATE SEQUENCE IF NOT EXISTS req_number_seq START 1000;

DROP TRIGGER IF EXISTS trg_req_number ON requirements;
CREATE TRIGGER trg_req_number
  BEFORE INSERT ON requirements
  FOR EACH ROW EXECUTE FUNCTION generate_req_number();

-- Backfill existing rows that have no req_number
UPDATE requirements SET req_number = 'RFQ-' || LPAD(NEXTVAL('req_number_seq')::text, 6, '0')
WHERE req_number IS NULL;

-- Add quotation shipping_cost column if missing
ALTER TABLE quotations
  ADD COLUMN IF NOT EXISTS shipping_cost numeric,
  ADD COLUMN IF NOT EXISTS available_quantity integer;

-- Notify buyer on new quotation (trigger creates a notification row)
CREATE OR REPLACE FUNCTION notify_buyer_on_quote()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_buyer_id uuid;
  v_title    text;
BEGIN
  SELECT buyer_id, title INTO v_buyer_id, v_title
  FROM requirements WHERE id = NEW.requirement_id;
  IF v_buyer_id IS NOT NULL THEN
    INSERT INTO notifications(user_id, title, message, type, link)
    VALUES (
      v_buyer_id,
      'New Supplier Response',
      'A supplier has responded to your requirement: ' || v_title,
      'quotation',
      '/requirements'
    );
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_notify_buyer_on_quote ON quotations;
CREATE TRIGGER trg_notify_buyer_on_quote
  AFTER INSERT ON quotations
  FOR EACH ROW EXECUTE FUNCTION notify_buyer_on_quote();

-- Notify supplier on deal_status change
CREATE OR REPLACE FUNCTION notify_supplier_on_deal_status()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_supplier_id uuid;
BEGIN
  IF OLD.deal_status IS DISTINCT FROM NEW.deal_status THEN
    -- Notify all suppliers who quoted on this requirement
    FOR v_supplier_id IN
      SELECT DISTINCT supplier_id FROM quotations WHERE requirement_id = NEW.id
    LOOP
      INSERT INTO notifications(user_id, title, message, type, link)
      VALUES (
        v_supplier_id,
        'Requirement Status Updated',
        'Status changed to ' || NEW.deal_status || ' for: ' || NEW.title,
        'deal_status',
        '/requirements'
      );
    END LOOP;
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_notify_supplier_on_deal_status ON requirements;
CREATE TRIGGER trg_notify_supplier_on_deal_status
  AFTER UPDATE ON requirements
  FOR EACH ROW EXECUTE FUNCTION notify_supplier_on_deal_status();