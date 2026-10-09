-- Enable Realtime publication for the requirements table
-- so LiveRequirementsFeed can receive instant INSERT events via Supabase channel
ALTER PUBLICATION supabase_realtime ADD TABLE requirements;