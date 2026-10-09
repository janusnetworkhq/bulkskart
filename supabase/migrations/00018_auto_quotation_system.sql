
-- Supplier auto-quote settings (one row per company)
CREATE TABLE IF NOT EXISTS supplier_auto_quote_settings (
  id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id          uuid NOT NULL UNIQUE REFERENCES companies(id) ON DELETE CASCADE,
  auto_send_enabled   boolean NOT NULL DEFAULT false,
  require_approval    boolean NOT NULL DEFAULT true,
  default_validity_days int NOT NULL DEFAULT 30,
  default_payment_terms text,
  default_delivery_days int DEFAULT 14,
  shipping_rate_pct   numeric(5,2) DEFAULT 5.00,   -- % of product subtotal
  tax_rate_pct        numeric(5,2) DEFAULT 18.00,  -- GST %
  other_charges       numeric(12,2) DEFAULT 0,
  terms_and_conditions text,
  created_at          timestamptz NOT NULL DEFAULT now(),
  updated_at          timestamptz NOT NULL DEFAULT now()
);

-- Auto-generated quotation records
CREATE TABLE IF NOT EXISTS auto_quotations (
  id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  requirement_id      uuid NOT NULL REFERENCES requirements(id) ON DELETE CASCADE,
  supplier_company_id uuid NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
  quotation_id        uuid REFERENCES quotations(id) ON DELETE SET NULL, -- set after approval/send
  buyer_id            uuid NOT NULL,
  status              text NOT NULL DEFAULT 'draft'
                      CHECK (status IN ('draft','pending_approval','sent','accepted','rejected','revised_requested','expired')),
  -- Calculation breakdown
  unit_price          numeric(14,4) NOT NULL,
  quantity            numeric(14,4) NOT NULL,
  quantity_unit       text,
  currency            text NOT NULL DEFAULT 'INR',
  subtotal            numeric(14,2) NOT NULL,
  shipping_cost       numeric(14,2) NOT NULL DEFAULT 0,
  tax_amount          numeric(14,2) NOT NULL DEFAULT 0,
  other_charges       numeric(14,2) NOT NULL DEFAULT 0,
  total_amount        numeric(14,2) NOT NULL,
  -- Quote details
  product_name        text NOT NULL,
  product_specs       text,
  moq                 int NOT NULL DEFAULT 1,
  moq_unit            text DEFAULT 'Pcs',
  delivery_days       int,
  estimated_delivery_date date,
  validity_days       int NOT NULL DEFAULT 30,
  valid_until         date,
  payment_terms       text,
  terms_and_conditions text,
  -- Meta
  is_auto_generated   boolean NOT NULL DEFAULT true,
  auto_sent_at        timestamptz,
  approved_at         timestamptz,
  approved_by         uuid,
  buyer_action        text CHECK (buyer_action IN ('accepted','rejected','revised_requested') OR buyer_action IS NULL),
  buyer_action_at     timestamptz,
  buyer_notes         text,
  created_at          timestamptz NOT NULL DEFAULT now(),
  updated_at          timestamptz NOT NULL DEFAULT now(),
  UNIQUE (requirement_id, supplier_company_id)
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_auto_quotations_requirement ON auto_quotations(requirement_id);
CREATE INDEX IF NOT EXISTS idx_auto_quotations_supplier ON auto_quotations(supplier_company_id);
CREATE INDEX IF NOT EXISTS idx_auto_quotations_buyer ON auto_quotations(buyer_id);
CREATE INDEX IF NOT EXISTS idx_auto_quotations_status ON auto_quotations(status);

-- RLS
ALTER TABLE supplier_auto_quote_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE auto_quotations ENABLE ROW LEVEL SECURITY;

-- Supplier can manage their own settings
CREATE POLICY "supplier_manage_auto_settings"
  ON supplier_auto_quote_settings FOR ALL
  USING (
    company_id IN (
      SELECT id FROM companies WHERE owner_id = auth.uid()
    )
  );

-- Auto quotations: supplier can see/manage their own; buyer can see ones sent to them
CREATE POLICY "supplier_manage_auto_quotations"
  ON auto_quotations FOR ALL
  USING (
    supplier_company_id IN (
      SELECT id FROM companies WHERE owner_id = auth.uid()
    )
  );

CREATE POLICY "buyer_view_auto_quotations"
  ON auto_quotations FOR SELECT
  USING (buyer_id = auth.uid());

CREATE POLICY "buyer_update_auto_quotations"
  ON auto_quotations FOR UPDATE
  USING (buyer_id = auth.uid())
  WITH CHECK (buyer_id = auth.uid());
