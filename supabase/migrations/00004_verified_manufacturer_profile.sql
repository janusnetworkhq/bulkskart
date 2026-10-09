
-- 1. Extend companies table with profile fields
ALTER TABLE public.companies
  ADD COLUMN IF NOT EXISTS logo_url text,
  ADD COLUMN IF NOT EXISTS banner_url text,
  ADD COLUMN IF NOT EXISTS description text,
  ADD COLUMN IF NOT EXISTS tagline text,
  ADD COLUMN IF NOT EXISTS year_established integer,
  ADD COLUMN IF NOT EXISTS employee_count_range text,
  ADD COLUMN IF NOT EXISTS annual_turnover_range text,
  ADD COLUMN IF NOT EXISTS export_destinations text[] DEFAULT '{}',
  ADD COLUMN IF NOT EXISTS payment_terms text[] DEFAULT '{}',
  ADD COLUMN IF NOT EXISTS production_capacity text,
  ADD COLUMN IF NOT EXISTS is_verified boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS verified_at timestamptz,
  ADD COLUMN IF NOT EXISTS verification_notes text,
  ADD COLUMN IF NOT EXISTS rating_avg numeric(3,2) DEFAULT 0,
  ADD COLUMN IF NOT EXISTS review_count integer DEFAULT 0,
  ADD COLUMN IF NOT EXISTS key_products text[] DEFAULT '{}',
  ADD COLUMN IF NOT EXISTS moq_policy text,
  ADD COLUMN IF NOT EXISTS packaging_details text,
  ADD COLUMN IF NOT EXISTS profile_completion integer DEFAULT 0;

-- 2. company_certifications table
CREATE TABLE IF NOT EXISTS public.company_certifications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id uuid NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  cert_type text NOT NULL CHECK (cert_type IN ('gst','iec','company_reg','iso','other')),
  cert_name text NOT NULL DEFAULT '',
  cert_number text,
  cert_file_url text,
  is_verified boolean NOT NULL DEFAULT false,
  verified_at timestamptz,
  pending_review boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- 3. company_reviews table
CREATE TABLE IF NOT EXISTS public.company_reviews (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id uuid NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  reviewer_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  rating integer NOT NULL CHECK (rating BETWEEN 1 AND 5),
  review_text text,
  order_id uuid,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE(company_id, reviewer_id)
);

-- 4. RLS: company_certifications
ALTER TABLE public.company_certifications ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public can view verified certs" ON public.company_certifications;
CREATE POLICY "Public can view verified certs"
  ON public.company_certifications FOR SELECT
  USING (true);

DROP POLICY IF EXISTS "Owner can manage own certs" ON public.company_certifications;
CREATE POLICY "Owner can manage own certs"
  ON public.company_certifications FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.companies c
      WHERE c.id = company_certifications.company_id AND c.owner_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Admin can manage all certs" ON public.company_certifications;
CREATE POLICY "Admin can manage all certs"
  ON public.company_certifications FOR ALL
  USING (
    EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
  );

-- 5. RLS: company_reviews
ALTER TABLE public.company_reviews ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public can view reviews" ON public.company_reviews;
CREATE POLICY "Public can view reviews"
  ON public.company_reviews FOR SELECT
  USING (true);

DROP POLICY IF EXISTS "Authenticated buyer can insert review" ON public.company_reviews;
CREATE POLICY "Authenticated buyer can insert review"
  ON public.company_reviews FOR INSERT
  WITH CHECK (reviewer_id = auth.uid());

DROP POLICY IF EXISTS "Reviewer can update own review" ON public.company_reviews;
CREATE POLICY "Reviewer can update own review"
  ON public.company_reviews FOR UPDATE
  USING (reviewer_id = auth.uid());

-- 6. Storage bucket for company assets
INSERT INTO storage.buckets (id, name, public)
VALUES ('company-assets', 'company-assets', true)
ON CONFLICT (id) DO NOTHING;

DROP POLICY IF EXISTS "Company assets are publicly readable" ON storage.objects;
CREATE POLICY "Company assets are publicly readable"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'company-assets');

DROP POLICY IF EXISTS "Authenticated users can upload company assets" ON storage.objects;
CREATE POLICY "Authenticated users can upload company assets"
  ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'company-assets' AND auth.role() = 'authenticated');

DROP POLICY IF EXISTS "Owner can update company assets" ON storage.objects;
CREATE POLICY "Owner can update company assets"
  ON storage.objects FOR UPDATE
  USING (bucket_id = 'company-assets' AND auth.role() = 'authenticated');
