-- Shareable public buyer profiles. Visitors can read a safe subset by slug.
-- PAN, KYC documents, and rejection notes stay off the public function.

ALTER TABLE public.buyer_profiles
  ADD COLUMN IF NOT EXISTS public_slug text,
  ADD COLUMN IF NOT EXISTS annual_volume text;

CREATE UNIQUE INDEX IF NOT EXISTS buyer_profiles_public_slug_key
  ON public.buyer_profiles (public_slug);

CREATE UNIQUE INDEX IF NOT EXISTS buyer_profiles_user_id_key
  ON public.buyer_profiles (user_id);

CREATE OR REPLACE FUNCTION public.ensure_buyer_public_slug()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = public
AS $$
DECLARE
  base text;
  candidate text;
  n int := 0;
BEGIN
  IF new.company_name IS NULL OR btrim(new.company_name) = '' THEN
    new.company_name := 'Buyer';
  END IF;

  IF new.public_slug IS NOT NULL AND btrim(new.public_slug) <> '' THEN
    new.public_slug := lower(btrim(new.public_slug));
    RETURN new;
  END IF;

  base := lower(regexp_replace(new.company_name, '[^a-zA-Z0-9]+', '-', 'g'));
  base := trim(both '-' from base);
  IF base = '' THEN
    base := 'buyer';
  END IF;
  base := left(base, 48);
  candidate := base || '-' || substr(replace(new.user_id::text, '-', ''), 1, 6);

  WHILE EXISTS (
    SELECT 1 FROM public.buyer_profiles
    WHERE public_slug = candidate
      AND id IS DISTINCT FROM new.id
  ) LOOP
    n := n + 1;
    candidate := base || '-' || substr(replace(new.user_id::text, '-', ''), 1, 6) || '-' || n;
  END LOOP;

  new.public_slug := candidate;
  RETURN new;
END;
$$;

DROP TRIGGER IF EXISTS trg_buyer_public_slug ON public.buyer_profiles;
CREATE TRIGGER trg_buyer_public_slug
  BEFORE INSERT OR UPDATE ON public.buyer_profiles
  FOR EACH ROW
  EXECUTE FUNCTION public.ensure_buyer_public_slug();

INSERT INTO public.buyer_profiles (user_id, company_name, city, state, country, whatsapp_number)
SELECT
  p.id,
  COALESCE(NULLIF(btrim(p.full_name), ''), 'Buyer'),
  p.city,
  p.state,
  COALESCE(NULLIF(btrim(p.country), ''), 'India'),
  p.whatsapp_number
FROM public.profiles p
WHERE p.role = 'buyer'
  AND p.status = 'active'
  AND NOT EXISTS (
    SELECT 1 FROM public.buyer_profiles bp WHERE bp.user_id = p.id
  );

UPDATE public.buyer_profiles
SET updated_at = now()
WHERE public_slug IS NULL;

CREATE OR REPLACE FUNCTION public.buyer_public_profile(p_slug text)
RETURNS TABLE (
  user_id uuid,
  public_slug text,
  company_name text,
  brand_name text,
  business_type text,
  gst_number text,
  annual_volume text,
  address text,
  city text,
  state text,
  country text,
  pincode text,
  verified boolean,
  verification_status text,
  logo_url text,
  banner_url text,
  whatsapp_number text,
  website text,
  year_established integer,
  description text,
  product_categories text[],
  target_products text[],
  trade_type text,
  countries_served text[],
  created_at timestamptz,
  full_name text,
  avatar_url text,
  phone text,
  email text,
  profile_whatsapp text
)
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT
    bp.user_id,
    bp.public_slug,
    bp.company_name,
    bp.brand_name,
    bp.business_type,
    bp.gst_number,
    bp.annual_volume,
    bp.address,
    bp.city,
    bp.state,
    bp.country,
    bp.pincode,
    bp.verified,
    bp.verification_status,
    bp.logo_url,
    bp.banner_url,
    bp.whatsapp_number,
    bp.website,
    bp.year_established,
    bp.description,
    bp.product_categories,
    bp.target_products,
    bp.trade_type,
    bp.countries_served,
    bp.created_at,
    p.full_name,
    p.avatar_url,
    p.phone,
    p.email,
    p.whatsapp_number
  FROM public.buyer_profiles bp
  JOIN public.profiles p ON p.id = bp.user_id
  WHERE bp.public_slug = lower(btrim(p_slug))
    AND p.role = 'buyer'
    AND p.status = 'active';
$$;

REVOKE ALL ON FUNCTION public.buyer_public_profile(text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.buyer_public_profile(text) TO anon, authenticated, service_role;

NOTIFY pgrst, 'reload schema';
