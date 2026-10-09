
-- Add promotion columns to products
ALTER TABLE products
  ADD COLUMN IF NOT EXISTS is_sponsored   boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS is_promoted    boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS promotion_type text;   -- 'featured' | 'boost' | null

-- Main promotions / campaigns table
CREATE TABLE IF NOT EXISTS product_promotions (
  id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id        uuid NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
  product_id        uuid NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  promotion_type    text NOT NULL CHECK (promotion_type IN ('featured', 'boost', 'campaign')),
  target_category   text,
  target_country    text,
  duration_days     int  NOT NULL DEFAULT 7,
  daily_budget      numeric(10,2),
  total_budget      numeric(10,2),
  status            text NOT NULL DEFAULT 'draft'
                    CHECK (status IN ('draft','pending_payment','active','paused','completed','cancelled')),
  -- estimated reach (computed / shown to supplier)
  est_impressions   int  DEFAULT 0,
  est_views         int  DEFAULT 0,
  est_clicks        int  DEFAULT 0,
  est_leads         int  DEFAULT 0,
  -- actual analytics
  actual_impressions int DEFAULT 0,
  actual_views       int DEFAULT 0,
  actual_clicks      int DEFAULT 0,
  actual_leads       int DEFAULT 0,
  total_spent        numeric(10,2) DEFAULT 0,
  -- payment
  payment_amount    numeric(10,2),
  payment_currency  text DEFAULT 'INR',
  payment_status    text DEFAULT 'pending' CHECK (payment_status IN ('pending','paid','failed','refunded')),
  payment_method    text,
  payment_ref       text,
  paid_at           timestamptz,
  -- lifecycle
  starts_at         timestamptz,
  ends_at           timestamptz,
  created_at        timestamptz DEFAULT now(),
  updated_at        timestamptz DEFAULT now()
);

-- RLS
ALTER TABLE product_promotions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "supplier_manage_promotions" ON product_promotions
  FOR ALL USING (
    company_id IN (SELECT id FROM companies WHERE owner_id = auth.uid())
  );

CREATE POLICY "public_read_active_promotions" ON product_promotions
  FOR SELECT USING (status = 'active');

-- Index
CREATE INDEX IF NOT EXISTS idx_product_promotions_company   ON product_promotions(company_id);
CREATE INDEX IF NOT EXISTS idx_product_promotions_product   ON product_promotions(product_id);
CREATE INDEX IF NOT EXISTS idx_product_promotions_status    ON product_promotions(status);
