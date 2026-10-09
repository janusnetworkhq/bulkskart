
-- ============================================================
-- 1. Inventory / Stock Management
-- ============================================================
CREATE TABLE IF NOT EXISTS product_inventory (
  id             uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id     uuid NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  company_id     uuid NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
  stock_qty      int  NOT NULL DEFAULT 0,
  reserved_qty   int  NOT NULL DEFAULT 0,
  available_qty  int  GENERATED ALWAYS AS (GREATEST(stock_qty - reserved_qty, 0)) STORED,
  low_stock_threshold int NOT NULL DEFAULT 10,
  reorder_qty    int  NOT NULL DEFAULT 50,
  warehouse_location text,
  sku            text,
  last_restocked_at timestamptz,
  created_at     timestamptz DEFAULT now(),
  updated_at     timestamptz DEFAULT now()
);
ALTER TABLE product_inventory ENABLE ROW LEVEL SECURITY;
CREATE UNIQUE INDEX IF NOT EXISTS idx_inventory_product ON product_inventory(product_id);
CREATE INDEX IF NOT EXISTS idx_inventory_company ON product_inventory(company_id);
CREATE POLICY "supplier_manage_inventory" ON product_inventory FOR ALL
  USING (company_id IN (SELECT id FROM companies WHERE owner_id = auth.uid()));
CREATE POLICY "public_read_inventory" ON product_inventory FOR SELECT USING (true);

-- ============================================================
-- 2. Bulk Discount Rules
-- ============================================================
CREATE TABLE IF NOT EXISTS bulk_discount_rules (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id  uuid NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  company_id  uuid NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
  min_qty     int  NOT NULL,
  max_qty     int,
  discount_pct numeric(5,2) NOT NULL DEFAULT 0,
  fixed_price numeric(14,2),
  label       text,
  is_active   boolean NOT NULL DEFAULT true,
  created_at  timestamptz DEFAULT now()
);
ALTER TABLE bulk_discount_rules ENABLE ROW LEVEL SECURITY;
CREATE INDEX IF NOT EXISTS idx_bulk_discount_product ON bulk_discount_rules(product_id);
CREATE POLICY "supplier_manage_discounts" ON bulk_discount_rules FOR ALL
  USING (company_id IN (SELECT id FROM companies WHERE owner_id = auth.uid()));
CREATE POLICY "public_read_discounts" ON bulk_discount_rules FOR SELECT USING (true);

-- ============================================================
-- 3. Sample Requests
-- ============================================================
CREATE TABLE IF NOT EXISTS sample_requests (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id      uuid NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  buyer_id        uuid NOT NULL DEFAULT auth.uid() REFERENCES profiles(id) ON DELETE CASCADE,
  supplier_company_id uuid NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
  quantity        int  NOT NULL DEFAULT 1,
  purpose         text,
  shipping_address text,
  status          text NOT NULL DEFAULT 'pending'
                  CHECK (status IN ('pending','approved','shipped','delivered','rejected')),
  supplier_notes  text,
  tracking_number text,
  created_at      timestamptz DEFAULT now(),
  updated_at      timestamptz DEFAULT now()
);
ALTER TABLE sample_requests ENABLE ROW LEVEL SECURITY;
CREATE INDEX IF NOT EXISTS idx_sample_requests_buyer    ON sample_requests(buyer_id);
CREATE INDEX IF NOT EXISTS idx_sample_requests_supplier ON sample_requests(supplier_company_id);
CREATE POLICY "buyer_manage_own_samples" ON sample_requests FOR ALL
  USING (buyer_id = auth.uid());
CREATE POLICY "supplier_view_own_samples" ON sample_requests FOR SELECT
  USING (supplier_company_id IN (SELECT id FROM companies WHERE owner_id = auth.uid()));
CREATE POLICY "supplier_update_own_samples" ON sample_requests FOR UPDATE
  USING (supplier_company_id IN (SELECT id FROM companies WHERE owner_id = auth.uid()));

