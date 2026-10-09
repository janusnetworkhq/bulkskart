
-- ── Companies: wallet + response analytics columns ──────────────────
ALTER TABLE companies
  ADD COLUMN IF NOT EXISTS wallet_balance       NUMERIC(12,2) DEFAULT 0,
  ADD COLUMN IF NOT EXISTS withdrawable_balance NUMERIC(12,2) DEFAULT 0,
  ADD COLUMN IF NOT EXISTS total_revenue        NUMERIC(14,2) DEFAULT 0,
  ADD COLUMN IF NOT EXISTS response_rate        NUMERIC(5,2)  DEFAULT 0,
  ADD COLUMN IF NOT EXISTS avg_response_hours   NUMERIC(6,2)  DEFAULT 0,
  ADD COLUMN IF NOT EXISTS is_verified          BOOLEAN       DEFAULT FALSE,
  ADD COLUMN IF NOT EXISTS verified_at          TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS verification_expiry_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS rejection_reason     TEXT,
  ADD COLUMN IF NOT EXISTS profile_completion   INT           DEFAULT 0,
  ADD COLUMN IF NOT EXISTS rating_avg           NUMERIC(3,1)  DEFAULT 0,
  ADD COLUMN IF NOT EXISTS review_count         INT           DEFAULT 0,
  ADD COLUMN IF NOT EXISTS key_products         TEXT[];

-- ── Disputes: resolution columns ───────────────────────────────────
ALTER TABLE disputes
  ADD COLUMN IF NOT EXISTS resolution    TEXT,
  ADD COLUMN IF NOT EXISTS resolved_at   TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS against_user_id UUID REFERENCES auth.users(id);

-- ── Withdrawal requests table ───────────────────────────────────────
CREATE TABLE IF NOT EXISTS withdrawal_requests (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id   UUID NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
  amount       NUMERIC(12,2) NOT NULL,
  status       TEXT NOT NULL DEFAULT 'pending'
               CHECK (status IN ('pending','approved','rejected')),
  notes        TEXT,
  processed_at TIMESTAMPTZ,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE withdrawal_requests ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Company members can manage own withdrawal requests"
  ON withdrawal_requests FOR ALL
  USING (
    company_id IN (
      SELECT id FROM companies WHERE owner_id = auth.uid()
    )
  );

CREATE POLICY "Admins manage all withdrawal requests"
  ON withdrawal_requests FOR ALL
  USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

-- ── Fraud alerts: resolved_at ───────────────────────────────────────
ALTER TABLE fraud_alerts
  ADD COLUMN IF NOT EXISTS resolved_at TIMESTAMPTZ;

-- ── Buyer profiles: verification_status ────────────────────────────
ALTER TABLE buyer_profiles
  ADD COLUMN IF NOT EXISTS verification_status TEXT NOT NULL DEFAULT 'unverified'
    CHECK (verification_status IN ('unverified','pending','verified','rejected'));

-- ── Storage bucket for dispute evidence ────────────────────────────
INSERT INTO storage.buckets (id, name, public)
VALUES ('dispute-evidence', 'dispute-evidence', false)
ON CONFLICT (id) DO NOTHING;

CREATE POLICY "Authenticated users upload dispute evidence"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'dispute-evidence' AND auth.uid() IS NOT NULL
  );

CREATE POLICY "Users access own dispute evidence"
  ON storage.objects FOR SELECT
  USING (
    bucket_id = 'dispute-evidence' AND (
      auth.uid()::text = (storage.foldername(name))[1]
      OR EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
    )
  );
