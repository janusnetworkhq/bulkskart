-- 1. Alter companies & requirements tables to ensure photo fields exist
ALTER TABLE companies ADD COLUMN IF NOT EXISTS gallery_images text[] DEFAULT '{}';
ALTER TABLE companies ADD COLUMN IF NOT EXISTS is_representative_image boolean DEFAULT false;

ALTER TABLE requirements ADD COLUMN IF NOT EXISTS images text[] DEFAULT '{}';
ALTER TABLE requirements ADD COLUMN IF NOT EXISTS representative_storage_url text;

-- 2. Create image_sync_logs table
CREATE TABLE IF NOT EXISTS image_sync_logs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  entity_type text NOT NULL, -- 'product', 'requirement', 'company'
  entity_id uuid NOT NULL,
  entity_name text,
  pixabay_asset_id text,
  storage_url text NOT NULL,
  search_query text,
  refresh_cycle bigint DEFAULT 1,
  status text NOT NULL DEFAULT 'new_added',
  created_at timestamptz NOT NULL DEFAULT now()
);

-- Index for speedy querying by entity and time
CREATE INDEX IF NOT EXISTS idx_image_sync_logs_entity ON image_sync_logs(entity_type, entity_id);
CREATE INDEX IF NOT EXISTS idx_image_sync_logs_created_at ON image_sync_logs(created_at DESC);

-- Enable RLS
ALTER TABLE image_sync_logs ENABLE ROW LEVEL SECURITY;

-- Allow anyone to read sync logs (audit & live refresh)
CREATE POLICY "Allow read on image_sync_logs"
  ON image_sync_logs FOR SELECT
  USING (true);

-- Allow backend / authenticated insert
CREATE POLICY "Allow insert on image_sync_logs"
  ON image_sync_logs FOR INSERT
  WITH CHECK (true);

-- 3. Register or replace pg_cron 1-minute schedule for auto photo refresh
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM cron.job WHERE jobname = 'sync-photos-every-minute') THEN
    PERFORM cron.unschedule('sync-photos-every-minute');
  END IF;
END $$;

SELECT cron.schedule(
  'sync-photos-every-minute',
  '* * * * *',
  $$
  SELECT net.http_post(
      url := (SELECT decrypted_secret FROM vault.decrypted_secrets WHERE name = 'project_url') || '/functions/v1/pixabay-product-image',
      headers := jsonb_build_object(
        'Content-Type', 'application/json',
        'apikey', (SELECT decrypted_secret FROM vault.decrypted_secrets WHERE name = 'publishable_key')
      ),
      body := jsonb_build_object(
        'action', 'sync_all_posts_and_companies',
        'timestamp', now()
      )
  ) AS request_id;
  $$
);
