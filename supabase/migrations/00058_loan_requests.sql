-- Buyer loan requests submitted from the landing calculator.
-- Anonymous visitors can insert a request. Only admins can read or update them.

CREATE TABLE IF NOT EXISTS public.loan_requests (
  id                   uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id              uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
  full_name            text NOT NULL,
  company_name         text NOT NULL,
  email                text NOT NULL,
  phone                text NOT NULL,
  city                 text NOT NULL,
  country              text NOT NULL DEFAULT 'India',
  loan_amount          numeric(14,2) NOT NULL,
  currency             text NOT NULL DEFAULT 'INR',
  order_amount         numeric(14,2),
  down_payment_pct     numeric(5,2),
  annual_rate_pct      numeric(5,2),
  tenure_months        integer,
  monthly_installment  numeric(14,2),
  goods_needed         text,
  status               text NOT NULL DEFAULT 'new'
                       CHECK (status IN ('new', 'reviewing', 'contacted', 'closed')),
  created_at           timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS loan_requests_created_at_idx ON public.loan_requests (created_at DESC);
CREATE INDEX IF NOT EXISTS loan_requests_status_idx ON public.loan_requests (status);

ALTER TABLE public.loan_requests ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS loan_requests_public_insert ON public.loan_requests;
CREATE POLICY loan_requests_public_insert
  ON public.loan_requests
  FOR INSERT
  TO anon, authenticated
  WITH CHECK (
    user_id IS NOT DISTINCT FROM auth.uid()
    AND char_length(btrim(full_name)) BETWEEN 2 AND 80
    AND char_length(btrim(company_name)) BETWEEN 2 AND 120
    AND char_length(btrim(email)) BETWEEN 5 AND 160
    AND email ~* '^[^@[:space:]]+@[^@[:space:]]+\.[^@[:space:]]+$'
    AND char_length(regexp_replace(phone, '\D', '', 'g')) BETWEEN 10 AND 15
    AND char_length(btrim(city)) BETWEEN 2 AND 80
    AND loan_amount > 0
    AND loan_amount <= 100000000
    AND char_length(coalesce(goods_needed, '')) <= 300
    AND status = 'new'
  );

DROP POLICY IF EXISTS loan_requests_admin_select ON public.loan_requests;
CREATE POLICY loan_requests_admin_select
  ON public.loan_requests
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE profiles.id = auth.uid() AND profiles.role = 'admin'
    )
  );

DROP POLICY IF EXISTS loan_requests_admin_update ON public.loan_requests;
CREATE POLICY loan_requests_admin_update
  ON public.loan_requests
  FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE profiles.id = auth.uid() AND profiles.role = 'admin'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE profiles.id = auth.uid() AND profiles.role = 'admin'
    )
  );

GRANT INSERT ON public.loan_requests TO anon;
GRANT SELECT, INSERT, UPDATE ON public.loan_requests TO authenticated;
GRANT ALL ON public.loan_requests TO service_role;

NOTIFY pgrst, 'reload schema';
