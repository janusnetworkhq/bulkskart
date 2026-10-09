
-- rfq_matches: stores AI match results per RFQ per supplier
CREATE TABLE IF NOT EXISTS public.rfq_matches (
  id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  rfq_id            uuid NOT NULL REFERENCES public.requirements(id) ON DELETE CASCADE,
  company_id        uuid NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  match_score       integer NOT NULL CHECK (match_score BETWEEN 0 AND 100),
  score_category    integer NOT NULL DEFAULT 0,
  score_location    integer NOT NULL DEFAULT 0,
  score_moq         integer NOT NULL DEFAULT 0,
  score_capacity    integer NOT NULL DEFAULT 0,
  score_rating      integer NOT NULL DEFAULT 0,
  notified_at       timestamptz,
  response_status   text NOT NULL DEFAULT 'pending' CHECK (response_status IN ('pending','quoted','dismissed','expired')),
  created_at        timestamptz NOT NULL DEFAULT now(),
  UNIQUE(rfq_id, company_id)
);

-- Indexes for common query patterns
CREATE INDEX IF NOT EXISTS rfq_matches_rfq_id_idx     ON public.rfq_matches(rfq_id);
CREATE INDEX IF NOT EXISTS rfq_matches_company_id_idx ON public.rfq_matches(company_id);
CREATE INDEX IF NOT EXISTS rfq_matches_score_idx      ON public.rfq_matches(match_score DESC);

-- RLS
ALTER TABLE public.rfq_matches ENABLE ROW LEVEL SECURITY;

-- Buyers can read matches for their own RFQs
CREATE POLICY "buyers_read_own_rfq_matches"
  ON public.rfq_matches FOR SELECT
  USING (
    rfq_id IN (
      SELECT id FROM public.requirements WHERE buyer_id = auth.uid()
    )
  );

-- Suppliers can read matches for their own company
CREATE POLICY "suppliers_read_own_matches"
  ON public.rfq_matches FOR SELECT
  USING (
    company_id IN (
      SELECT id FROM public.companies WHERE owner_id = auth.uid()
    )
  );

-- Admins can read all
CREATE POLICY "admins_read_all_matches"
  ON public.rfq_matches FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- Service role (edge functions) can insert/update
CREATE POLICY "service_insert_matches"
  ON public.rfq_matches FOR INSERT
  WITH CHECK (true);

CREATE POLICY "service_update_matches"
  ON public.rfq_matches FOR UPDATE
  USING (true);
