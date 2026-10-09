
-- subscriptions table
CREATE TABLE IF NOT EXISTS public.subscriptions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id uuid NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  tier text NOT NULL DEFAULT 'starter' CHECK (tier IN ('starter','business','growth','enterprise')),
  status text NOT NULL DEFAULT 'active' CHECK (status IN ('active','expired','cancelled','trial')),
  price_inr numeric,
  billing_cycle text NOT NULL DEFAULT 'monthly',
  starts_at timestamptz NOT NULL DEFAULT now(),
  ends_at timestamptz,
  stripe_subscription_id text,
  stripe_customer_id text,
  max_products integer NOT NULL DEFAULT 5,
  max_rfq_leads integer NOT NULL DEFAULT 10,
  used_rfq_leads integer NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- buyer_profiles table
CREATE TABLE IF NOT EXISTS public.buyer_profiles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  company_name text NOT NULL DEFAULT '',
  business_type text,
  gst_number text,
  address text,
  city text,
  state text,
  country text NOT NULL DEFAULT 'India',
  pincode text,
  verified boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- notifications table if missing
CREATE TABLE IF NOT EXISTS public.notifications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  title text NOT NULL DEFAULT '',
  message text NOT NULL DEFAULT '',
  type text NOT NULL DEFAULT 'info',
  is_read boolean NOT NULL DEFAULT false,
  link text,
  created_at timestamptz NOT NULL DEFAULT now()
);

-- reports table if missing
CREATE TABLE IF NOT EXISTS public.reports (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  reporter_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  reported_user_id uuid REFERENCES public.profiles(id),
  reported_company_id uuid REFERENCES public.companies(id),
  reported_product_id uuid REFERENCES public.products(id),
  reason text NOT NULL,
  description text,
  status text NOT NULL DEFAULT 'open' CHECK (status IN ('open','under_review','resolved','dismissed')),
  admin_notes text,
  resolved_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now()
);
