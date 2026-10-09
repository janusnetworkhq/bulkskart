
-- 1. Add tracking columns to orders (idempotent via DO block)
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='orders' AND column_name='order_status') THEN
    ALTER TABLE public.orders ADD COLUMN order_status text NOT NULL DEFAULT 'pending'
      CHECK (order_status IN ('pending','confirmed','processing','shipped','delivered','cancelled'));
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='orders' AND column_name='tracking_courier') THEN
    ALTER TABLE public.orders ADD COLUMN tracking_courier text;
    ALTER TABLE public.orders ADD COLUMN tracking_number text;
    ALTER TABLE public.orders ADD COLUMN tracking_eta date;
  END IF;
END $$;

-- Sync existing milestone values to order_status
UPDATE public.orders SET order_status =
  CASE
    WHEN milestone IN ('quote_accepted')                      THEN 'pending'
    WHEN milestone IN ('order_processing')                    THEN 'confirmed'
    WHEN milestone IN ('production','ready_for_dispatch')     THEN 'processing'
    WHEN milestone IN ('dispatched')                          THEN 'shipped'
    WHEN milestone IN ('delivered','completed')               THEN 'delivered'
    WHEN milestone IN ('cancelled')                           THEN 'cancelled'
    ELSE 'pending'
  END
WHERE order_status = 'pending';

-- 2. order_status_history — full audit log of every status change
CREATE TABLE IF NOT EXISTS public.order_status_history (
  id             uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id       uuid NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
  from_status    text,
  to_status      text NOT NULL,
  changed_by     uuid NOT NULL REFERENCES auth.users(id),
  changer_role   text NOT NULL CHECK (changer_role IN ('buyer','supplier','admin')),
  notes          text,
  created_at     timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS osh_order_id_idx ON public.order_status_history(order_id);
CREATE INDEX IF NOT EXISTS osh_created_at_idx ON public.order_status_history(created_at DESC);

-- RLS
ALTER TABLE public.order_status_history ENABLE ROW LEVEL SECURITY;

-- Buyer can read history of their own orders
CREATE POLICY "buyer_read_own_order_history"
  ON public.order_status_history FOR SELECT
  USING (
    order_id IN (SELECT id FROM public.orders WHERE buyer_id = auth.uid())
  );

-- Supplier can read history of orders for their company
CREATE POLICY "supplier_read_own_order_history"
  ON public.order_status_history FOR SELECT
  USING (
    order_id IN (
      SELECT o.id FROM public.orders o
      JOIN public.companies c ON c.id = o.supplier_company_id
      WHERE c.owner_id = auth.uid()
    )
  );

-- Admin can read all
CREATE POLICY "admin_read_all_order_history"
  ON public.order_status_history FOR SELECT
  USING (
    EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
  );

-- Anyone involved can insert (validated in edge function / RLS on orders)
CREATE POLICY "insert_order_history"
  ON public.order_status_history FOR INSERT
  WITH CHECK (changed_by = auth.uid());
