-- Create storage buckets for product images, company assets, avatars, and verification docs
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES
  ('product-images', 'product-images', true, 10485760, ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/gif', 'image/avif']),
  ('company-assets', 'company-assets', true, 10485760, ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/gif', 'image/avif']),
  ('avatars', 'avatars', true, 5242880, ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/gif', 'image/avif']),
  ('verification-docs', 'verification-docs', true, 10485760, ARRAY['image/jpeg', 'image/png', 'image/webp', 'application/pdf'])
ON CONFLICT (id) DO UPDATE SET
  public = EXCLUDED.public,
  file_size_limit = EXCLUDED.file_size_limit,
  allowed_mime_types = EXCLUDED.allowed_mime_types;

-- Storage policies for public buckets
DROP POLICY IF EXISTS "Public read access for product-images" ON storage.objects;
CREATE POLICY "Public read access for product-images" ON storage.objects
  FOR SELECT USING (bucket_id = 'product-images');

DROP POLICY IF EXISTS "Public insert access for product-images" ON storage.objects;
CREATE POLICY "Public insert access for product-images" ON storage.objects
  FOR INSERT WITH CHECK (bucket_id = 'product-images');

DROP POLICY IF EXISTS "Public update access for product-images" ON storage.objects;
CREATE POLICY "Public update access for product-images" ON storage.objects
  FOR UPDATE USING (bucket_id = 'product-images');

DROP POLICY IF EXISTS "Public delete access for product-images" ON storage.objects;
CREATE POLICY "Public delete access for product-images" ON storage.objects
  FOR DELETE USING (bucket_id = 'product-images');

-- company-assets
DROP POLICY IF EXISTS "Public read access for company-assets" ON storage.objects;
CREATE POLICY "Public read access for company-assets" ON storage.objects
  FOR SELECT USING (bucket_id = 'company-assets');

DROP POLICY IF EXISTS "Public insert access for company-assets" ON storage.objects;
CREATE POLICY "Public insert access for company-assets" ON storage.objects
  FOR INSERT WITH CHECK (bucket_id = 'company-assets');

DROP POLICY IF EXISTS "Public update access for company-assets" ON storage.objects;
CREATE POLICY "Public update access for company-assets" ON storage.objects
  FOR UPDATE USING (bucket_id = 'company-assets');

-- avatars
DROP POLICY IF EXISTS "Public read access for avatars" ON storage.objects;
CREATE POLICY "Public read access for avatars" ON storage.objects
  FOR SELECT USING (bucket_id = 'avatars');

DROP POLICY IF EXISTS "Public insert access for avatars" ON storage.objects;
CREATE POLICY "Public insert access for avatars" ON storage.objects
  FOR INSERT WITH CHECK (bucket_id = 'avatars');

DROP POLICY IF EXISTS "Public update access for avatars" ON storage.objects;
CREATE POLICY "Public update access for avatars" ON storage.objects
  FOR UPDATE USING (bucket_id = 'avatars');

-- verification-docs
DROP POLICY IF EXISTS "Public read access for verification-docs" ON storage.objects;
CREATE POLICY "Public read access for verification-docs" ON storage.objects
  FOR SELECT USING (bucket_id = 'verification-docs');

DROP POLICY IF EXISTS "Public insert access for verification-docs" ON storage.objects;
CREATE POLICY "Public insert access for verification-docs" ON storage.objects
  FOR INSERT WITH CHECK (bucket_id = 'verification-docs');
