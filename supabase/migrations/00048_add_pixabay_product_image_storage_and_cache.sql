ALTER TABLE products 
  ADD COLUMN IF NOT EXISTS has_seller_images BOOLEAN DEFAULT false,
  ADD COLUMN IF NOT EXISTS is_representative_image BOOLEAN DEFAULT false,
  ADD COLUMN IF NOT EXISTS representative_storage_url TEXT,
  ADD COLUMN IF NOT EXISTS pixabay_search_query TEXT;

CREATE TABLE IF NOT EXISTS pixabay_search_cache (
  query_hash TEXT PRIMARY KEY,
  query TEXT NOT NULL,
  results JSONB NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  expires_at TIMESTAMPTZ DEFAULT (NOW() + INTERVAL '24 hours')
);

ALTER TABLE pixabay_search_cache ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow anon and auth read cache" ON pixabay_search_cache
  FOR SELECT USING (true);

CREATE POLICY "Allow service role and authenticated insert cache" ON pixabay_search_cache
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Allow update cache" ON pixabay_search_cache
  FOR UPDATE USING (true);
