CREATE TABLE IF NOT EXISTS auction_chats (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  auction_id text NOT NULL,
  sender_name text NOT NULL,
  sender_role text NOT NULL DEFAULT 'buyer',
  message text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);