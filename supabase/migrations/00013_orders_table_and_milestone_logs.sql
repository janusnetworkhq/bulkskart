
-- ── Orders table ────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS orders (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_number        TEXT NOT NULL UNIQUE,
  quotation_id        UUID NOT NULL REFERENCES quotations(id) ON DELETE RESTRICT,
  requirement_id      UUID REFERENCES requirements(id) ON DELETE SET NULL,
  buyer_id            UUID NOT NULL REFERENCES auth.users(id),
  supplier_id         UUID REFERENCES auth.users(id),
  supplier_company_id UUID NOT NULL REFERENCES companies(id),
  total_amount        NUMERIC(14,2) NOT NULL DEFAULT 0,
  currency            TEXT NOT NULL DEFAULT 'INR',
  quantity            NUMERIC(12,2) NOT NULL DEFAULT 1,
  quantity_unit       TEXT,
  milestone           TEXT NOT NULL DEFAULT 'quote_accepted',
  notes               TEXT,
  cancelled_reason    TEXT,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ── Milestone logs ───────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS order_milestone_logs (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id     UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  milestone    TEXT NOT NULL,
  changed_by   UUID NOT NULL REFERENCES auth.users(id),
  notes        TEXT,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ── Order number sequence ────────────────────────────────────────────────
CREATE SEQUENCE IF NOT EXISTS order_number_seq START 10001 INCREMENT 1;

-- ── Auto-generate order_number trigger ──────────────────────────────────
CREATE OR REPLACE FUNCTION generate_order_number()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.order_number IS NULL OR NEW.order_number = '' THEN
    NEW.order_number := 'ORD-' || TO_CHAR(NOW(), 'YYYYMM') || '-' || LPAD(nextval('order_number_seq')::TEXT, 5, '0');
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_generate_order_number ON orders;
CREATE TRIGGER trg_generate_order_number
  BEFORE INSERT ON orders
  FOR EACH ROW EXECUTE FUNCTION generate_order_number();

-- ── Updated_at trigger ───────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION update_orders_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN NEW.updated_at = now(); RETURN NEW; END;
$$;

DROP TRIGGER IF EXISTS trg_orders_updated_at ON orders;
CREATE TRIGGER trg_orders_updated_at
  BEFORE UPDATE ON orders
  FOR EACH ROW EXECUTE FUNCTION update_orders_updated_at();

-- ── RLS ──────────────────────────────────────────────────────────────────
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_milestone_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Buyers see their own orders"
  ON orders FOR SELECT USING (buyer_id = auth.uid());

CREATE POLICY "Suppliers see orders for their company"
  ON orders FOR SELECT USING (
    supplier_company_id IN (SELECT id FROM companies WHERE owner_id = auth.uid())
  );

CREATE POLICY "Buyers create orders"
  ON orders FOR INSERT WITH CHECK (buyer_id = auth.uid());

CREATE POLICY "Order parties update orders"
  ON orders FOR UPDATE USING (
    buyer_id = auth.uid()
    OR supplier_company_id IN (SELECT id FROM companies WHERE owner_id = auth.uid())
    OR EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

CREATE POLICY "Admins full access orders"
  ON orders FOR ALL USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

CREATE POLICY "Order parties see milestone logs"
  ON order_milestone_logs FOR SELECT USING (
    order_id IN (
      SELECT id FROM orders
      WHERE buyer_id = auth.uid()
         OR supplier_company_id IN (SELECT id FROM companies WHERE owner_id = auth.uid())
    )
    OR EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

CREATE POLICY "Order parties insert milestone logs"
  ON order_milestone_logs FOR INSERT WITH CHECK (
    changed_by = auth.uid()
    AND order_id IN (
      SELECT id FROM orders
      WHERE buyer_id = auth.uid()
         OR supplier_company_id IN (SELECT id FROM companies WHERE owner_id = auth.uid())
    )
  );

-- ── Indexes ───────────────────────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_orders_buyer_id ON orders(buyer_id);
CREATE INDEX IF NOT EXISTS idx_orders_supplier_company_id ON orders(supplier_company_id);
CREATE INDEX IF NOT EXISTS idx_orders_quotation_id ON orders(quotation_id);
CREATE INDEX IF NOT EXISTS idx_milestone_logs_order_id ON order_milestone_logs(order_id);
