-- Add logo_url and banner_url to buyer_profiles if not exist
ALTER TABLE IF EXISTS buyer_profiles
ADD COLUMN IF NOT EXISTS logo_url text,
ADD COLUMN IF NOT EXISTS banner_url text;

-- Add avatar_url to profiles if not exist
ALTER TABLE IF EXISTS profiles
ADD COLUMN IF NOT EXISTS avatar_url text;
