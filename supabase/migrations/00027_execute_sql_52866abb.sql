CREATE OR REPLACE FUNCTION trigger_rfq_matching_on_new_req() RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  _service_key text := 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV3bmZ0dnNodnNyaGF3bHVsb3R5Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4OTU1MTI2NywiZXhwIjoyMTA1MTI3MjY3fQ.service_role_placeholder';
BEGIN
  IF NEW.status <> 'active' THEN
    RETURN NEW;
  END IF;

  PERFORM net.http_post(
    url     := 'https://ewnftvshvsrhawluloty.supabase.co/functions/v1/run-rfq-matching',
    body    := jsonb_build_object('rfq_id', NEW.id),
    params  := '{}'::jsonb,
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer ' || _service_key
    )
  );
  RETURN NEW;
EXCEPTION WHEN OTHERS THEN
  RETURN NEW;
END;
$$;