ALTER TABLE companies 
  ADD COLUMN IF NOT EXISTS brand_name text,
  ADD COLUMN IF NOT EXISTS registration_number text,
  ADD COLUMN IF NOT EXISTS whatsapp_number text,
  ADD COLUMN IF NOT EXISTS shipping_capabilities text,
  ADD COLUMN IF NOT EXISTS trade_type text,
  ADD COLUMN IF NOT EXISTS product_categories text[],
  ADD COLUMN IF NOT EXISTS onboarding_step integer DEFAULT 1,
  ADD COLUMN IF NOT EXISTS onboarding_completed boolean DEFAULT false;

ALTER TABLE buyer_profiles
  ADD COLUMN IF NOT EXISTS brand_name text,
  ADD COLUMN IF NOT EXISTS whatsapp_number text,
  ADD COLUMN IF NOT EXISTS website text,
  ADD COLUMN IF NOT EXISTS year_established integer,
  ADD COLUMN IF NOT EXISTS description text,
  ADD COLUMN IF NOT EXISTS product_categories text[],
  ADD COLUMN IF NOT EXISTS target_products text[],
  ADD COLUMN IF NOT EXISTS moq_requirement text,
  ADD COLUMN IF NOT EXISTS trade_type text,
  ADD COLUMN IF NOT EXISTS countries_served text[],
  ADD COLUMN IF NOT EXISTS payment_terms text[],
  ADD COLUMN IF NOT EXISTS shipping_capabilities text,
  ADD COLUMN IF NOT EXISTS onboarding_step integer DEFAULT 1,
  ADD COLUMN IF NOT EXISTS onboarding_completed boolean DEFAULT false,
  ADD COLUMN IF NOT EXISTS profile_completion integer DEFAULT 20;

ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS whatsapp_number text,
  ADD COLUMN IF NOT EXISTS country text,
  ADD COLUMN IF NOT EXISTS state text,
  ADD COLUMN IF NOT EXISTS city text,
  ADD COLUMN IF NOT EXISTS onboarding_completed boolean DEFAULT false;
