
-- ============================================================
-- subscription_orders: tracks Stripe payment for plan purchases
-- ============================================================
CREATE TABLE IF NOT EXISTS public.subscription_orders (
  id                       uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  company_id               uuid NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  user_id                  uuid NOT NULL REFERENCES auth.users(id),
  plan_tier                text NOT NULL CHECK (plan_tier IN ('starter','business','growth','enterprise')),
  plan_label               text NOT NULL,
  price_inr                numeric(10,2) NOT NULL,
  billing_cycle            text NOT NULL DEFAULT 'monthly',
  stripe_session_id        text UNIQUE,
  stripe_payment_intent_id text,
  customer_email           text,
  status                   text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending','completed','cancelled','failed')),
  completed_at             timestamptz,
  created_at               timestamptz NOT NULL DEFAULT now(),
  updated_at               timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX idx_sub_orders_company   ON public.subscription_orders(company_id);
CREATE INDEX idx_sub_orders_stripe    ON public.subscription_orders(stripe_session_id);
CREATE INDEX idx_sub_orders_status    ON public.subscription_orders(status);
CREATE INDEX idx_sub_orders_user      ON public.subscription_orders(user_id);

-- RLS
ALTER TABLE public.subscription_orders ENABLE ROW LEVEL SECURITY;

-- Users can view their own orders
CREATE POLICY "Users can view own subscription orders"
  ON public.subscription_orders FOR SELECT
  USING (auth.uid() = user_id);

-- Service role manages all
CREATE POLICY "Service role can manage subscription orders"
  ON public.subscription_orders FOR ALL
  USING (auth.jwt()->>'role' = 'service_role')
  WITH CHECK (auth.jwt()->>'role' = 'service_role');
