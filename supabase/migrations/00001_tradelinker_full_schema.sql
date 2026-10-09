
-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================
-- ENUMS
-- ============================================================
CREATE TYPE user_role AS ENUM ('buyer', 'supplier', 'admin');
CREATE TYPE account_status AS ENUM ('pending', 'active', 'suspended', 'rejected');
CREATE TYPE subscription_tier AS ENUM ('starter', 'business', 'growth', 'enterprise');
CREATE TYPE subscription_status AS ENUM ('active', 'expired', 'cancelled', 'trial');
CREATE TYPE rfq_status AS ENUM ('active', 'closed', 'expired');
CREATE TYPE quote_status AS ENUM ('pending', 'accepted', 'rejected', 'revised');
CREATE TYPE order_status AS ENUM ('confirmed', 'processing', 'shipped', 'delivered', 'cancelled');
CREATE TYPE verification_status AS ENUM ('unverified', 'pending', 'verified', 'rejected');
CREATE TYPE report_status AS ENUM ('open', 'under_review', 'resolved', 'dismissed');

-- ============================================================
-- PROFILES (extends auth.users)
-- ============================================================
CREATE TABLE profiles (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email text NOT NULL,
  full_name text,
  phone text,
  role user_role NOT NULL DEFAULT 'buyer',
  status account_status NOT NULL DEFAULT 'active',
  avatar_url text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- ============================================================
-- COMPANIES (supplier/manufacturer profiles)
-- ============================================================
CREATE TABLE companies (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  owner_id uuid NOT NULL DEFAULT auth.uid() REFERENCES profiles(id) ON DELETE CASCADE,
  company_name text NOT NULL,
  slug text UNIQUE NOT NULL,
  description text,
  gst_number text,
  iec_number text,
  business_type text,
  website text,
  address text,
  city text,
  state text,
  country text NOT NULL DEFAULT 'India',
  pincode text,
  logo_url text,
  cover_url text,
  verification_status verification_status NOT NULL DEFAULT 'unverified',
  verified_at timestamptz,
  is_featured boolean NOT NULL DEFAULT false,
  total_products integer NOT NULL DEFAULT 0,
  total_quotes_sent integer NOT NULL DEFAULT 0,
  export_destinations text[],
  years_in_business integer,
  employee_count text,
  annual_turnover text,
  gst_doc_url text,
  iec_doc_url text,
  reg_doc_url text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- ============================================================
-- BUYER PROFILES
-- ============================================================
CREATE TABLE buyer_profiles (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id uuid NOT NULL DEFAULT auth.uid() REFERENCES profiles(id) ON DELETE CASCADE,
  company_name text NOT NULL,
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

-- ============================================================
-- CATEGORIES
-- ============================================================
CREATE TABLE categories (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  name text NOT NULL,
  slug text UNIQUE NOT NULL,
  parent_id uuid REFERENCES categories(id),
  icon text,
  image_url text,
  description text,
  sort_order integer NOT NULL DEFAULT 0,
  is_active boolean NOT NULL DEFAULT true,
  product_count integer NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now()
);

-- ============================================================
-- SUBSCRIPTIONS
-- ============================================================
CREATE TABLE subscriptions (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  company_id uuid NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
  tier subscription_tier NOT NULL DEFAULT 'starter',
  status subscription_status NOT NULL DEFAULT 'trial',
  price_inr numeric(10,2),
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

-- ============================================================
-- PRODUCTS
-- ============================================================
CREATE TABLE products (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  company_id uuid NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
  category_id uuid REFERENCES categories(id),
  name text NOT NULL,
  slug text UNIQUE NOT NULL,
  description text,
  specifications text,
  moq integer NOT NULL DEFAULT 1,
  moq_unit text NOT NULL DEFAULT 'pcs',
  price_min numeric(12,2),
  price_max numeric(12,2),
  price_currency text NOT NULL DEFAULT 'INR',
  images text[],
  tags text[],
  export_destinations text[],
  is_active boolean NOT NULL DEFAULT true,
  is_featured boolean NOT NULL DEFAULT false,
  view_count integer NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- ============================================================
-- REQUIREMENTS (RFQ)
-- ============================================================
CREATE TABLE requirements (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  buyer_id uuid NOT NULL DEFAULT auth.uid() REFERENCES profiles(id),
  category_id uuid REFERENCES categories(id),
  title text NOT NULL,
  description text,
  specifications text,
  quantity integer NOT NULL,
  quantity_unit text NOT NULL DEFAULT 'pcs',
  destination_country text,
  destination_city text,
  deadline date,
  budget_min numeric(12,2),
  budget_max numeric(12,2),
  currency text NOT NULL DEFAULT 'INR',
  attachment_url text,
  status rfq_status NOT NULL DEFAULT 'active',
  quote_count integer NOT NULL DEFAULT 0,
  view_count integer NOT NULL DEFAULT 0,
  is_verified_buyer boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  expires_at timestamptz
);

-- ============================================================
-- QUOTATIONS
-- ============================================================
CREATE TABLE quotations (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  requirement_id uuid NOT NULL REFERENCES requirements(id) ON DELETE CASCADE,
  supplier_company_id uuid NOT NULL REFERENCES companies(id),
  supplier_id uuid NOT NULL REFERENCES profiles(id),
  buyer_id uuid NOT NULL REFERENCES profiles(id),
  unit_price numeric(12,2) NOT NULL,
  currency text NOT NULL DEFAULT 'INR',
  moq integer NOT NULL DEFAULT 1,
  moq_unit text NOT NULL DEFAULT 'pcs',
  delivery_days integer,
  payment_terms text,
  validity_days integer NOT NULL DEFAULT 30,
  notes text,
  status quote_status NOT NULL DEFAULT 'pending',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- ============================================================
-- ORDERS
-- ============================================================
CREATE TABLE orders (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_number text UNIQUE NOT NULL,
  quotation_id uuid NOT NULL REFERENCES quotations(id),
  buyer_id uuid NOT NULL REFERENCES profiles(id),
  supplier_company_id uuid NOT NULL REFERENCES companies(id),
  total_amount numeric(12,2) NOT NULL,
  currency text NOT NULL DEFAULT 'INR',
  quantity integer NOT NULL,
  status order_status NOT NULL DEFAULT 'confirmed',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE OR REPLACE FUNCTION generate_order_number()
RETURNS TRIGGER AS $$
BEGIN
  NEW.order_number := 'TL-' || TO_CHAR(now(), 'YYYYMMDD') || '-' || LPAD(FLOOR(RANDOM() * 99999)::TEXT, 5, '0');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_order_number
  BEFORE INSERT ON orders
  FOR EACH ROW EXECUTE FUNCTION generate_order_number();

-- ============================================================
-- CONVERSATIONS & MESSAGES
-- ============================================================
CREATE TABLE conversations (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  requirement_id uuid REFERENCES requirements(id),
  quotation_id uuid REFERENCES quotations(id),
  buyer_id uuid NOT NULL REFERENCES profiles(id),
  supplier_company_id uuid NOT NULL REFERENCES companies(id),
  supplier_id uuid NOT NULL REFERENCES profiles(id),
  last_message text,
  last_message_at timestamptz,
  buyer_unread integer NOT NULL DEFAULT 0,
  supplier_unread integer NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE messages (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  conversation_id uuid NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
  sender_id uuid NOT NULL DEFAULT auth.uid() REFERENCES profiles(id),
  content text NOT NULL,
  attachment_url text,
  is_read boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now()
);

-- ============================================================
-- NOTIFICATIONS
-- ============================================================
CREATE TABLE notifications (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  title text NOT NULL,
  message text NOT NULL,
  type text NOT NULL DEFAULT 'info',
  is_read boolean NOT NULL DEFAULT false,
  link text,
  created_at timestamptz NOT NULL DEFAULT now()
);

-- ============================================================
-- REPORTS
-- ============================================================
CREATE TABLE reports (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  reporter_id uuid NOT NULL DEFAULT auth.uid() REFERENCES profiles(id),
  reported_user_id uuid REFERENCES profiles(id),
  reported_company_id uuid REFERENCES companies(id),
  reported_product_id uuid REFERENCES products(id),
  reason text NOT NULL,
  description text,
  status report_status NOT NULL DEFAULT 'open',
  admin_notes text,
  resolved_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now()
);

-- ============================================================
-- RFQ LEAD TRACKING
-- ============================================================
CREATE TABLE rfq_lead_views (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  supplier_id uuid NOT NULL REFERENCES profiles(id),
  company_id uuid NOT NULL REFERENCES companies(id),
  requirement_id uuid NOT NULL REFERENCES requirements(id),
  viewed_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE(company_id, requirement_id)
);

-- ============================================================
-- STORAGE BUCKETS
-- ============================================================
INSERT INTO storage.buckets (id, name, public) VALUES
  ('business-docs', 'business-docs', false),
  ('product-images', 'product-images', true),
  ('avatars', 'avatars', true),
  ('attachments', 'attachments', false);

-- ============================================================
-- RLS
-- ============================================================
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE companies ENABLE ROW LEVEL SECURITY;
ALTER TABLE buyer_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE requirements ENABLE ROW LEVEL SECURITY;
ALTER TABLE quotations ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE rfq_lead_views ENABLE ROW LEVEL SECURITY;

CREATE OR REPLACE FUNCTION is_admin()
RETURNS boolean LANGUAGE sql SECURITY DEFINER STABLE AS $$
  SELECT EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin');
$$;

CREATE OR REPLACE FUNCTION owns_company(company_uuid uuid)
RETURNS boolean LANGUAGE sql SECURITY DEFINER STABLE AS $$
  SELECT EXISTS (SELECT 1 FROM companies WHERE id = company_uuid AND owner_id = auth.uid());
$$;

-- PROFILES
CREATE POLICY "profiles_select_public" ON profiles FOR SELECT USING (true);
CREATE POLICY "profiles_insert_own" ON profiles FOR INSERT WITH CHECK (id = auth.uid());
CREATE POLICY "profiles_update_own" ON profiles FOR UPDATE USING (id = auth.uid() OR is_admin());
CREATE POLICY "profiles_delete_admin" ON profiles FOR DELETE USING (is_admin());

-- COMPANIES
CREATE POLICY "companies_select_public" ON companies FOR SELECT USING (true);
CREATE POLICY "companies_insert_own" ON companies FOR INSERT WITH CHECK (owner_id = auth.uid());
CREATE POLICY "companies_update_own" ON companies FOR UPDATE USING (owns_company(id) OR is_admin());
CREATE POLICY "companies_delete_own" ON companies FOR DELETE USING (owns_company(id) OR is_admin());

-- BUYER PROFILES
CREATE POLICY "buyer_profiles_select_own" ON buyer_profiles FOR SELECT USING (user_id = auth.uid() OR is_admin());
CREATE POLICY "buyer_profiles_insert_own" ON buyer_profiles FOR INSERT WITH CHECK (user_id = auth.uid());
CREATE POLICY "buyer_profiles_update_own" ON buyer_profiles FOR UPDATE USING (user_id = auth.uid() OR is_admin());
CREATE POLICY "buyer_profiles_delete_admin" ON buyer_profiles FOR DELETE USING (is_admin());

-- CATEGORIES
CREATE POLICY "categories_select_all" ON categories FOR SELECT USING (true);
CREATE POLICY "categories_insert_admin" ON categories FOR INSERT WITH CHECK (is_admin());
CREATE POLICY "categories_update_admin" ON categories FOR UPDATE USING (is_admin());
CREATE POLICY "categories_delete_admin" ON categories FOR DELETE USING (is_admin());

-- SUBSCRIPTIONS
CREATE POLICY "subscriptions_select_own" ON subscriptions FOR SELECT USING (
  EXISTS (SELECT 1 FROM companies WHERE id = company_id AND owner_id = auth.uid()) OR is_admin()
);
CREATE POLICY "subscriptions_insert_own" ON subscriptions FOR INSERT WITH CHECK (
  EXISTS (SELECT 1 FROM companies WHERE id = company_id AND owner_id = auth.uid())
);
CREATE POLICY "subscriptions_update_own" ON subscriptions FOR UPDATE USING (
  EXISTS (SELECT 1 FROM companies WHERE id = company_id AND owner_id = auth.uid()) OR is_admin()
);
CREATE POLICY "subscriptions_delete_admin" ON subscriptions FOR DELETE USING (is_admin());

-- PRODUCTS
CREATE POLICY "products_select_all" ON products FOR SELECT USING (true);
CREATE POLICY "products_insert_own" ON products FOR INSERT WITH CHECK (
  EXISTS (SELECT 1 FROM companies WHERE id = company_id AND owner_id = auth.uid())
);
CREATE POLICY "products_update_own" ON products FOR UPDATE USING (
  EXISTS (SELECT 1 FROM companies WHERE id = company_id AND owner_id = auth.uid()) OR is_admin()
);
CREATE POLICY "products_delete_own" ON products FOR DELETE USING (
  EXISTS (SELECT 1 FROM companies WHERE id = company_id AND owner_id = auth.uid()) OR is_admin()
);

-- REQUIREMENTS
CREATE POLICY "requirements_select_all" ON requirements FOR SELECT USING (true);
CREATE POLICY "requirements_insert_buyer" ON requirements FOR INSERT WITH CHECK (buyer_id = auth.uid());
CREATE POLICY "requirements_update_buyer" ON requirements FOR UPDATE USING (buyer_id = auth.uid() OR is_admin());
CREATE POLICY "requirements_delete_buyer" ON requirements FOR DELETE USING (buyer_id = auth.uid() OR is_admin());

-- QUOTATIONS
CREATE POLICY "quotations_select_parties" ON quotations FOR SELECT USING (
  buyer_id = auth.uid() OR supplier_id = auth.uid() OR is_admin()
);
CREATE POLICY "quotations_insert_supplier" ON quotations FOR INSERT WITH CHECK (supplier_id = auth.uid());
CREATE POLICY "quotations_update_supplier" ON quotations FOR UPDATE USING (supplier_id = auth.uid() OR buyer_id = auth.uid() OR is_admin());
CREATE POLICY "quotations_delete_admin" ON quotations FOR DELETE USING (is_admin());

-- ORDERS
CREATE POLICY "orders_select_parties" ON orders FOR SELECT USING (
  buyer_id = auth.uid() OR
  EXISTS (SELECT 1 FROM companies WHERE id = supplier_company_id AND owner_id = auth.uid()) OR
  is_admin()
);
CREATE POLICY "orders_insert_buyer" ON orders FOR INSERT WITH CHECK (buyer_id = auth.uid());
CREATE POLICY "orders_update_parties" ON orders FOR UPDATE USING (
  buyer_id = auth.uid() OR
  EXISTS (SELECT 1 FROM companies WHERE id = supplier_company_id AND owner_id = auth.uid()) OR
  is_admin()
);
CREATE POLICY "orders_delete_admin" ON orders FOR DELETE USING (is_admin());

-- CONVERSATIONS
CREATE POLICY "conversations_select_parties" ON conversations FOR SELECT USING (
  buyer_id = auth.uid() OR supplier_id = auth.uid() OR is_admin()
);
CREATE POLICY "conversations_insert_parties" ON conversations FOR INSERT WITH CHECK (
  buyer_id = auth.uid() OR supplier_id = auth.uid()
);
CREATE POLICY "conversations_update_parties" ON conversations FOR UPDATE USING (
  buyer_id = auth.uid() OR supplier_id = auth.uid() OR is_admin()
);
CREATE POLICY "conversations_delete_admin" ON conversations FOR DELETE USING (is_admin());

-- MESSAGES
CREATE POLICY "messages_select_parties" ON messages FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM conversations c
    WHERE c.id = conversation_id AND (c.buyer_id = auth.uid() OR c.supplier_id = auth.uid())
  ) OR is_admin()
);
CREATE POLICY "messages_insert_parties" ON messages FOR INSERT WITH CHECK (sender_id = auth.uid());
CREATE POLICY "messages_update_sender" ON messages FOR UPDATE USING (sender_id = auth.uid() OR is_admin());
CREATE POLICY "messages_delete_admin" ON messages FOR DELETE USING (is_admin());

-- NOTIFICATIONS
CREATE POLICY "notifications_select_own" ON notifications FOR SELECT USING (user_id = auth.uid() OR is_admin());
CREATE POLICY "notifications_insert_system" ON notifications FOR INSERT WITH CHECK (is_admin() OR user_id = auth.uid());
CREATE POLICY "notifications_update_own" ON notifications FOR UPDATE USING (user_id = auth.uid() OR is_admin());
CREATE POLICY "notifications_delete_own" ON notifications FOR DELETE USING (user_id = auth.uid() OR is_admin());

-- REPORTS
CREATE POLICY "reports_select_own_admin" ON reports FOR SELECT USING (reporter_id = auth.uid() OR is_admin());
CREATE POLICY "reports_insert_auth" ON reports FOR INSERT WITH CHECK (reporter_id = auth.uid());
CREATE POLICY "reports_update_admin" ON reports FOR UPDATE USING (is_admin());
CREATE POLICY "reports_delete_admin" ON reports FOR DELETE USING (is_admin());

-- RFQ LEAD VIEWS
CREATE POLICY "rfq_views_select_own" ON rfq_lead_views FOR SELECT USING (supplier_id = auth.uid() OR is_admin());
CREATE POLICY "rfq_views_insert_own" ON rfq_lead_views FOR INSERT WITH CHECK (supplier_id = auth.uid());
CREATE POLICY "rfq_views_update_admin" ON rfq_lead_views FOR UPDATE USING (is_admin());
CREATE POLICY "rfq_views_delete_admin" ON rfq_lead_views FOR DELETE USING (is_admin());

-- STORAGE POLICIES
CREATE POLICY "business_docs_owner" ON storage.objects FOR ALL USING (
  bucket_id = 'business-docs' AND auth.uid()::text = (storage.foldername(name))[1]
);
CREATE POLICY "product_images_public_read" ON storage.objects FOR SELECT USING (bucket_id = 'product-images');
CREATE POLICY "product_images_owner_write" ON storage.objects FOR INSERT WITH CHECK (
  bucket_id = 'product-images' AND auth.uid()::text = (storage.foldername(name))[1]
);
CREATE POLICY "avatars_public_read" ON storage.objects FOR SELECT USING (bucket_id = 'avatars');
CREATE POLICY "avatars_owner_write" ON storage.objects FOR INSERT WITH CHECK (
  bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]
);

-- ============================================================
-- SEED CATEGORIES
-- ============================================================
INSERT INTO categories (name, slug, icon, sort_order) VALUES
  ('Textiles & Apparel', 'textiles-apparel', 'shirt', 1),
  ('Machinery & Industrial Equipment', 'machinery-industrial', 'settings', 2),
  ('Agriculture & Food Products', 'agriculture-food', 'leaf', 3),
  ('Chemicals & Raw Materials', 'chemicals-raw-materials', 'flask-conical', 4),
  ('Electronics & Electricals', 'electronics-electricals', 'cpu', 5),
  ('Construction & Building Materials', 'construction-building', 'building-2', 6),
  ('Furniture & Home Decor', 'furniture-home', 'sofa', 7),
  ('Auto Parts & Vehicles', 'auto-parts-vehicles', 'car', 8),
  ('Pharmaceuticals & Healthcare', 'pharma-healthcare', 'pill', 9),
  ('Plastics & Rubber', 'plastics-rubber', 'circle-dot', 10),
  ('Gems & Jewellery', 'gems-jewellery', 'gem', 11),
  ('Handicrafts & Gifts', 'handicrafts-gifts', 'gift', 12);
