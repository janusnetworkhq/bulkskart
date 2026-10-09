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
        'apikey', (SELECT decrypted_secret FROM vault.decrypted_secrets WHERE name = 'publishable_key'),
        'Authorization', 'Bearer ' || (SELECT decrypted_secret FROM vault.decrypted_secrets WHERE name = 'publishable_key')
      ),
      body := jsonb_build_object(
        'action', 'sync_all_posts_and_companies',
        'timestamp', now()
      )
  ) AS request_id;
  $$
);