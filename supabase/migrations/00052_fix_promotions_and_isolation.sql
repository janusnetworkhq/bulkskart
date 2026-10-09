-- 1. Add Razorpay fields to product_promotions
ALTER TABLE public.product_promotions
  ADD COLUMN IF NOT EXISTS razorpay_order_id TEXT,
  ADD COLUMN IF NOT EXISTS razorpay_payment_id TEXT,
  ADD COLUMN IF NOT EXISTS razorpay_signature TEXT,
  ADD COLUMN IF NOT EXISTS base_amount NUMERIC(12,2),
  ADD COLUMN IF NOT EXISTS gst_amount NUMERIC(12,2);

-- 2. Ensure RLS on product_promotions
ALTER TABLE public.product_promotions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "supplier_manage_promotions" ON public.product_promotions;
DROP POLICY IF EXISTS "public_read_active_promotions" ON public.product_promotions;

CREATE POLICY "supplier_manage_promotions" ON public.product_promotions
  FOR ALL TO authenticated
  USING (
    company_id IN (SELECT id FROM public.companies WHERE owner_id = auth.uid())
    OR is_admin()
  )
  WITH CHECK (
    company_id IN (SELECT id FROM public.companies WHERE owner_id = auth.uid())
    OR is_admin()
  );

CREATE POLICY "public_read_active_promotions" ON public.product_promotions
  FOR SELECT TO public
  USING (status = 'active');

-- 3. Ensure RLS on rfq_matches
ALTER TABLE public.rfq_matches ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "rfq_matches_select_own" ON public.rfq_matches;
DROP POLICY IF EXISTS "rfq_matches_all_own" ON public.rfq_matches;

CREATE POLICY "rfq_matches_select_own" ON public.rfq_matches
  FOR SELECT TO authenticated
  USING (
    company_id IN (SELECT id FROM public.companies WHERE owner_id = auth.uid())
    OR is_admin()
  );

CREATE POLICY "rfq_matches_manage_own" ON public.rfq_matches
  FOR ALL TO authenticated
  USING (
    company_id IN (SELECT id FROM public.companies WHERE owner_id = auth.uid())
    OR is_admin()
  )
  WITH CHECK (
    company_id IN (SELECT id FROM public.companies WHERE owner_id = auth.uid())
    OR is_admin()
  );

-- 4. Mark expired auctions completed
UPDATE public.auctions
SET status = 'completed'
WHERE status = 'live' AND end_time <= now();
