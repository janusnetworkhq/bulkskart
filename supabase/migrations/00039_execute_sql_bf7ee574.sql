SELECT cron.schedule(
  'daily-morning-unpaid-manufacturer-reminders',
  '0 8 * * *',
  'SELECT public.notify_unpaid_manufacturers()'
);