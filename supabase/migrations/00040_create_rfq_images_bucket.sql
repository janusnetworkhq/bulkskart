INSERT INTO storage.buckets (id, name, public)
VALUES ('rfq-images', 'rfq-images', true)
ON CONFLICT (id) DO UPDATE SET public = true;

-- Ensure public select policies for product-images, company-assets, and rfq-images
DROP POLICY IF EXISTS "Public can view rfq images" ON storage.objects;
CREATE POLICY "Public can view rfq images"
ON storage.objects FOR SELECT
USING (bucket_id IN ('product-images', 'company-assets', 'rfq-images', 'attachments', 'avatars'));

DROP POLICY IF EXISTS "Authenticated and anon users can upload rfq images" ON storage.objects;
CREATE POLICY "Authenticated and anon users can upload rfq images"
ON storage.objects FOR INSERT
WITH CHECK (bucket_id IN ('product-images', 'company-assets', 'rfq-images', 'attachments', 'avatars'));

DROP POLICY IF EXISTS "Users can update and delete their uploaded objects" ON storage.objects;
CREATE POLICY "Users can update and delete their uploaded objects"
ON storage.objects FOR UPDATE
USING (bucket_id IN ('product-images', 'company-assets', 'rfq-images', 'attachments', 'avatars'));
