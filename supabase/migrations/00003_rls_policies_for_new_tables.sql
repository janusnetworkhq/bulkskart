
-- RLS: subscriptions
ALTER TABLE public.subscriptions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Company owner can view own subscription" ON public.subscriptions;
CREATE POLICY "Company owner can view own subscription"
  ON public.subscriptions FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.companies c
      WHERE c.id = subscriptions.company_id AND c.owner_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Company owner can insert subscription" ON public.subscriptions;
CREATE POLICY "Company owner can insert subscription"
  ON public.subscriptions FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.companies c
      WHERE c.id = subscriptions.company_id AND c.owner_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Company owner can update subscription" ON public.subscriptions;
CREATE POLICY "Company owner can update subscription"
  ON public.subscriptions FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM public.companies c
      WHERE c.id = subscriptions.company_id AND c.owner_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Admin can manage all subscriptions" ON public.subscriptions;
CREATE POLICY "Admin can manage all subscriptions"
  ON public.subscriptions FOR ALL
  USING (
    EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
  );

-- RLS: buyer_profiles
ALTER TABLE public.buyer_profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Buyer can view own profile" ON public.buyer_profiles;
CREATE POLICY "Buyer can view own profile"
  ON public.buyer_profiles FOR SELECT
  USING (user_id = auth.uid());

DROP POLICY IF EXISTS "Buyer can insert own profile" ON public.buyer_profiles;
CREATE POLICY "Buyer can insert own profile"
  ON public.buyer_profiles FOR INSERT
  WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS "Buyer can update own profile" ON public.buyer_profiles;
CREATE POLICY "Buyer can update own profile"
  ON public.buyer_profiles FOR UPDATE
  USING (user_id = auth.uid());

-- RLS: notifications
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "User can view own notifications" ON public.notifications;
CREATE POLICY "User can view own notifications"
  ON public.notifications FOR SELECT
  USING (user_id = auth.uid());

DROP POLICY IF EXISTS "User can update own notifications" ON public.notifications;
CREATE POLICY "User can update own notifications"
  ON public.notifications FOR UPDATE
  USING (user_id = auth.uid());

-- RLS: reports
ALTER TABLE public.reports ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Reporter can view own reports" ON public.reports;
CREATE POLICY "Reporter can view own reports"
  ON public.reports FOR SELECT
  USING (reporter_id = auth.uid());

DROP POLICY IF EXISTS "Reporter can insert reports" ON public.reports;
CREATE POLICY "Reporter can insert reports"
  ON public.reports FOR INSERT
  WITH CHECK (reporter_id = auth.uid());

DROP POLICY IF EXISTS "Admin can manage all reports" ON public.reports;
CREATE POLICY "Admin can manage all reports"
  ON public.reports FOR ALL
  USING (
    EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
  );
