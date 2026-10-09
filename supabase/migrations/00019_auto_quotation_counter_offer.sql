
ALTER TABLE auto_quotations
  ADD COLUMN IF NOT EXISTS counter_offer_price   numeric(14,4),
  ADD COLUMN IF NOT EXISTS counter_offer_message text,
  ADD COLUMN IF NOT EXISTS counter_offer_at      timestamptz;