-- ============================================================
-- 4. Shipping Quotes
-- ============================================================
CREATE TABLE IF NOT EXISTS shipping_quotes (
  id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  requester_id      uuid NOT NULL DEFAULT auth.uid() REFERENCES profiles(id) ON DELETE CASCADE,
  origin_city       text NOT NULL,
  origin_country    text NOT NULL DEFAULT 'India',
  destination_city  text NOT NULL,
  destination_country text NOT NULL,
  cargo_type        text,
  weight_kg         numeric(10,2),
  volume_cbm        numeric(10,2),
  shipment_mode     text CHECK (shipment_mode IN ('air','sea','road','rail','multimodal')),
  incoterms         text,
  status            text NOT NULL DEFAULT 'pending'
                    CHECK (status IN ('pending','quoted','accepted','expired')),
  estimated_cost_min numeric(14,2),
  estimated_cost_max numeric(14,2),
  currency          text DEFAULT 'INR',
  estimated_days_min int,
  estimated_days_max int,
  notes             text,
  created_at        timestamptz DEFAULT now(),
  updated_at        timestamptz DEFAULT now()
);
ALTER TABLE shipping_quotes ENABLE ROW LEVEL SECURITY;
CREATE INDEX IF NOT EXISTS idx_shipping_quotes_requester ON shipping_quotes(requester_id);
CREATE POLICY "user_manage_own_shipping_quotes" ON shipping_quotes FOR ALL
  USING (requester_id = auth.uid());
CREATE POLICY "admin_read_all_shipping_quotes" ON shipping_quotes FOR SELECT
  USING ((SELECT role FROM profiles WHERE id = auth.uid()) = 'admin');

-- ============================================================
-- 5. Lead Credits (supplier wallet extension)
-- ============================================================
ALTER TABLE companies
  ADD COLUMN IF NOT EXISTS lead_credits int NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS commission_balance numeric(14,2) NOT NULL DEFAULT 0;

CREATE TABLE IF NOT EXISTS lead_credit_transactions (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id  uuid NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
  type        text NOT NULL CHECK (type IN ('purchase','consume','refund','bonus')),
  credits     int  NOT NULL,
  amount_inr  numeric(10,2),
  reference   text,
  description text,
  created_at  timestamptz DEFAULT now()
);
ALTER TABLE lead_credit_transactions ENABLE ROW LEVEL SECURITY;
CREATE INDEX IF NOT EXISTS idx_lead_credit_company ON lead_credit_transactions(company_id);
CREATE POLICY "supplier_view_own_credits" ON lead_credit_transactions FOR ALL
  USING (company_id IN (SELECT id FROM companies WHERE owner_id = auth.uid()));

-- ============================================================
-- 6. Commission tracking on orders
-- ============================================================
ALTER TABLE orders
  ADD COLUMN IF NOT EXISTS commission_pct   numeric(5,2) NOT NULL DEFAULT 2.00,
  ADD COLUMN IF NOT EXISTS commission_amount numeric(14,2),
  ADD COLUMN IF NOT EXISTS commission_status text DEFAULT 'pending'
                           CHECK (commission_status IN ('pending','collected','waived'));

-- Ensure status column allows 'pending' (older tables used confirmed as first status)
ALTER TABLE orders
  ADD COLUMN IF NOT EXISTS payment_status text DEFAULT 'pending'
                           CHECK (payment_status IN ('pending','paid','escrow','released','refunded'));

-- ============================================================
-- 7. Instant Quote Requests (on product detail)
-- ============================================================
CREATE TABLE IF NOT EXISTS instant_quote_requests (
  id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id          uuid NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  buyer_id            uuid NOT NULL DEFAULT auth.uid() REFERENCES profiles(id) ON DELETE CASCADE,
  supplier_company_id uuid NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
  quantity            int  NOT NULL DEFAULT 1,
  quantity_unit       text NOT NULL DEFAULT 'Pcs',
  message             text,
  destination_country text,
  status              text NOT NULL DEFAULT 'pending'
                      CHECK (status IN ('pending','responded','closed')),
  response_price      numeric(14,2),
  response_notes      text,
  responded_at        timestamptz,
  created_at          timestamptz DEFAULT now(),
  updated_at          timestamptz DEFAULT now()
);
ALTER TABLE instant_quote_requests ENABLE ROW LEVEL SECURITY;
CREATE INDEX IF NOT EXISTS idx_iqr_buyer    ON instant_quote_requests(buyer_id);
CREATE INDEX IF NOT EXISTS idx_iqr_supplier ON instant_quote_requests(supplier_company_id);
CREATE POLICY "buyer_manage_iqr" ON instant_quote_requests FOR ALL
  USING (buyer_id = auth.uid());
CREATE POLICY "supplier_view_iqr" ON instant_quote_requests FOR SELECT
  USING (supplier_company_id IN (SELECT id FROM companies WHERE owner_id = auth.uid()));
CREATE POLICY "supplier_respond_iqr" ON instant_quote_requests FOR UPDATE
  USING (supplier_company_id IN (SELECT id FROM companies WHERE owner_id = auth.uid()));
