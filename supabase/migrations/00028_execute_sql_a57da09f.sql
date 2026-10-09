CREATE OR REPLACE FUNCTION trigger_rfq_matching_on_new_req() RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  IF NEW.status <> 'active' THEN
    RETURN NEW;
  END IF;

  PERFORM net.http_post(
    url     := 'https://ewnftvshvsrhawluloty.supabase.co/functions/v1/run-rfq-matching',
    body    := jsonb_build_object('rfq_id', NEW.id),
    params  := '{}'::jsonb,
    headers := jsonb_build_object(
      'Content-Type',  'application/json',
      'Authorization', 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV3bmZ0dnNodnNyaGF3bHVsb3R5Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4OTU1MTI2NywiZXhwIjoyMTA1MTI3MjY3fQ.DWM5SqN_RGEHj0SifkgKv5g4J5MYFX9ioaxN58fPDMw'
    ),
    timeout_milliseconds := 5000
  );
  RETURN NEW;
EXCEPTION WHEN OTHERS THEN
  -- Never block the INSERT if the EF call fails
  RETURN NEW;
END;
$$; CREATE OR REPLACE FUNCTION trigger_match_on_new_manufacturer() RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  PERFORM net.http_post(
    url     := 'https://ewnftvshvsrhawluloty.supabase.co/functions/v1/match-new-manufacturer',
    body    := jsonb_build_object('company_id', NEW.id),
    params  := '{}'::jsonb,
    headers := jsonb_build_object(
      'Content-Type',  'application/json',
      'Authorization', 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV3bmZ0dnNodnNyaGF3bHVsb3R5Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4OTU1MTI2NywiZXhwIjoyMTA1MTI3MjY3fQ.DWM5SqN_RGEHj0SifkgKv5g4J5MYFX9ioaxN58fPDMw'
    ),
    timeout_milliseconds := 5000
  );
  RETURN NEW;
EXCEPTION WHEN OTHERS THEN
  RETURN NEW;
END;
$$;