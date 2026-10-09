
-- ─────────────────────────────────────────────────────────────
-- subscription_invoices: GST invoice records for subscription payments
-- ─────────────────────────────────────────────────────────────
CREATE SEQUENCE IF NOT EXISTS subscription_invoice_seq START 1001;

CREATE TABLE IF NOT EXISTS subscription_invoices (
  id                    uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  invoice_number        text NOT NULL UNIQUE DEFAULT ('INV-BSK-' || LPAD(nextval('subscription_invoice_seq')::text, 6, '0')),
  company_id            uuid NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
  subscription_order_id uuid REFERENCES subscription_orders(id) ON DELETE SET NULL,
  user_id               uuid NOT NULL REFERENCES auth.users(id),

  -- Plan info
  plan_tier             text NOT NULL,
  plan_label            text NOT NULL,
  billing_cycle         text NOT NULL DEFAULT 'monthly',

  -- Amounts (all in INR)
  base_amount           numeric(10,2) NOT NULL,   -- pre-tax
  cgst_rate             numeric(5,2) NOT NULL DEFAULT 9.00,
  sgst_rate             numeric(5,2) NOT NULL DEFAULT 9.00,
  igst_rate             numeric(5,2) NOT NULL DEFAULT 0.00,
  cgst_amount           numeric(10,2) NOT NULL DEFAULT 0,
  sgst_amount           numeric(10,2) NOT NULL DEFAULT 0,
  igst_amount           numeric(10,2) NOT NULL DEFAULT 0,
  total_amount          numeric(10,2) NOT NULL,

  -- Billing details (captured at time of invoice)
  bill_to_name          text,
  bill_to_company       text,
  bill_to_gst           text,
  bill_to_address       text,
  bill_to_email         text,
  razorpay_payment_id   text,

  -- GST supply type: 'intra' (CGST+SGST) or 'inter' (IGST)
  supply_type           text NOT NULL DEFAULT 'intra',

  -- PDF
  pdf_url               text,
  pdf_generated_at      timestamptz,

  status                text NOT NULL DEFAULT 'issued' CHECK (status IN ('issued','cancelled')),
  created_at            timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX idx_sub_invoices_company  ON subscription_invoices(company_id);
CREATE INDEX idx_sub_invoices_user     ON subscription_invoices(user_id);
CREATE INDEX idx_sub_invoices_order    ON subscription_invoices(subscription_order_id);

ALTER TABLE subscription_invoices ENABLE ROW LEVEL SECURITY;

CREATE POLICY "invoices_select_own" ON subscription_invoices
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "invoices_service_all" ON subscription_invoices
  FOR ALL USING (auth.jwt()->>'role' = 'service_role')
  WITH CHECK (auth.jwt()->>'role' = 'service_role');

-- invoices-pdfs bucket (private, 50 MB cap per file)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES ('invoices-pdfs', 'invoices-pdfs', false, 52428800, ARRAY['application/pdf'])
ON CONFLICT (id) DO NOTHING;

-- RLS for invoices-pdfs: owner can read their own PDFs
CREATE POLICY "invoice_pdf_select_own" ON storage.objects
  FOR SELECT USING (
    bucket_id = 'invoices-pdfs'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY "invoice_pdf_service_all" ON storage.objects
  FOR ALL USING (
    bucket_id = 'invoices-pdfs'
    AND auth.jwt()->>'role' = 'service_role'
  )
  WITH CHECK (
    bucket_id = 'invoices-pdfs'
    AND auth.jwt()->>'role' = 'service_role'
  );
