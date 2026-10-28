-- ============================================================
-- SECTION: SCHEMA
-- ============================================================

--
-- PostgreSQL database dump
--


-- Dumped from database version 17.6
-- Dumped by pg_dump version 17.6

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: pg_cron; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "pg_cron" WITH SCHEMA "pg_catalog";


--
-- Name: EXTENSION "pg_cron"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "pg_cron" IS 'Job scheduler for PostgreSQL';


--
-- Name: pg_net; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "pg_net" WITH SCHEMA "extensions";


--
-- Name: EXTENSION "pg_net"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "pg_net" IS 'Async HTTP';


--
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA IF NOT EXISTS "public";


--
-- Name: SCHEMA "public"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA "public" IS 'standard public schema';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";


--
-- Name: EXTENSION "pgcrypto"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "pgcrypto" IS 'cryptographic functions';


--
-- Name: supabase_vault; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";


--
-- Name: EXTENSION "supabase_vault"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "supabase_vault" IS 'Supabase Vault Extension';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: account_status; Type: TYPE; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_type t
    JOIN pg_namespace n ON n.oid = t.typnamespace
    WHERE n.nspname = 'public'
      AND t.typname = 'account_status'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE TYPE "public"."account_status" AS ENUM (
    'pending',
    'active',
    'suspended',
    'rejected'
);
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: dispute_reason; Type: TYPE; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_type t
    JOIN pg_namespace n ON n.oid = t.typnamespace
    WHERE n.nspname = 'public'
      AND t.typname = 'dispute_reason'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE TYPE "public"."dispute_reason" AS ENUM (
    'quality_issue',
    'delivery_delay',
    'payment_issue',
    'communication_issue',
    'other'
);
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: dispute_status; Type: TYPE; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_type t
    JOIN pg_namespace n ON n.oid = t.typnamespace
    WHERE n.nspname = 'public'
      AND t.typname = 'dispute_status'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE TYPE "public"."dispute_status" AS ENUM (
    'open',
    'under_review',
    'resolved',
    'closed'
);
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: fraud_severity; Type: TYPE; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_type t
    JOIN pg_namespace n ON n.oid = t.typnamespace
    WHERE n.nspname = 'public'
      AND t.typname = 'fraud_severity'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE TYPE "public"."fraud_severity" AS ENUM (
    'low',
    'medium',
    'high'
);
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: order_milestone; Type: TYPE; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_type t
    JOIN pg_namespace n ON n.oid = t.typnamespace
    WHERE n.nspname = 'public'
      AND t.typname = 'order_milestone'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE TYPE "public"."order_milestone" AS ENUM (
    'rfq_created',
    'quote_received',
    'quote_accepted',
    'order_processing',
    'production',
    'ready_for_dispatch',
    'dispatched',
    'delivered',
    'completed',
    'cancelled'
);
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: order_status; Type: TYPE; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_type t
    JOIN pg_namespace n ON n.oid = t.typnamespace
    WHERE n.nspname = 'public'
      AND t.typname = 'order_status'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE TYPE "public"."order_status" AS ENUM (
    'confirmed',
    'processing',
    'shipped',
    'delivered',
    'cancelled'
);
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: quote_status; Type: TYPE; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_type t
    JOIN pg_namespace n ON n.oid = t.typnamespace
    WHERE n.nspname = 'public'
      AND t.typname = 'quote_status'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE TYPE "public"."quote_status" AS ENUM (
    'pending',
    'accepted',
    'rejected',
    'revised'
);
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: report_status; Type: TYPE; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_type t
    JOIN pg_namespace n ON n.oid = t.typnamespace
    WHERE n.nspname = 'public'
      AND t.typname = 'report_status'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE TYPE "public"."report_status" AS ENUM (
    'open',
    'under_review',
    'resolved',
    'dismissed'
);
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: rfq_status; Type: TYPE; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_type t
    JOIN pg_namespace n ON n.oid = t.typnamespace
    WHERE n.nspname = 'public'
      AND t.typname = 'rfq_status'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE TYPE "public"."rfq_status" AS ENUM (
    'active',
    'closed',
    'expired'
);
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: subscription_status; Type: TYPE; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_type t
    JOIN pg_namespace n ON n.oid = t.typnamespace
    WHERE n.nspname = 'public'
      AND t.typname = 'subscription_status'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE TYPE "public"."subscription_status" AS ENUM (
    'active',
    'expired',
    'cancelled',
    'trial'
);
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: subscription_tier; Type: TYPE; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_type t
    JOIN pg_namespace n ON n.oid = t.typnamespace
    WHERE n.nspname = 'public'
      AND t.typname = 'subscription_tier'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE TYPE "public"."subscription_tier" AS ENUM (
    'starter',
    'business',
    'growth',
    'enterprise'
);
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: user_role; Type: TYPE; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_type t
    JOIN pg_namespace n ON n.oid = t.typnamespace
    WHERE n.nspname = 'public'
      AND t.typname = 'user_role'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE TYPE "public"."user_role" AS ENUM (
    'buyer',
    'supplier',
    'admin'
);
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: verification_doc_status; Type: TYPE; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_type t
    JOIN pg_namespace n ON n.oid = t.typnamespace
    WHERE n.nspname = 'public'
      AND t.typname = 'verification_doc_status'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE TYPE "public"."verification_doc_status" AS ENUM (
    'pending',
    'approved',
    'rejected'
);
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: verification_status; Type: TYPE; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_type t
    JOIN pg_namespace n ON n.oid = t.typnamespace
    WHERE n.nspname = 'public'
      AND t.typname = 'verification_status'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE TYPE "public"."verification_status" AS ENUM (
    'unverified',
    'pending',
    'verified',
    'rejected'
);
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: withdrawal_status; Type: TYPE; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_type t
    JOIN pg_namespace n ON n.oid = t.typnamespace
    WHERE n.nspname = 'public'
      AND t.typname = 'withdrawal_status'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE TYPE "public"."withdrawal_status" AS ENUM (
    'pending',
    'approved',
    'rejected'
);
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: bulk_update_product_images("jsonb"); Type: FUNCTION; Schema: public; Owner: -
--

CREATE OR REPLACE FUNCTION "public"."bulk_update_product_images"("updates" "jsonb") RETURNS integer
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
  updated_count int;
BEGIN
  WITH data AS (
    SELECT 
      (elem->>'id')::uuid AS id,
      ARRAY(SELECT jsonb_array_elements_text(elem->'images'))::text[] AS images
    FROM jsonb_array_elements(updates) AS elem
  ),
  upd AS (
    UPDATE products AS p
    SET images = d.images
    FROM data AS d
    WHERE p.id = d.id
    RETURNING p.id
  )
  SELECT count(*) INTO updated_count FROM upd;
  
  RETURN updated_count;
END;
$$;


--
-- Name: can_supplier_use_ai_matching("uuid", "uuid"); Type: FUNCTION; Schema: public; Owner: -
--

CREATE OR REPLACE FUNCTION "public"."can_supplier_use_ai_matching"("p_company_id" "uuid", "p_user_id" "uuid" DEFAULT "auth"."uid"()) RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
  v_sub record;
  v_comp record;
  v_user_role text;
BEGIN
  -- If user_id provided, check if admin
  IF p_user_id IS NOT NULL THEN
    SELECT role INTO v_user_role FROM profiles WHERE id = p_user_id;
    IF v_user_role = 'admin' THEN
      RETURN jsonb_build_object(
        'allowed', true,
        'tier', 'enterprise',
        'has_ai_matching', true,
        'message', 'Admin access granted'
      );
    END IF;
  END IF;

  IF p_company_id IS NULL THEN
    RETURN jsonb_build_object(
      'allowed', false,
      'tier', null,
      'has_ai_matching', false,
      'reason', 'no_company',
      'message', 'Registered company required'
    );
  END IF;

  -- Check company direct flag
  SELECT * INTO v_comp FROM companies WHERE id = p_company_id;
  IF FOUND AND v_comp.has_ai_access = true THEN
    RETURN jsonb_build_object(
      'allowed', true,
      'tier', 'addon_ai',
      'has_ai_matching', true,
      'message', 'AI Accessibility Add-on active'
    );
  END IF;

  -- Find active subscription
  SELECT * INTO v_sub
  FROM subscriptions
  WHERE company_id = p_company_id
    AND status = 'active'
    AND (ends_at IS NULL OR ends_at > now())
  ORDER BY created_at DESC
  LIMIT 1;

  IF NOT FOUND THEN
    RETURN jsonb_build_object(
      'allowed', false,
      'tier', null,
      'has_ai_matching', false,
      'reason', 'no_subscription',
      'message', 'Active paid subscription required. Upgrade to ₹7,500 Business Package or ₹7,500 AI Accessibility Add-on.'
    );
  END IF;

  -- Check tier: business (₹7,500), growth (₹15,000), enterprise or has_ai_access flag
  IF v_sub.tier IN ('business', 'growth', 'enterprise') OR v_sub.has_ai_access = true THEN
    RETURN jsonb_build_object(
      'allowed', true,
      'tier', v_sub.tier,
      'has_ai_matching', true,
      'message', 'AI Product Matching & Assistant unlocked'
    );
  ELSE
    RETURN jsonb_build_object(
      'allowed', false,
      'tier', v_sub.tier,
      'has_ai_matching', false,
      'reason', 'upgrade_required',
      'message', 'AI Accessibility requires the ₹7,500 Business Package or the ₹7,500 AI Add-on.'
    );
  END IF;
END;
$$;


--
-- Name: generate_order_number(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE OR REPLACE FUNCTION "public"."generate_order_number"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  IF NEW.order_number IS NULL OR NEW.order_number = '' THEN
    NEW.order_number := 'ORD-' || TO_CHAR(NOW(), 'YYYYMM') || '-' || LPAD(nextval('order_number_seq')::TEXT, 5, '0');
  END IF;
  RETURN NEW;
END;
$$;


--
-- Name: generate_req_number(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE OR REPLACE FUNCTION "public"."generate_req_number"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  IF NEW.req_number IS NULL THEN
    NEW.req_number := 'RFQ-' || LPAD(NEXTVAL('req_number_seq')::text, 6, '0');
  END IF;
  RETURN NEW;
END;
$$;


--
-- Name: get_conversation_parties("uuid"); Type: FUNCTION; Schema: public; Owner: -
--

CREATE OR REPLACE FUNCTION "public"."get_conversation_parties"("conv_id" "uuid") RETURNS TABLE("buyer_id" "uuid", "supplier_id" "uuid")
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
  SELECT buyer_id, supplier_id FROM conversations WHERE id = conv_id;
$$;


--
-- Name: get_manufacturer_analytics("uuid"); Type: FUNCTION; Schema: public; Owner: -
--

CREATE OR REPLACE FUNCTION "public"."get_manufacturer_analytics"("p_company_id" "uuid") RETURNS json
    LANGUAGE "plpgsql" STABLE SECURITY DEFINER
    AS $$
DECLARE
  v_rfqs_received  int;
  v_quotes_sent    int;
  v_orders_done    int;
  v_response_rate  numeric;
  v_avg_hours      numeric;
BEGIN
  SELECT COUNT(*) INTO v_rfqs_received FROM rfq_match_log WHERE company_id = p_company_id;
  SELECT COUNT(*) INTO v_quotes_sent FROM quotations WHERE supplier_company_id = p_company_id AND is_draft = false;
  SELECT COUNT(*) INTO v_orders_done FROM orders
    WHERE supplier_company_id = p_company_id AND milestone = 'completed';

  v_response_rate := CASE WHEN v_rfqs_received > 0
    THEN ROUND((v_quotes_sent::numeric / v_rfqs_received) * 100, 1)
    ELSE 0 END;

  SELECT COALESCE(AVG(EXTRACT(EPOCH FROM (q.created_at - r.created_at)) / 3600), 0)
  INTO v_avg_hours
  FROM quotations q
  JOIN requirements r ON r.id = q.requirement_id
  WHERE q.supplier_company_id = p_company_id AND q.is_draft = false;

  RETURN json_build_object(
    'rfqs_received', v_rfqs_received,
    'quotes_sent', v_quotes_sent,
    'orders_completed', v_orders_done,
    'response_rate', v_response_rate,
    'avg_response_hours', ROUND(v_avg_hours, 1)
  );
END;
$$;


--
-- Name: get_my_role(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE OR REPLACE FUNCTION "public"."get_my_role"() RETURNS "text"
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
  SELECT role::text FROM profiles WHERE id = auth.uid();
$$;


--
-- Name: get_or_create_chat_conversation("uuid", "uuid", "uuid", "uuid", "uuid"); Type: FUNCTION; Schema: public; Owner: -
--

CREATE OR REPLACE FUNCTION "public"."get_or_create_chat_conversation"("p_buyer_id" "uuid", "p_supplier_id" "uuid", "p_supplier_company_id" "uuid", "p_product_id" "uuid" DEFAULT NULL::"uuid", "p_requirement_id" "uuid" DEFAULT NULL::"uuid") RETURNS "uuid"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
  v_conv_id uuid;
BEGIN
  -- Look up existing
  IF p_product_id IS NOT NULL THEN
    SELECT id INTO v_conv_id
    FROM conversations
    WHERE buyer_id = p_buyer_id
      AND supplier_id = p_supplier_id
      AND product_id = p_product_id
    LIMIT 1;
  ELSIF p_requirement_id IS NOT NULL THEN
    SELECT id INTO v_conv_id
    FROM conversations
    WHERE buyer_id = p_buyer_id
      AND supplier_id = p_supplier_id
      AND requirement_id = p_requirement_id
    LIMIT 1;
  ELSE
    SELECT id INTO v_conv_id
    FROM conversations
    WHERE buyer_id = p_buyer_id
      AND supplier_id = p_supplier_id
    ORDER BY created_at ASC
    LIMIT 1;
  END IF;

  IF v_conv_id IS NOT NULL THEN
    RETURN v_conv_id;
  END IF;

  -- Create new
  INSERT INTO conversations(
    buyer_id, supplier_id, supplier_company_id, product_id, requirement_id
  )
  VALUES(
    p_buyer_id, p_supplier_id, p_supplier_company_id, p_product_id, p_requirement_id
  )
  RETURNING id INTO v_conv_id;

  RETURN v_conv_id;
END;
$$;


--
-- Name: get_order_parties("uuid"); Type: FUNCTION; Schema: public; Owner: -
--

CREATE OR REPLACE FUNCTION "public"."get_order_parties"("ord_id" "uuid") RETURNS TABLE("buyer_id" "uuid", "supplier_id" "uuid", "supplier_company_id" "uuid")
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
  SELECT buyer_id, supplier_id, supplier_company_id FROM orders WHERE id = ord_id;
$$;


--
-- Name: handle_new_user(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE OR REPLACE FUNCTION "public"."handle_new_user"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
  chosen_role public.user_role := 'buyer'::public.user_role;
  raw_role text;
  meta_full_name text;
BEGIN
  -- Extract role from raw_user_meta_data if provided
  raw_role := NEW.raw_user_meta_data->>'role';
  IF raw_role = 'supplier' THEN
    chosen_role := 'supplier'::public.user_role;
  ELSIF raw_role = 'admin' THEN
    chosen_role := 'admin'::public.user_role;
  ELSE
    chosen_role := 'buyer'::public.user_role;
  END IF;

  meta_full_name := COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.raw_user_meta_data->>'name', split_part(NEW.email, '@', 1));

  -- Insert profile if not exists, or update on conflict
  INSERT INTO public.profiles (
    id,
    email,
    full_name,
    role,
    status,
    created_at,
    updated_at
  )
  VALUES (
    NEW.id,
    NEW.email,
    meta_full_name,
    chosen_role,
    'active'::public.account_status,
    NOW(),
    NOW()
  )
  ON CONFLICT (id) DO UPDATE SET
    email = EXCLUDED.email,
    full_name = COALESCE(public.profiles.full_name, EXCLUDED.full_name),
    updated_at = NOW();

  RETURN NEW;
END;
$$;


--
-- Name: is_admin(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE OR REPLACE FUNCTION "public"."is_admin"() RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
  SELECT EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin');
$$;


--
-- Name: is_chat_eligible("uuid"); Type: FUNCTION; Schema: public; Owner: -
--

CREATE OR REPLACE FUNCTION "public"."is_chat_eligible"("p_user_id" "uuid") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
  v_role text;
BEGIN
  SELECT role INTO v_role FROM profiles WHERE id = p_user_id;

  -- Admins and buyers are always eligible (buyers use platform for free)
  IF v_role IN ('admin', 'buyer') THEN RETURN true; END IF;

  -- Suppliers must have an active subscription
  RETURN EXISTS (
    SELECT 1
    FROM companies c
    JOIN subscriptions s ON s.company_id = c.id
    WHERE c.owner_id = p_user_id
      AND s.status = 'active'
      AND (s.ends_at IS NULL OR s.ends_at > now())
  );
END;
$$;


--
-- Name: is_company_owner("uuid"); Type: FUNCTION; Schema: public; Owner: -
--

CREATE OR REPLACE FUNCTION "public"."is_company_owner"("comp_id" "uuid") RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
  SELECT EXISTS(SELECT 1 FROM companies WHERE id = comp_id AND owner_id = auth.uid());
$$;


--
-- Name: is_supplier_subscribed("uuid"); Type: FUNCTION; Schema: public; Owner: -
--

CREATE OR REPLACE FUNCTION "public"."is_supplier_subscribed"("p_user_id" "uuid" DEFAULT "auth"."uid"()) RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
  v_role text;
  v_subscribed boolean := false;
BEGIN
  IF p_user_id IS NULL THEN
    RETURN false;
  END IF;

  SELECT role INTO v_role FROM profiles WHERE id = p_user_id;

  -- Admins are always allowed
  IF v_role = 'admin' THEN
    RETURN true;
  END IF;

  -- Only suppliers need a subscription to submit quotations
  IF v_role <> 'supplier' THEN
    RETURN false;
  END IF;

  SELECT EXISTS (
    SELECT 1
    FROM companies c
    JOIN subscriptions s ON s.company_id = c.id
    WHERE c.owner_id = p_user_id
      AND s.status = 'active'
      AND (s.ends_at IS NULL OR s.ends_at > now())
  ) INTO v_subscribed;

  RETURN v_subscribed;
END;
$$;


--
-- Name: log_order_milestone(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE OR REPLACE FUNCTION "public"."log_order_milestone"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
  IF NEW.milestone IS DISTINCT FROM OLD.milestone THEN
    INSERT INTO order_milestones(order_id, milestone, changed_by)
    VALUES(NEW.id, NEW.milestone, auth.uid());
  END IF;
  RETURN NEW;
END;
$$;


--
-- Name: notify_buyer_on_quote(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE OR REPLACE FUNCTION "public"."notify_buyer_on_quote"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
  v_buyer_id uuid;
  v_title    text;
BEGIN
  SELECT buyer_id, title INTO v_buyer_id, v_title
  FROM requirements WHERE id = NEW.requirement_id;
  IF v_buyer_id IS NOT NULL THEN
    INSERT INTO notifications(user_id, title, message, type, link)
    VALUES (
      v_buyer_id,
      'New Supplier Response',
      'A supplier has responded to your requirement: ' || v_title,
      'quotation',
      '/requirements'
    );
  END IF;
  RETURN NEW;
END;
$$;


--
-- Name: notify_followers_on_product(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE OR REPLACE FUNCTION "public"."notify_followers_on_product"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
  r RECORD;
BEGIN
  FOR r IN
    SELECT sm.buyer_id FROM saved_manufacturers sm WHERE sm.company_id = NEW.company_id
  LOOP
    INSERT INTO notifications(user_id, title, message, type, link, reference_id, reference_type)
    SELECT r.buyer_id,
      'New product from followed manufacturer',
      (SELECT company_name FROM companies WHERE id = NEW.company_id) || ' added a new product: ' || NEW.name,
      'product_update',
      '/companies/' || (SELECT slug FROM companies WHERE id = NEW.company_id),
      NEW.id,
      'product';
  END LOOP;
  RETURN NEW;
END;
$$;


--
-- Name: notify_supplier_on_deal_status(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE OR REPLACE FUNCTION "public"."notify_supplier_on_deal_status"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
  v_supplier_id uuid;
BEGIN
  IF OLD.deal_status IS DISTINCT FROM NEW.deal_status THEN
    -- Notify all suppliers who quoted on this requirement
    FOR v_supplier_id IN
      SELECT DISTINCT supplier_id FROM quotations WHERE requirement_id = NEW.id
    LOOP
      INSERT INTO notifications(user_id, title, message, type, link)
      VALUES (
        v_supplier_id,
        'Requirement Status Updated',
        'Status changed to ' || NEW.deal_status || ' for: ' || NEW.title,
        'deal_status',
        '/requirements'
      );
    END LOOP;
  END IF;
  RETURN NEW;
END;
$$;


--
-- Name: notify_unpaid_manufacturers(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE OR REPLACE FUNCTION "public"."notify_unpaid_manufacturers"() RETURNS integer
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
  v_count integer := 0;
  r record;
BEGIN
  FOR r IN
    SELECT DISTINCT c.owner_id, c.company_name
    FROM public.companies c
    JOIN public.profiles p ON p.id = c.owner_id
    WHERE c.owner_id IS NOT NULL
      AND p.role = 'supplier'
      AND NOT EXISTS (
        SELECT 1 FROM public.subscriptions s
        WHERE s.company_id = c.id
          AND s.status = 'active'
          AND (s.ends_at IS NULL OR s.ends_at > now())
      )
      -- Check that we haven't already sent a subscription notification today
      AND NOT EXISTS (
        SELECT 1 FROM public.notifications n
        WHERE n.user_id = c.owner_id
          AND n.type = 'subscription'
          AND n.created_at > now() - interval '12 hours'
      )
  LOOP
    INSERT INTO public.notifications (
      user_id,
      title,
      message,
      type,
      link,
      urgency_label
    ) VALUES (
      r.owner_id,
      '⚡ Upgrade Required: Unlock Live RFQs & Direct Buyer Chat',
      'Your manufacturer account has active buyer inquiries waiting in your industry. Upgrade to a Verified Supplier Plan to submit formal quotes, access buyer contact details, and start real-time negotiations.',
      'subscription',
      '/pricing',
      'urgent'
    );
    v_count := v_count + 1;
  END LOOP;

  RETURN v_count;
END;
$$;


--
-- Name: owns_company("uuid"); Type: FUNCTION; Schema: public; Owner: -
--

CREATE OR REPLACE FUNCTION "public"."owns_company"("company_uuid" "uuid") RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
  SELECT EXISTS (SELECT 1 FROM companies WHERE id = company_uuid AND owner_id = auth.uid());
$$;


--
-- Name: place_auction_bid("uuid", numeric, "text"); Type: FUNCTION; Schema: public; Owner: -
--

CREATE OR REPLACE FUNCTION "public"."place_auction_bid"("p_auction_id" "uuid", "p_bid_amount" numeric, "p_bidder_name" "text") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_auction RECORD;
    v_user_id UUID := auth.uid();
    v_company_id UUID;
    v_bid_id UUID;
BEGIN
    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'Authentication required to place bid';
    END IF;

    SELECT id INTO v_company_id FROM public.companies WHERE owner_id = v_user_id LIMIT 1;

    SELECT * INTO v_auction FROM public.auctions WHERE id = p_auction_id FOR UPDATE;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Auction not found';
    END IF;

    IF v_auction.status != 'live' OR (v_auction.end_time IS NOT NULL AND v_auction.end_time < NOW()) THEN
        RAISE EXCEPTION 'This auction is no longer active';
    END IF;

    -- For reverse auctions (buyers bidding lower) or forward auctions (bidding higher)
    INSERT INTO public.auction_bids (
        auction_id, bidder_user_id, bidder_company_id, bidder_name, bid_amount
    ) VALUES (
        p_auction_id, v_user_id, v_company_id, COALESCE(p_bidder_name, 'Verified Bidder'), p_bid_amount
    ) RETURNING id INTO v_bid_id;

    UPDATE public.auctions
    SET current_highest_bid = p_bid_amount,
        highest_bidder_id = v_user_id,
        highest_bidder_name = COALESCE(p_bidder_name, 'Verified Bidder'),
        total_bids = COALESCE(total_bids, 0) + 1,
        updated_at = NOW()
    WHERE id = p_auction_id;

    RETURN jsonb_build_object(
        'success', true,
        'bid_id', v_bid_id,
        'new_amount', p_bid_amount,
        'total_bids', v_auction.total_bids + 1
    );
END;
$$;


--
-- Name: place_forward_bid("uuid", numeric, integer, "text"); Type: FUNCTION; Schema: public; Owner: -
--

CREATE OR REPLACE FUNCTION "public"."place_forward_bid"("p_auction_id" "uuid", "p_bid_amount" numeric, "p_quantity" integer, "p_bidder_company_name" "text" DEFAULT NULL::"text") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
  v_auction RECORD;
  v_bid_id uuid;
  v_total_val numeric;
  v_now timestamptz := now();
  v_min_eligible numeric;
  v_extended boolean := false;
  v_new_end timestamptz;
BEGIN
  -- Lock auction row for concurrency safety
  SELECT * INTO v_auction FROM auctions WHERE id = p_auction_id FOR UPDATE;
  
  IF NOT FOUND THEN
    RETURN jsonb_build_object('success', false, 'error', 'Auction not found');
  END IF;

  IF v_auction.status NOT IN ('live', 'closing_soon') THEN
    RETURN jsonb_build_object('success', false, 'error', 'Auction is not active (status: ' || v_auction.status || ')');
  END IF;

  IF v_auction.end_time <= v_now THEN
    UPDATE auctions SET status = 'under_review' WHERE id = p_auction_id;
    RETURN jsonb_build_object('success', false, 'error', 'Auction has closed');
  END IF;

  IF v_auction.seller_id IS NOT NULL AND v_auction.seller_id = auth.uid() THEN
    RETURN jsonb_build_object('success', false, 'error', 'Sellers are strictly prohibited from bidding on their own auction');
  END IF;

  -- Determine min eligible bid
  IF v_auction.total_bids = 0 OR v_auction.current_highest_bid = 0 THEN
    v_min_eligible := v_auction.starting_price;
  ELSE
    v_min_eligible := v_auction.current_highest_bid + v_auction.min_bid_increment;
  END IF;

  IF p_bid_amount < v_min_eligible THEN
    RETURN jsonb_build_object(
      'success', false, 
      'error', 'Bid must be at least ₹' || v_min_eligible || ' (Current: ₹' || v_auction.current_highest_bid || ' + Min Incr: ₹' || v_auction.min_bid_increment || ')'
    );
  END IF;

  v_total_val := p_bid_amount * COALESCE(p_quantity, v_auction.total_quantity);

  -- Insert bid record
  INSERT INTO forward_bids (
    auction_id, bidder_id, bidder_company_name, bid_amount, quantity, total_value, currency, status, server_timestamp
  ) VALUES (
    p_auction_id, 
    COALESCE(auth.uid(), '00000000-0000-0000-0000-000000000001'::uuid), 
    COALESCE(p_bidder_company_name, 'Verified Wholesale Buyer'), 
    p_bid_amount, 
    COALESCE(p_quantity, v_auction.total_quantity), 
    v_total_val, 
    v_auction.currency, 
    'accepted', 
    v_now
  ) RETURNING id INTO v_bid_id;

  -- Mark previous bids as outbid
  UPDATE forward_bids 
  SET status = 'outbid' 
  WHERE auction_id = p_auction_id AND id != v_bid_id AND status = 'accepted';

  -- Anti-sniping logic: if within last 120s, extend by 120s
  v_new_end := v_auction.end_time;
  IF v_auction.anti_sniping_enabled AND (v_auction.end_time - v_now) <= interval '120 seconds' THEN
    v_new_end := v_auction.end_time + interval '120 seconds';
    v_extended := true;
  END IF;

  -- Update auction record
  UPDATE auctions SET
    current_highest_bid = p_bid_amount,
    highest_bidder_id = COALESCE(auth.uid(), '00000000-0000-0000-0000-000000000001'::uuid),
    highest_bidder_name = COALESCE(p_bidder_company_name, 'Verified Wholesale Buyer'),
    total_bids = v_auction.total_bids + 1,
    winning_bid_id = v_bid_id,
    end_time = v_new_end,
    updated_at = v_now
  WHERE id = p_auction_id;

  RETURN jsonb_build_object(
    'success', true,
    'bid_id', v_bid_id,
    'bid_amount', p_bid_amount,
    'total_bids', v_auction.total_bids + 1,
    'anti_sniping_extended', v_extended,
    'new_end_time', v_new_end
  );
END;
$$;


--
-- Name: trg_check_quotation_subscription(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE OR REPLACE FUNCTION "public"."trg_check_quotation_subscription"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
  v_role text;
  v_has_sub boolean := false;
BEGIN
  -- Check user role
  IF NEW.supplier_id IS NOT NULL THEN
    SELECT role INTO v_role FROM profiles WHERE id = NEW.supplier_id;
    IF v_role = 'admin' THEN
      RETURN NEW;
    END IF;
  END IF;

  -- Check if supplier has active subscription by company or supplier_id
  IF NEW.supplier_company_id IS NOT NULL THEN
    SELECT EXISTS (
      SELECT 1
      FROM subscriptions
      WHERE company_id = NEW.supplier_company_id
        AND status = 'active'
        AND (ends_at IS NULL OR ends_at > now())
    ) INTO v_has_sub;
  END IF;

  IF NOT v_has_sub AND NEW.supplier_id IS NOT NULL THEN
    SELECT EXISTS (
      SELECT 1
      FROM companies c
      JOIN subscriptions s ON s.company_id = c.id
      WHERE c.owner_id = NEW.supplier_id
        AND s.status = 'active'
        AND (s.ends_at IS NULL OR s.ends_at > now())
    ) INTO v_has_sub;
  END IF;

  IF NOT v_has_sub THEN
    RAISE EXCEPTION 'Active paid subscription required to send quotations to Live Buying Requirements. Please upgrade to the ₹5,000 Business Package.'
      USING ERRCODE = 'P0001';
  END IF;

  RETURN NEW;
END;
$$;


--
-- Name: trg_notify_new_message_fn(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE OR REPLACE FUNCTION "public"."trg_notify_new_message_fn"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
  v_conv record;
  v_recipient_id uuid;
  v_recipient_role text;
  v_sender_name text;
  v_link text;
BEGIN
  -- Fetch conversation details
  SELECT buyer_id, supplier_id, id INTO v_conv
  FROM public.conversations
  WHERE id = NEW.conversation_id;

  IF NOT FOUND THEN
    RETURN NEW;
  END IF;

  -- Determine recipient
  IF NEW.sender_id = v_conv.buyer_id THEN
    v_recipient_id := v_conv.supplier_id;
    v_recipient_role := 'supplier';
  ELSE
    v_recipient_id := v_conv.buyer_id;
    v_recipient_role := 'buyer';
  END IF;

  -- Get sender name
  SELECT COALESCE(full_name, 'A trading partner') INTO v_sender_name
  FROM public.profiles
  WHERE id = NEW.sender_id;

  v_link := '/dashboard/' || v_recipient_role || '/negotiation/' || v_conv.id::text;

  -- Insert notification for recipient
  INSERT INTO public.notifications (
    user_id,
    title,
    message,
    type,
    link,
    reference_id,
    reference_type,
    urgency_label
  ) VALUES (
    v_recipient_id,
    '💬 New Message from ' || v_sender_name,
    CASE 
      WHEN NEW.content IS NOT NULL AND char_length(NEW.content) > 0 
        THEN substring(NEW.content from 1 for 100)
      ELSE 'Sent an attachment'
    END,
    'message',
    v_link,
    v_conv.id,
    'conversation',
    'new'
  );

  RETURN NEW;
END;
$$;


--
-- Name: trg_notify_new_quotation_fn(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE OR REPLACE FUNCTION "public"."trg_notify_new_quotation_fn"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
  v_buyer_id uuid;
  v_req_title text;
  v_company_name text;
BEGIN
  -- Get requirement info
  SELECT buyer_id, title INTO v_buyer_id, v_req_title
  FROM public.requirements
  WHERE id = NEW.requirement_id;

  -- Get supplier company name
  SELECT company_name INTO v_company_name
  FROM public.companies
  WHERE id = NEW.supplier_company_id;

  IF v_buyer_id IS NOT NULL THEN
    INSERT INTO public.notifications (
      user_id,
      title,
      message,
      type,
      link,
      reference_id,
      reference_type,
      urgency_label
    ) VALUES (
      v_buyer_id,
      '📦 New Quotation: ' || COALESCE(v_company_name, 'Verified Manufacturer'),
      'A new formal quotation was submitted for "' || COALESCE(v_req_title, 'your requirement') || '" at ' || COALESCE(NEW.currency, 'INR') || ' ' || COALESCE(NEW.unit_price::text, '') || '/unit.',
      'quote_received',
      '/dashboard/buyer/requirements',
      NEW.id,
      'quotation',
      'urgent'
    );
  END IF;

  RETURN NEW;
END;
$$;


--
-- Name: trigger_match_on_new_manufacturer(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE OR REPLACE FUNCTION "public"."trigger_match_on_new_manufacturer"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
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


--
-- Name: trigger_rfq_matching_on_new_req(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE OR REPLACE FUNCTION "public"."trigger_rfq_matching_on_new_req"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
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
$$;


--
-- Name: update_company_response_rate(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE OR REPLACE FUNCTION "public"."update_company_response_rate"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
  v_rfqs int; v_quotes int;
BEGIN
  SELECT COUNT(*) INTO v_rfqs FROM rfq_match_log WHERE company_id = NEW.supplier_company_id;
  SELECT COUNT(*) INTO v_quotes FROM quotations
    WHERE supplier_company_id = NEW.supplier_company_id AND is_draft = false;
  UPDATE companies SET
    response_rate = CASE WHEN v_rfqs > 0 THEN ROUND((v_quotes::numeric/v_rfqs)*100,1) ELSE 0 END,
    total_quotes_sent = v_quotes
  WHERE id = NEW.supplier_company_id;
  RETURN NEW;
END;
$$;


--
-- Name: update_conv_on_message(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE OR REPLACE FUNCTION "public"."update_conv_on_message"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
  v_buyer_id uuid;
  v_supplier_id uuid;
BEGIN
  SELECT buyer_id, supplier_id INTO v_buyer_id, v_supplier_id
  FROM conversations WHERE id = NEW.conversation_id;

  UPDATE conversations SET
    last_message    = LEFT(NEW.content, 120),
    last_message_at = NEW.created_at,
    buyer_unread    = CASE WHEN NEW.sender_id = v_supplier_id THEN buyer_unread + 1 ELSE buyer_unread END,
    supplier_unread = CASE WHEN NEW.sender_id = v_buyer_id    THEN supplier_unread + 1 ELSE supplier_unread END
  WHERE id = NEW.conversation_id;

  RETURN NEW;
END;
$$;


--
-- Name: update_orders_updated_at(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE OR REPLACE FUNCTION "public"."update_orders_updated_at"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN NEW.updated_at = now(); RETURN NEW; END;
$$;


SET default_tablespace = '';

SET default_table_access_method = "heap";

--
-- Name: _backup_auth_users_20261001; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE IF NOT EXISTS "public"."_backup_auth_users_20261001" (
    "id" "uuid",
    "email" character varying(255),
    "created_at" timestamp with time zone,
    "role" character varying(255)
);


--
-- Name: _backup_companies_20261001; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE IF NOT EXISTS "public"."_backup_companies_20261001" (
    "id" "uuid",
    "owner_id" "uuid",
    "company_name" "text",
    "slug" "text",
    "description" "text",
    "gst_number" "text",
    "iec_number" "text",
    "business_type" "text",
    "website" "text",
    "address" "text",
    "city" "text",
    "state" "text",
    "country" "text",
    "pincode" "text",
    "logo_url" "text",
    "cover_url" "text",
    "verification_status" "public"."verification_status",
    "verified_at" timestamp with time zone,
    "is_featured" boolean,
    "total_products" integer,
    "total_quotes_sent" integer,
    "export_destinations" "text"[],
    "years_in_business" integer,
    "employee_count" "text",
    "annual_turnover" "text",
    "gst_doc_url" "text",
    "iec_doc_url" "text",
    "reg_doc_url" "text",
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "banner_url" "text",
    "tagline" "text",
    "year_established" integer,
    "employee_count_range" "text",
    "annual_turnover_range" "text",
    "payment_terms" "text"[],
    "production_capacity" "text",
    "is_verified" boolean,
    "verification_notes" "text",
    "rating_avg" numeric(3,2),
    "review_count" integer,
    "key_products" "text"[],
    "moq_policy" "text",
    "packaging_details" "text",
    "profile_completion" integer,
    "verification_expiry_at" timestamp with time zone,
    "pan_number" "text",
    "pan_doc_url" "text",
    "factory_doc_url" "text",
    "bank_doc_url" "text",
    "bank_account_name" "text",
    "bank_account_number" "text",
    "bank_ifsc" "text",
    "bank_name" "text",
    "bank_branch" "text",
    "verified_by" "uuid",
    "rejection_reason" "text",
    "wallet_balance" numeric,
    "withdrawable_balance" numeric,
    "total_revenue" numeric,
    "response_rate" numeric,
    "avg_response_hours" numeric,
    "is_blocked" boolean,
    "lead_credits" integer,
    "commission_balance" numeric(14,2)
);


--
-- Name: _backup_orders_20261001; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE IF NOT EXISTS "public"."_backup_orders_20261001" (
    "id" "uuid",
    "order_number" "text",
    "quotation_id" "uuid",
    "buyer_id" "uuid",
    "supplier_company_id" "uuid",
    "total_amount" numeric(12,2),
    "currency" "text",
    "quantity" integer,
    "status" "public"."order_status",
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "milestone" "public"."order_milestone",
    "requirement_id" "uuid",
    "supplier_id" "uuid",
    "notes" "text",
    "cancelled_reason" "text",
    "cancelled_by" "uuid",
    "commission_pct" numeric(5,2),
    "commission_amount" numeric(14,2),
    "commission_status" "text",
    "payment_status" "text",
    "order_status" "text",
    "tracking_courier" "text",
    "tracking_number" "text",
    "tracking_eta" "date"
);


--
-- Name: _backup_products_20261001; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE IF NOT EXISTS "public"."_backup_products_20261001" (
    "id" "uuid",
    "company_id" "uuid",
    "category_id" "uuid",
    "name" "text",
    "slug" "text",
    "description" "text",
    "specifications" "text",
    "moq" integer,
    "moq_unit" "text",
    "price_min" numeric(12,2),
    "price_max" numeric(12,2),
    "price_currency" "text",
    "images" "text"[],
    "tags" "text"[],
    "export_destinations" "text"[],
    "is_active" boolean,
    "is_featured" boolean,
    "view_count" integer,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "is_sponsored" boolean,
    "is_promoted" boolean,
    "promotion_type" "text",
    "video_url" "text",
    "brochure_url" "text"
);


--
-- Name: _backup_profiles_20261001; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE IF NOT EXISTS "public"."_backup_profiles_20261001" (
    "id" "uuid",
    "email" "text",
    "full_name" "text",
    "phone" "text",
    "role" "public"."user_role",
    "status" "public"."account_status",
    "avatar_url" "text",
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone
);


--
-- Name: _backup_quotations_20261001; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE IF NOT EXISTS "public"."_backup_quotations_20261001" (
    "id" "uuid",
    "requirement_id" "uuid",
    "supplier_company_id" "uuid",
    "supplier_id" "uuid",
    "buyer_id" "uuid",
    "unit_price" numeric(12,2),
    "currency" "text",
    "moq" integer,
    "moq_unit" "text",
    "delivery_days" integer,
    "payment_terms" "text",
    "validity_days" integer,
    "notes" "text",
    "status" "public"."quote_status",
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "quantity" integer,
    "total_price" numeric,
    "production_days" integer,
    "delivery_terms" "text",
    "attachment_urls" "text"[],
    "pdf_url" "text",
    "is_draft" boolean,
    "change_request" "text",
    "shipping_cost" numeric,
    "available_quantity" integer
);


--
-- Name: _backup_requirements_20261001; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE IF NOT EXISTS "public"."_backup_requirements_20261001" (
    "id" "uuid",
    "buyer_id" "uuid",
    "category_id" "uuid",
    "title" "text",
    "description" "text",
    "specifications" "text",
    "quantity" integer,
    "quantity_unit" "text",
    "destination_country" "text",
    "destination_city" "text",
    "deadline" "date",
    "budget_min" numeric(12,2),
    "budget_max" numeric(12,2),
    "currency" "text",
    "attachment_url" "text",
    "status" "public"."rfq_status",
    "quote_count" integer,
    "view_count" integer,
    "is_verified_buyer" boolean,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "expires_at" timestamp with time zone,
    "matched_count" integer,
    "deal_status" "text",
    "is_urgent" boolean,
    "req_number" "text"
);


--
-- Name: _backup_subscription_orders_20261001; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE IF NOT EXISTS "public"."_backup_subscription_orders_20261001" (
    "id" "uuid",
    "company_id" "uuid",
    "user_id" "uuid",
    "plan_tier" "text",
    "plan_label" "text",
    "price_inr" numeric(10,2),
    "billing_cycle" "text",
    "stripe_session_id" "text",
    "stripe_payment_intent_id" "text",
    "customer_email" "text",
    "status" "text",
    "completed_at" timestamp with time zone,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "razorpay_order_id" "text",
    "razorpay_payment_id" "text",
    "razorpay_signature" "text"
);


--
-- Name: _backup_subscriptions_20261001; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE IF NOT EXISTS "public"."_backup_subscriptions_20261001" (
    "id" "uuid",
    "company_id" "uuid",
    "tier" "public"."subscription_tier",
    "status" "public"."subscription_status",
    "price_inr" numeric(10,2),
    "billing_cycle" "text",
    "starts_at" timestamp with time zone,
    "ends_at" timestamp with time zone,
    "stripe_subscription_id" "text",
    "stripe_customer_id" "text",
    "max_products" integer,
    "max_rfq_leads" integer,
    "used_rfq_leads" integer,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone
);


--
-- Name: auction_bids; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE IF NOT EXISTS "public"."auction_bids" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "auction_id" "uuid" NOT NULL,
    "bidder_user_id" "uuid",
    "bidder_company_id" "uuid",
    "bidder_name" "text" NOT NULL,
    "bid_amount" numeric NOT NULL,
    "quantity" integer,
    "status" "text" DEFAULT 'valid'::"text",
    "created_at" timestamp with time zone DEFAULT "now"()
);


--
-- Name: auction_chats; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE IF NOT EXISTS "public"."auction_chats" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "auction_id" "text" NOT NULL,
    "sender_name" "text" NOT NULL,
    "sender_role" "text" DEFAULT 'buyer'::"text" NOT NULL,
    "message" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


--
-- Name: auctions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE IF NOT EXISTS "public"."auctions" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "auction_number" "text" NOT NULL,
    "auction_type" "text" DEFAULT 'forward'::"text" NOT NULL,
    "seller_id" "uuid",
    "seller_company_id" "uuid",
    "title" "text" NOT NULL,
    "description" "text",
    "category_id" "uuid",
    "images" "text"[] DEFAULT '{}'::"text"[],
    "total_quantity" integer DEFAULT 1000 NOT NULL,
    "moq" integer DEFAULT 100 NOT NULL,
    "quantity_unit" "text" DEFAULT 'Pieces'::"text" NOT NULL,
    "starting_price" numeric DEFAULT 100 NOT NULL,
    "reserve_price" numeric DEFAULT 150 NOT NULL,
    "min_bid_increment" numeric DEFAULT 10 NOT NULL,
    "current_highest_bid" numeric DEFAULT 0 NOT NULL,
    "highest_bidder_id" "uuid",
    "highest_bidder_name" "text",
    "total_bids" integer DEFAULT 0 NOT NULL,
    "currency" "text" DEFAULT 'INR'::"text" NOT NULL,
    "duration_minutes" integer DEFAULT 60 NOT NULL,
    "start_time" timestamp with time zone DEFAULT "now"() NOT NULL,
    "end_time" timestamp with time zone DEFAULT ("now"() + '01:00:00'::interval) NOT NULL,
    "anti_sniping_enabled" boolean DEFAULT true NOT NULL,
    "anti_sniping_trigger_seconds" integer DEFAULT 120 NOT NULL,
    "anti_sniping_extend_seconds" integer DEFAULT 120 NOT NULL,
    "status" "text" DEFAULT 'live'::"text" NOT NULL,
    "winner_id" "uuid",
    "winning_bid_id" "uuid",
    "specifications" "jsonb" DEFAULT '{}'::"jsonb",
    "tax_rate" numeric DEFAULT 18,
    "freight_terms" "text" DEFAULT 'Ex-Factory / FOB'::"text",
    "packaging_details" "text" DEFAULT 'Standard export corrugated pallet packing'::"text",
    "payment_terms" "text" DEFAULT '50% advance, 50% before dispatch'::"text",
    "delivery_location" "text" DEFAULT 'Nhava Sheva Port / Mumbai, India'::"text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


--
-- Name: audit_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE IF NOT EXISTS "public"."audit_logs" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "actor_id" "uuid",
    "action_type" "text" NOT NULL,
    "target_table" "text",
    "target_id" "uuid",
    "details" "jsonb",
    "ip_address" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


--
-- Name: auto_quotations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE IF NOT EXISTS "public"."auto_quotations" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "requirement_id" "uuid" NOT NULL,
    "supplier_company_id" "uuid" NOT NULL,
    "quotation_id" "uuid",
    "buyer_id" "uuid" NOT NULL,
    "status" "text" DEFAULT 'draft'::"text" NOT NULL,
    "unit_price" numeric(14,4) NOT NULL,
    "quantity" numeric(14,4) NOT NULL,
    "quantity_unit" "text",
    "currency" "text" DEFAULT 'INR'::"text" NOT NULL,
    "subtotal" numeric(14,2) NOT NULL,
    "shipping_cost" numeric(14,2) DEFAULT 0 NOT NULL,
    "tax_amount" numeric(14,2) DEFAULT 0 NOT NULL,
    "other_charges" numeric(14,2) DEFAULT 0 NOT NULL,
    "total_amount" numeric(14,2) NOT NULL,
    "product_name" "text" NOT NULL,
    "product_specs" "text",
    "moq" integer DEFAULT 1 NOT NULL,
    "moq_unit" "text" DEFAULT 'Pcs'::"text",
    "delivery_days" integer,
    "estimated_delivery_date" "date",
    "validity_days" integer DEFAULT 30 NOT NULL,
    "valid_until" "date",
    "payment_terms" "text",
    "terms_and_conditions" "text",
    "is_auto_generated" boolean DEFAULT true NOT NULL,
    "auto_sent_at" timestamp with time zone,
    "approved_at" timestamp with time zone,
    "approved_by" "uuid",
    "buyer_action" "text",
    "buyer_action_at" timestamp with time zone,
    "buyer_notes" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "counter_offer_price" numeric(14,4),
    "counter_offer_message" "text",
    "counter_offer_at" timestamp with time zone,
    CONSTRAINT "auto_quotations_buyer_action_check" CHECK ((("buyer_action" = ANY (ARRAY['accepted'::"text", 'rejected'::"text", 'revised_requested'::"text"])) OR ("buyer_action" IS NULL))),
    CONSTRAINT "auto_quotations_status_check" CHECK (("status" = ANY (ARRAY['draft'::"text", 'pending_approval'::"text", 'sent'::"text", 'accepted'::"text", 'rejected'::"text", 'revised_requested'::"text", 'expired'::"text"])))
);


--
-- Name: blocked_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE IF NOT EXISTS "public"."blocked_users" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "blocker_id" "uuid" DEFAULT "auth"."uid"() NOT NULL,
    "blocked_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


--
-- Name: bulk_discount_rules; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE IF NOT EXISTS "public"."bulk_discount_rules" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "product_id" "uuid" NOT NULL,
    "company_id" "uuid" NOT NULL,
    "min_qty" integer NOT NULL,
    "max_qty" integer,
    "discount_pct" numeric(5,2) DEFAULT 0 NOT NULL,
    "fixed_price" numeric(14,2),
    "label" "text",
    "is_active" boolean DEFAULT true NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"()
);


--
-- Name: buyer_profiles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE IF NOT EXISTS "public"."buyer_profiles" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "user_id" "uuid" DEFAULT "auth"."uid"() NOT NULL,
    "company_name" "text" NOT NULL,
    "business_type" "text",
    "gst_number" "text",
    "address" "text",
    "city" "text",
    "state" "text",
    "country" "text" DEFAULT 'India'::"text" NOT NULL,
    "pincode" "text",
    "verified" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "verification_status" "text" DEFAULT 'unverified'::"text" NOT NULL,
    "pan_number" "text",
    "registration_number" "text",
    "gst_doc_url" "text",
    "pan_doc_url" "text",
    "reg_doc_url" "text",
    "verified_at" timestamp with time zone,
    "verified_by" "uuid",
    "rejection_reason" "text",
    "logo_url" "text",
    "banner_url" "text",
    "brand_name" "text",
    "whatsapp_number" "text",
    "website" "text",
    "year_established" integer,
    "description" "text",
    "product_categories" "text"[],
    "target_products" "text"[],
    "moq_requirement" "text",
    "trade_type" "text",
    "countries_served" "text"[],
    "payment_terms" "text"[],
    "shipping_capabilities" "text",
    "onboarding_step" integer DEFAULT 1,
    "onboarding_completed" boolean DEFAULT false,
    "profile_completion" integer DEFAULT 20
);


--
-- Name: buyer_subscriptions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE IF NOT EXISTS "public"."buyer_subscriptions" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "tier" "text" DEFAULT 'basic'::"text" NOT NULL,
    "status" "text" DEFAULT 'active'::"text" NOT NULL,
    "starts_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "ends_at" timestamp with time zone,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "buyer_subscriptions_status_check" CHECK (("status" = ANY (ARRAY['active'::"text", 'expired'::"text", 'cancelled'::"text", 'trial'::"text"]))),
    CONSTRAINT "buyer_subscriptions_tier_check" CHECK (("tier" = ANY (ARRAY['basic'::"text", 'premium'::"text", 'enterprise'::"text"])))
);


--
-- Name: categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE IF NOT EXISTS "public"."categories" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "name" "text" NOT NULL,
    "slug" "text" NOT NULL,
    "parent_id" "uuid",
    "icon" "text",
    "image_url" "text",
    "description" "text",
    "sort_order" integer DEFAULT 0 NOT NULL,
    "is_active" boolean DEFAULT true NOT NULL,
    "product_count" integer DEFAULT 0 NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


--
-- Name: companies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE IF NOT EXISTS "public"."companies" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "owner_id" "uuid" DEFAULT "auth"."uid"() NOT NULL,
    "company_name" "text" NOT NULL,
    "slug" "text" NOT NULL,
    "description" "text",
    "gst_number" "text",
    "iec_number" "text",
    "business_type" "text",
    "website" "text",
    "address" "text",
    "city" "text",
    "state" "text",
    "country" "text" DEFAULT 'India'::"text" NOT NULL,
    "pincode" "text",
    "logo_url" "text",
    "cover_url" "text",
    "verification_status" "public"."verification_status" DEFAULT 'unverified'::"public"."verification_status" NOT NULL,
    "verified_at" timestamp with time zone,
    "is_featured" boolean DEFAULT false NOT NULL,
    "total_products" integer DEFAULT 0 NOT NULL,
    "total_quotes_sent" integer DEFAULT 0 NOT NULL,
    "export_destinations" "text"[],
    "years_in_business" integer,
    "employee_count" "text",
    "annual_turnover" "text",
    "gst_doc_url" "text",
    "iec_doc_url" "text",
    "reg_doc_url" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "banner_url" "text",
    "tagline" "text",
    "year_established" integer,
    "employee_count_range" "text",
    "annual_turnover_range" "text",
    "payment_terms" "text"[] DEFAULT '{}'::"text"[],
    "production_capacity" "text",
    "is_verified" boolean DEFAULT false NOT NULL,
    "verification_notes" "text",
    "rating_avg" numeric(3,2) DEFAULT 0,
    "review_count" integer DEFAULT 0,
    "key_products" "text"[] DEFAULT '{}'::"text"[],
    "moq_policy" "text",
    "packaging_details" "text",
    "profile_completion" integer DEFAULT 0,
    "verification_expiry_at" timestamp with time zone,
    "pan_number" "text",
    "pan_doc_url" "text",
    "factory_doc_url" "text",
    "bank_doc_url" "text",
    "bank_account_name" "text",
    "bank_account_number" "text",
    "bank_ifsc" "text",
    "bank_name" "text",
    "bank_branch" "text",
    "verified_by" "uuid",
    "rejection_reason" "text",
    "wallet_balance" numeric DEFAULT 0 NOT NULL,
    "withdrawable_balance" numeric DEFAULT 0 NOT NULL,
    "total_revenue" numeric DEFAULT 0 NOT NULL,
    "response_rate" numeric DEFAULT 0 NOT NULL,
    "avg_response_hours" numeric DEFAULT 0 NOT NULL,
    "is_blocked" boolean DEFAULT false NOT NULL,
    "lead_credits" integer DEFAULT 0 NOT NULL,
    "commission_balance" numeric(14,2) DEFAULT 0 NOT NULL,
    "gallery_images" "text"[] DEFAULT '{}'::"text"[],
    "is_representative_image" boolean DEFAULT false,
    "has_ai_access" boolean DEFAULT false,
    "flash_sell_until" timestamp with time zone,
    "brand_name" "text",
    "registration_number" "text",
    "whatsapp_number" "text",
    "shipping_capabilities" "text",
    "trade_type" "text",
    "product_categories" "text"[],
    "onboarding_step" integer DEFAULT 1,
    "onboarding_completed" boolean DEFAULT false
);


--
-- Name: company_certifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE IF NOT EXISTS "public"."company_certifications" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "company_id" "uuid" NOT NULL,
    "cert_type" "text" NOT NULL,
    "cert_name" "text" DEFAULT ''::"text" NOT NULL,
    "cert_number" "text",
    "cert_file_url" "text",
    "is_verified" boolean DEFAULT false NOT NULL,
    "verified_at" timestamp with time zone,
    "pending_review" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "company_certifications_cert_type_check" CHECK (("cert_type" = ANY (ARRAY['gst'::"text", 'iec'::"text", 'company_reg'::"text", 'iso'::"text", 'other'::"text"])))
);


--
-- Name: company_reviews; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE IF NOT EXISTS "public"."company_reviews" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "company_id" "uuid" NOT NULL,
    "reviewer_id" "uuid" NOT NULL,
    "rating" integer NOT NULL,
    "review_text" "text",
    "order_id" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "company_reviews_rating_check" CHECK ((("rating" >= 1) AND ("rating" <= 5)))
);


--
-- Name: conversations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE IF NOT EXISTS "public"."conversations" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "requirement_id" "uuid",
    "quotation_id" "uuid",
    "buyer_id" "uuid" NOT NULL,
    "supplier_company_id" "uuid" NOT NULL,
    "supplier_id" "uuid" NOT NULL,
    "last_message" "text",
    "last_message_at" timestamp with time zone,
    "buyer_unread" integer DEFAULT 0 NOT NULL,
    "supplier_unread" integer DEFAULT 0 NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "buyer_blocked" boolean DEFAULT false NOT NULL,
    "supplier_blocked" boolean DEFAULT false NOT NULL,
    "order_id" "uuid",
    "product_id" "uuid"
);


--
-- Name: dispute_actions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE IF NOT EXISTS "public"."dispute_actions" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "dispute_id" "uuid" NOT NULL,
    "actor_id" "uuid" NOT NULL,
    "action" "text" NOT NULL,
    "notes" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


--
-- Name: disputes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE IF NOT EXISTS "public"."disputes" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "order_id" "uuid" NOT NULL,
    "raised_by" "uuid" DEFAULT "auth"."uid"() NOT NULL,
    "against_user_id" "uuid",
    "reason" "public"."dispute_reason" DEFAULT 'other'::"public"."dispute_reason" NOT NULL,
    "description" "text" NOT NULL,
    "evidence_urls" "text"[] DEFAULT '{}'::"text"[],
    "status" "public"."dispute_status" DEFAULT 'open'::"public"."dispute_status" NOT NULL,
    "resolution" "text",
    "resolved_by" "uuid",
    "resolved_at" timestamp with time zone,
    "admin_notes" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


--
-- Name: forward_bids; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE IF NOT EXISTS "public"."forward_bids" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "auction_id" "uuid" NOT NULL,
    "bidder_id" "uuid" DEFAULT "auth"."uid"() NOT NULL,
    "bidder_company_name" "text",
    "bid_amount" numeric NOT NULL,
    "quantity" integer DEFAULT 1 NOT NULL,
    "total_value" numeric NOT NULL,
    "currency" "text" DEFAULT 'INR'::"text" NOT NULL,
    "status" "text" DEFAULT 'accepted'::"text" NOT NULL,
    "server_timestamp" timestamp with time zone DEFAULT "now"() NOT NULL,
    "notes" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


--
-- Name: fraud_alerts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE IF NOT EXISTS "public"."fraud_alerts" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "user_id" "uuid",
    "company_id" "uuid",
    "alert_type" "text" NOT NULL,
    "description" "text" NOT NULL,
    "severity" "public"."fraud_severity" DEFAULT 'low'::"public"."fraud_severity" NOT NULL,
    "is_resolved" boolean DEFAULT false NOT NULL,
    "resolved_by" "uuid",
    "resolved_at" timestamp with time zone,
    "admin_notes" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


--
-- Name: image_sync_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE IF NOT EXISTS "public"."image_sync_logs" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "entity_type" "text" NOT NULL,
    "entity_id" "uuid" NOT NULL,
    "entity_name" "text",
    "pixabay_asset_id" "text",
    "storage_url" "text" NOT NULL,
    "search_query" "text",
    "refresh_cycle" bigint DEFAULT 1,
    "status" "text" DEFAULT 'new_added'::"text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


--
-- Name: instant_quote_requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE IF NOT EXISTS "public"."instant_quote_requests" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "product_id" "uuid" NOT NULL,
    "buyer_id" "uuid" DEFAULT "auth"."uid"() NOT NULL,
    "supplier_company_id" "uuid" NOT NULL,
    "quantity" integer DEFAULT 1 NOT NULL,
    "quantity_unit" "text" DEFAULT 'Pcs'::"text" NOT NULL,
    "message" "text",
    "destination_country" "text",
    "status" "text" DEFAULT 'pending'::"text" NOT NULL,
    "response_price" numeric(14,2),
    "response_notes" "text",
    "responded_at" timestamp with time zone,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "instant_quote_requests_status_check" CHECK (("status" = ANY (ARRAY['pending'::"text", 'responded'::"text", 'closed'::"text"])))
);


--
-- Name: lead_credit_transactions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE IF NOT EXISTS "public"."lead_credit_transactions" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "company_id" "uuid" NOT NULL,
    "type" "text" NOT NULL,
    "credits" integer NOT NULL,
    "amount_inr" numeric(10,2),
    "reference" "text",
    "description" "text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "lead_credit_transactions_type_check" CHECK (("type" = ANY (ARRAY['purchase'::"text", 'consume'::"text", 'refund'::"text", 'bonus'::"text"])))
);


--
-- Name: messages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE IF NOT EXISTS "public"."messages" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "conversation_id" "uuid" NOT NULL,
    "sender_id" "uuid" DEFAULT "auth"."uid"() NOT NULL,
    "content" "text" NOT NULL,
    "attachment_url" "text",
    "is_read" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "attachment_type" "text",
    "attachment_name" "text",
    "is_file" boolean DEFAULT false NOT NULL,
    "read_at" timestamp with time zone
);


--
-- Name: notifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE IF NOT EXISTS "public"."notifications" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "title" "text" NOT NULL,
    "message" "text" NOT NULL,
    "type" "text" DEFAULT 'info'::"text" NOT NULL,
    "is_read" boolean DEFAULT false NOT NULL,
    "link" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "reference_id" "uuid",
    "reference_type" "text",
    "urgency_label" "text"
);


--
-- Name: order_milestone_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE IF NOT EXISTS "public"."order_milestone_logs" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "order_id" "uuid" NOT NULL,
    "milestone" "text" NOT NULL,
    "changed_by" "uuid" NOT NULL,
    "notes" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


--
-- Name: order_milestones; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE IF NOT EXISTS "public"."order_milestones" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "order_id" "uuid" NOT NULL,
    "milestone" "public"."order_milestone" NOT NULL,
    "changed_by" "uuid" NOT NULL,
    "notes" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


--
-- Name: order_number_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE IF NOT EXISTS "public"."order_number_seq"
    START WITH 10001
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: order_status_history; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE IF NOT EXISTS "public"."order_status_history" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "order_id" "uuid" NOT NULL,
    "from_status" "text",
    "to_status" "text" NOT NULL,
    "changed_by" "uuid" NOT NULL,
    "changer_role" "text" NOT NULL,
    "notes" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "order_status_history_changer_role_check" CHECK (("changer_role" = ANY (ARRAY['buyer'::"text", 'supplier'::"text", 'admin'::"text"])))
);


--
-- Name: orders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE IF NOT EXISTS "public"."orders" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "order_number" "text" NOT NULL,
    "quotation_id" "uuid" NOT NULL,
    "buyer_id" "uuid" NOT NULL,
    "supplier_company_id" "uuid" NOT NULL,
    "total_amount" numeric(12,2) NOT NULL,
    "currency" "text" DEFAULT 'INR'::"text" NOT NULL,
    "quantity" integer NOT NULL,
    "status" "public"."order_status" DEFAULT 'confirmed'::"public"."order_status" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "milestone" "public"."order_milestone" DEFAULT 'rfq_created'::"public"."order_milestone" NOT NULL,
    "requirement_id" "uuid",
    "supplier_id" "uuid",
    "notes" "text",
    "cancelled_reason" "text",
    "cancelled_by" "uuid",
    "commission_pct" numeric(5,2) DEFAULT 2.00 NOT NULL,
    "commission_amount" numeric(14,2),
    "commission_status" "text" DEFAULT 'pending'::"text",
    "payment_status" "text" DEFAULT 'pending'::"text",
    "order_status" "text" DEFAULT 'pending'::"text" NOT NULL,
    "tracking_courier" "text",
    "tracking_number" "text",
    "tracking_eta" "date",
    CONSTRAINT "orders_commission_status_check" CHECK (("commission_status" = ANY (ARRAY['pending'::"text", 'collected'::"text", 'waived'::"text"]))),
    CONSTRAINT "orders_order_status_check" CHECK (("order_status" = ANY (ARRAY['pending'::"text", 'confirmed'::"text", 'processing'::"text", 'shipped'::"text", 'delivered'::"text", 'cancelled'::"text"]))),
    CONSTRAINT "orders_payment_status_check" CHECK (("payment_status" = ANY (ARRAY['pending'::"text", 'paid'::"text", 'escrow'::"text", 'released'::"text", 'refunded'::"text"])))
);


--
-- Name: pixabay_search_cache; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE IF NOT EXISTS "public"."pixabay_search_cache" (
    "query_hash" "text" NOT NULL,
    "query" "text" NOT NULL,
    "results" "jsonb" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "expires_at" timestamp with time zone DEFAULT ("now"() + '24:00:00'::interval)
);


--
-- Name: product_inventory; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE IF NOT EXISTS "public"."product_inventory" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "product_id" "uuid" NOT NULL,
    "company_id" "uuid" NOT NULL,
    "stock_qty" integer DEFAULT 0 NOT NULL,
    "reserved_qty" integer DEFAULT 0 NOT NULL,
    "available_qty" integer GENERATED ALWAYS AS (GREATEST(("stock_qty" - "reserved_qty"), 0)) STORED,
    "low_stock_threshold" integer DEFAULT 10 NOT NULL,
    "reorder_qty" integer DEFAULT 50 NOT NULL,
    "warehouse_location" "text",
    "sku" "text",
    "last_restocked_at" timestamp with time zone,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


--
-- Name: product_promotions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE IF NOT EXISTS "public"."product_promotions" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "company_id" "uuid" NOT NULL,
    "product_id" "uuid" NOT NULL,
    "promotion_type" "text" NOT NULL,
    "target_category" "text",
    "target_country" "text",
    "duration_days" integer DEFAULT 7 NOT NULL,
    "daily_budget" numeric(10,2),
    "total_budget" numeric(10,2),
    "status" "text" DEFAULT 'draft'::"text" NOT NULL,
    "est_impressions" integer DEFAULT 0,
    "est_views" integer DEFAULT 0,
    "est_clicks" integer DEFAULT 0,
    "est_leads" integer DEFAULT 0,
    "actual_impressions" integer DEFAULT 0,
    "actual_views" integer DEFAULT 0,
    "actual_clicks" integer DEFAULT 0,
    "actual_leads" integer DEFAULT 0,
    "total_spent" numeric(10,2) DEFAULT 0,
    "payment_amount" numeric(10,2),
    "payment_currency" "text" DEFAULT 'INR'::"text",
    "payment_status" "text" DEFAULT 'pending'::"text",
    "payment_method" "text",
    "payment_ref" "text",
    "paid_at" timestamp with time zone,
    "starts_at" timestamp with time zone,
    "ends_at" timestamp with time zone,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "razorpay_order_id" "text",
    "razorpay_payment_id" "text",
    "razorpay_signature" "text",
    "base_amount" numeric(12,2),
    "gst_amount" numeric(12,2),
    CONSTRAINT "product_promotions_payment_status_check" CHECK (("payment_status" = ANY (ARRAY['pending'::"text", 'paid'::"text", 'failed'::"text", 'refunded'::"text"]))),
    CONSTRAINT "product_promotions_promotion_type_check" CHECK (("promotion_type" = ANY (ARRAY['featured'::"text", 'boost'::"text", 'campaign'::"text"]))),
    CONSTRAINT "product_promotions_status_check" CHECK (("status" = ANY (ARRAY['draft'::"text", 'pending_payment'::"text", 'active'::"text", 'paused'::"text", 'completed'::"text", 'cancelled'::"text"])))
);


--
-- Name: products; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE IF NOT EXISTS "public"."products" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "company_id" "uuid" NOT NULL,
    "category_id" "uuid",
    "name" "text" NOT NULL,
    "slug" "text" NOT NULL,
    "description" "text",
    "specifications" "text",
    "moq" integer DEFAULT 1 NOT NULL,
    "moq_unit" "text" DEFAULT 'pcs'::"text" NOT NULL,
    "price_min" numeric(12,2),
    "price_max" numeric(12,2),
    "price_currency" "text" DEFAULT 'INR'::"text" NOT NULL,
    "images" "text"[],
    "tags" "text"[],
    "export_destinations" "text"[],
    "is_active" boolean DEFAULT true NOT NULL,
    "is_featured" boolean DEFAULT false NOT NULL,
    "view_count" integer DEFAULT 0 NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "is_sponsored" boolean DEFAULT false NOT NULL,
    "is_promoted" boolean DEFAULT false NOT NULL,
    "promotion_type" "text",
    "video_url" "text",
    "brochure_url" "text",
    "has_seller_images" boolean DEFAULT false,
    "is_representative_image" boolean DEFAULT false,
    "representative_storage_url" "text",
    "pixabay_search_query" "text",
    "pixabay_asset_id" "text",
    "matched_tag" "text"
);


--
-- Name: profiles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE IF NOT EXISTS "public"."profiles" (
    "id" "uuid" NOT NULL,
    "email" "text" NOT NULL,
    "full_name" "text",
    "phone" "text",
    "role" "public"."user_role" DEFAULT 'buyer'::"public"."user_role" NOT NULL,
    "status" "public"."account_status" DEFAULT 'active'::"public"."account_status" NOT NULL,
    "avatar_url" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "whatsapp_number" "text",
    "country" "text",
    "state" "text",
    "city" "text",
    "onboarding_completed" boolean DEFAULT false
);


--
-- Name: quotations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE IF NOT EXISTS "public"."quotations" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "requirement_id" "uuid" NOT NULL,
    "supplier_company_id" "uuid" NOT NULL,
    "supplier_id" "uuid" NOT NULL,
    "buyer_id" "uuid" NOT NULL,
    "unit_price" numeric(12,2) NOT NULL,
    "currency" "text" DEFAULT 'INR'::"text" NOT NULL,
    "moq" integer DEFAULT 1 NOT NULL,
    "moq_unit" "text" DEFAULT 'pcs'::"text" NOT NULL,
    "delivery_days" integer,
    "payment_terms" "text",
    "validity_days" integer DEFAULT 30 NOT NULL,
    "notes" "text",
    "status" "public"."quote_status" DEFAULT 'pending'::"public"."quote_status" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "quantity" integer,
    "total_price" numeric,
    "production_days" integer,
    "delivery_terms" "text",
    "attachment_urls" "text"[] DEFAULT '{}'::"text"[],
    "pdf_url" "text",
    "is_draft" boolean DEFAULT false NOT NULL,
    "change_request" "text",
    "shipping_cost" numeric,
    "available_quantity" integer,
    "quotation_number" "text",
    "rfq_id_display" "text",
    "freight_charges" numeric DEFAULT 0,
    "packaging_charges" numeric DEFAULT 0,
    "tax_rate" numeric DEFAULT 18,
    "tax_amount" numeric DEFAULT 0,
    "subtotal" numeric DEFAULT 0,
    "total_quotation_value" numeric DEFAULT 0,
    "delivery_lead_days" integer DEFAULT 7,
    "compliance_documents" "jsonb" DEFAULT '[]'::"jsonb",
    "revision_number" integer DEFAULT 1,
    "is_latest" boolean DEFAULT true,
    "parent_quotation_id" "uuid",
    "spec_match_score" integer DEFAULT 95,
    "terms_accepted" boolean DEFAULT true
);


--
-- Name: reports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE IF NOT EXISTS "public"."reports" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "reporter_id" "uuid" DEFAULT "auth"."uid"() NOT NULL,
    "reported_user_id" "uuid",
    "reported_company_id" "uuid",
    "reported_product_id" "uuid",
    "reason" "text" NOT NULL,
    "description" "text",
    "status" "public"."report_status" DEFAULT 'open'::"public"."report_status" NOT NULL,
    "admin_notes" "text",
    "resolved_at" timestamp with time zone,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


--
-- Name: req_number_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE IF NOT EXISTS "public"."req_number_seq"
    START WITH 1000
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: requirements; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE IF NOT EXISTS "public"."requirements" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "buyer_id" "uuid" DEFAULT "auth"."uid"() NOT NULL,
    "category_id" "uuid",
    "title" "text" NOT NULL,
    "description" "text",
    "specifications" "text",
    "quantity" integer NOT NULL,
    "quantity_unit" "text" DEFAULT 'pcs'::"text" NOT NULL,
    "destination_country" "text",
    "destination_city" "text",
    "deadline" "date",
    "budget_min" numeric(12,2),
    "budget_max" numeric(12,2),
    "currency" "text" DEFAULT 'INR'::"text" NOT NULL,
    "attachment_url" "text",
    "status" "public"."rfq_status" DEFAULT 'active'::"public"."rfq_status" NOT NULL,
    "quote_count" integer DEFAULT 0 NOT NULL,
    "view_count" integer DEFAULT 0 NOT NULL,
    "is_verified_buyer" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "expires_at" timestamp with time zone,
    "matched_count" integer DEFAULT 0 NOT NULL,
    "deal_status" "text" DEFAULT 'active'::"text" NOT NULL,
    "is_urgent" boolean DEFAULT false NOT NULL,
    "req_number" "text",
    "is_reverse_auction" boolean DEFAULT true,
    "auction_end_time" timestamp with time zone DEFAULT ("now"() + '01:00:00'::interval),
    "auction_duration_minutes" integer DEFAULT 60,
    "anti_sniping_enabled" boolean DEFAULT true,
    "target_price_min" numeric DEFAULT 60,
    "target_price_max" numeric DEFAULT 75,
    "delivery_location" "text" DEFAULT 'Tiruppur, Tamil Nadu, India'::"text",
    "lead_time_days" integer DEFAULT 7,
    "payment_terms" "text" DEFAULT '50% advance, 50% before dispatch'::"text",
    "sample_required" "text" DEFAULT 'Yes (5 metre sample)'::"text",
    "interested_suppliers_count" integer DEFAULT 120,
    "awarded_quotation_id" "uuid",
    "awarded_supplier_id" "uuid",
    "images" "text"[] DEFAULT '{}'::"text"[],
    "representative_storage_url" "text",
    CONSTRAINT "requirements_deal_status_check" CHECK (("deal_status" = ANY (ARRAY['active'::"text", 'responses_received'::"text", 'negotiation'::"text", 'deal_finalized'::"text", 'fulfilled'::"text", 'closed'::"text"])))
);


--
-- Name: rfq_lead_views; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE IF NOT EXISTS "public"."rfq_lead_views" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "supplier_id" "uuid" NOT NULL,
    "company_id" "uuid" NOT NULL,
    "requirement_id" "uuid" NOT NULL,
    "viewed_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


--
-- Name: rfq_match_log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE IF NOT EXISTS "public"."rfq_match_log" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "requirement_id" "uuid" NOT NULL,
    "company_id" "uuid" NOT NULL,
    "relevance_score" numeric DEFAULT 0 NOT NULL,
    "notified_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


--
-- Name: rfq_matches; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE IF NOT EXISTS "public"."rfq_matches" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "rfq_id" "uuid" NOT NULL,
    "company_id" "uuid" NOT NULL,
    "match_score" integer NOT NULL,
    "score_category" integer DEFAULT 0 NOT NULL,
    "score_location" integer DEFAULT 0 NOT NULL,
    "score_moq" integer DEFAULT 0 NOT NULL,
    "score_capacity" integer DEFAULT 0 NOT NULL,
    "score_rating" integer DEFAULT 0 NOT NULL,
    "notified_at" timestamp with time zone,
    "response_status" "text" DEFAULT 'pending'::"text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "rfq_matches_match_score_check" CHECK ((("match_score" >= 0) AND ("match_score" <= 100))),
    CONSTRAINT "rfq_matches_response_status_check" CHECK (("response_status" = ANY (ARRAY['pending'::"text", 'quoted'::"text", 'dismissed'::"text", 'expired'::"text"])))
);


--
-- Name: sample_requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE IF NOT EXISTS "public"."sample_requests" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "product_id" "uuid" NOT NULL,
    "buyer_id" "uuid" DEFAULT "auth"."uid"() NOT NULL,
    "supplier_company_id" "uuid" NOT NULL,
    "quantity" integer DEFAULT 1 NOT NULL,
    "purpose" "text",
    "shipping_address" "text",
    "status" "text" DEFAULT 'pending'::"text" NOT NULL,
    "supplier_notes" "text",
    "tracking_number" "text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "sample_requests_status_check" CHECK (("status" = ANY (ARRAY['pending'::"text", 'approved'::"text", 'shipped'::"text", 'delivered'::"text", 'rejected'::"text"])))
);


--
-- Name: saved_manufacturers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE IF NOT EXISTS "public"."saved_manufacturers" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "buyer_id" "uuid" DEFAULT "auth"."uid"() NOT NULL,
    "company_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


--
-- Name: shipping_quotes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE IF NOT EXISTS "public"."shipping_quotes" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "requester_id" "uuid" DEFAULT "auth"."uid"() NOT NULL,
    "origin_city" "text" NOT NULL,
    "origin_country" "text" DEFAULT 'India'::"text" NOT NULL,
    "destination_city" "text" NOT NULL,
    "destination_country" "text" NOT NULL,
    "cargo_type" "text",
    "weight_kg" numeric(10,2),
    "volume_cbm" numeric(10,2),
    "shipment_mode" "text",
    "incoterms" "text",
    "status" "text" DEFAULT 'pending'::"text" NOT NULL,
    "estimated_cost_min" numeric(14,2),
    "estimated_cost_max" numeric(14,2),
    "currency" "text" DEFAULT 'INR'::"text",
    "estimated_days_min" integer,
    "estimated_days_max" integer,
    "notes" "text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "shipping_quotes_shipment_mode_check" CHECK (("shipment_mode" = ANY (ARRAY['air'::"text", 'sea'::"text", 'road'::"text", 'rail'::"text", 'multimodal'::"text"]))),
    CONSTRAINT "shipping_quotes_status_check" CHECK (("status" = ANY (ARRAY['pending'::"text", 'quoted'::"text", 'accepted'::"text", 'expired'::"text"])))
);


--
-- Name: subscription_invoice_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE IF NOT EXISTS "public"."subscription_invoice_seq"
    START WITH 1001
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: subscription_invoices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE IF NOT EXISTS "public"."subscription_invoices" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "invoice_number" "text" DEFAULT ('INV-BSK-'::"text" || "lpad"(("nextval"('"public"."subscription_invoice_seq"'::"regclass"))::"text", 6, '0'::"text")) NOT NULL,
    "company_id" "uuid" NOT NULL,
    "subscription_order_id" "uuid",
    "user_id" "uuid" NOT NULL,
    "plan_tier" "text" NOT NULL,
    "plan_label" "text" NOT NULL,
    "billing_cycle" "text" DEFAULT 'monthly'::"text" NOT NULL,
    "base_amount" numeric(10,2) NOT NULL,
    "cgst_rate" numeric(5,2) DEFAULT 9.00 NOT NULL,
    "sgst_rate" numeric(5,2) DEFAULT 9.00 NOT NULL,
    "igst_rate" numeric(5,2) DEFAULT 0.00 NOT NULL,
    "cgst_amount" numeric(10,2) DEFAULT 0 NOT NULL,
    "sgst_amount" numeric(10,2) DEFAULT 0 NOT NULL,
    "igst_amount" numeric(10,2) DEFAULT 0 NOT NULL,
    "total_amount" numeric(10,2) NOT NULL,
    "bill_to_name" "text",
    "bill_to_company" "text",
    "bill_to_gst" "text",
    "bill_to_address" "text",
    "bill_to_email" "text",
    "razorpay_payment_id" "text",
    "supply_type" "text" DEFAULT 'intra'::"text" NOT NULL,
    "pdf_url" "text",
    "pdf_generated_at" timestamp with time zone,
    "status" "text" DEFAULT 'issued'::"text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "subscription_invoices_status_check" CHECK (("status" = ANY (ARRAY['issued'::"text", 'cancelled'::"text"])))
);


--
-- Name: subscription_orders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE IF NOT EXISTS "public"."subscription_orders" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "company_id" "uuid" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "plan_tier" "text" NOT NULL,
    "plan_label" "text" NOT NULL,
    "price_inr" numeric(10,2) NOT NULL,
    "billing_cycle" "text" DEFAULT 'monthly'::"text" NOT NULL,
    "stripe_session_id" "text",
    "stripe_payment_intent_id" "text",
    "customer_email" "text",
    "status" "text" DEFAULT 'pending'::"text" NOT NULL,
    "completed_at" timestamp with time zone,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "razorpay_order_id" "text",
    "razorpay_payment_id" "text",
    "razorpay_signature" "text",
    CONSTRAINT "subscription_orders_plan_tier_check" CHECK (("plan_tier" = ANY (ARRAY['starter'::"text", 'business'::"text", 'growth'::"text", 'enterprise'::"text"]))),
    CONSTRAINT "subscription_orders_status_check" CHECK (("status" = ANY (ARRAY['pending'::"text", 'completed'::"text", 'cancelled'::"text", 'failed'::"text"])))
);


--
-- Name: subscriptions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE IF NOT EXISTS "public"."subscriptions" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "company_id" "uuid" NOT NULL,
    "tier" "public"."subscription_tier" DEFAULT 'starter'::"public"."subscription_tier" NOT NULL,
    "status" "public"."subscription_status" DEFAULT 'trial'::"public"."subscription_status" NOT NULL,
    "price_inr" numeric(10,2),
    "billing_cycle" "text" DEFAULT 'monthly'::"text" NOT NULL,
    "starts_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "ends_at" timestamp with time zone,
    "stripe_subscription_id" "text",
    "stripe_customer_id" "text",
    "max_products" integer DEFAULT 5 NOT NULL,
    "max_rfq_leads" integer DEFAULT 10 NOT NULL,
    "used_rfq_leads" integer DEFAULT 0 NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "has_ai_access" boolean DEFAULT false
);


--
-- Name: supplier_auto_quote_settings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE IF NOT EXISTS "public"."supplier_auto_quote_settings" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "company_id" "uuid" NOT NULL,
    "auto_send_enabled" boolean DEFAULT false NOT NULL,
    "require_approval" boolean DEFAULT true NOT NULL,
    "default_validity_days" integer DEFAULT 30 NOT NULL,
    "default_payment_terms" "text",
    "default_delivery_days" integer DEFAULT 14,
    "shipping_rate_pct" numeric(5,2) DEFAULT 5.00,
    "tax_rate_pct" numeric(5,2) DEFAULT 18.00,
    "other_charges" numeric(12,2) DEFAULT 0,
    "terms_and_conditions" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


--
-- Name: withdrawal_requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE IF NOT EXISTS "public"."withdrawal_requests" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "company_id" "uuid" NOT NULL,
    "amount" numeric NOT NULL,
    "status" "public"."withdrawal_status" DEFAULT 'pending'::"public"."withdrawal_status" NOT NULL,
    "notes" "text",
    "processed_by" "uuid",
    "processed_at" timestamp with time zone,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


--
-- Name: auction_bids auction_bids_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'auction_bids_pkey'
      AND n.nspname = 'public'
      AND c.relname = 'auction_bids'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."auction_bids"
    ADD CONSTRAINT "auction_bids_pkey" PRIMARY KEY ("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: auction_chats auction_chats_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'auction_chats_pkey'
      AND n.nspname = 'public'
      AND c.relname = 'auction_chats'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."auction_chats"
    ADD CONSTRAINT "auction_chats_pkey" PRIMARY KEY ("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: auctions auctions_auction_number_key; Type: CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'auctions_auction_number_key'
      AND n.nspname = 'public'
      AND c.relname = 'auctions'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."auctions"
    ADD CONSTRAINT "auctions_auction_number_key" UNIQUE ("auction_number");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: auctions auctions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'auctions_pkey'
      AND n.nspname = 'public'
      AND c.relname = 'auctions'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."auctions"
    ADD CONSTRAINT "auctions_pkey" PRIMARY KEY ("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: audit_logs audit_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'audit_logs_pkey'
      AND n.nspname = 'public'
      AND c.relname = 'audit_logs'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."audit_logs"
    ADD CONSTRAINT "audit_logs_pkey" PRIMARY KEY ("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: auto_quotations auto_quotations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'auto_quotations_pkey'
      AND n.nspname = 'public'
      AND c.relname = 'auto_quotations'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."auto_quotations"
    ADD CONSTRAINT "auto_quotations_pkey" PRIMARY KEY ("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: auto_quotations auto_quotations_requirement_id_supplier_company_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'auto_quotations_requirement_id_supplier_company_id_key'
      AND n.nspname = 'public'
      AND c.relname = 'auto_quotations'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."auto_quotations"
    ADD CONSTRAINT "auto_quotations_requirement_id_supplier_company_id_key" UNIQUE ("requirement_id", "supplier_company_id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: blocked_users blocked_users_blocker_id_blocked_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'blocked_users_blocker_id_blocked_id_key'
      AND n.nspname = 'public'
      AND c.relname = 'blocked_users'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."blocked_users"
    ADD CONSTRAINT "blocked_users_blocker_id_blocked_id_key" UNIQUE ("blocker_id", "blocked_id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: blocked_users blocked_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'blocked_users_pkey'
      AND n.nspname = 'public'
      AND c.relname = 'blocked_users'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."blocked_users"
    ADD CONSTRAINT "blocked_users_pkey" PRIMARY KEY ("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: bulk_discount_rules bulk_discount_rules_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'bulk_discount_rules_pkey'
      AND n.nspname = 'public'
      AND c.relname = 'bulk_discount_rules'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."bulk_discount_rules"
    ADD CONSTRAINT "bulk_discount_rules_pkey" PRIMARY KEY ("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: buyer_profiles buyer_profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'buyer_profiles_pkey'
      AND n.nspname = 'public'
      AND c.relname = 'buyer_profiles'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."buyer_profiles"
    ADD CONSTRAINT "buyer_profiles_pkey" PRIMARY KEY ("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: buyer_subscriptions buyer_subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'buyer_subscriptions_pkey'
      AND n.nspname = 'public'
      AND c.relname = 'buyer_subscriptions'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."buyer_subscriptions"
    ADD CONSTRAINT "buyer_subscriptions_pkey" PRIMARY KEY ("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: buyer_subscriptions buyer_subscriptions_user_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'buyer_subscriptions_user_id_key'
      AND n.nspname = 'public'
      AND c.relname = 'buyer_subscriptions'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."buyer_subscriptions"
    ADD CONSTRAINT "buyer_subscriptions_user_id_key" UNIQUE ("user_id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'categories_pkey'
      AND n.nspname = 'public'
      AND c.relname = 'categories'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."categories"
    ADD CONSTRAINT "categories_pkey" PRIMARY KEY ("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: categories categories_slug_key; Type: CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'categories_slug_key'
      AND n.nspname = 'public'
      AND c.relname = 'categories'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."categories"
    ADD CONSTRAINT "categories_slug_key" UNIQUE ("slug");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: companies companies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'companies_pkey'
      AND n.nspname = 'public'
      AND c.relname = 'companies'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."companies"
    ADD CONSTRAINT "companies_pkey" PRIMARY KEY ("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: companies companies_slug_key; Type: CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'companies_slug_key'
      AND n.nspname = 'public'
      AND c.relname = 'companies'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."companies"
    ADD CONSTRAINT "companies_slug_key" UNIQUE ("slug");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: company_certifications company_certifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'company_certifications_pkey'
      AND n.nspname = 'public'
      AND c.relname = 'company_certifications'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."company_certifications"
    ADD CONSTRAINT "company_certifications_pkey" PRIMARY KEY ("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: company_reviews company_reviews_company_id_reviewer_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'company_reviews_company_id_reviewer_id_key'
      AND n.nspname = 'public'
      AND c.relname = 'company_reviews'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."company_reviews"
    ADD CONSTRAINT "company_reviews_company_id_reviewer_id_key" UNIQUE ("company_id", "reviewer_id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: company_reviews company_reviews_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'company_reviews_pkey'
      AND n.nspname = 'public'
      AND c.relname = 'company_reviews'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."company_reviews"
    ADD CONSTRAINT "company_reviews_pkey" PRIMARY KEY ("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: conversations conversations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'conversations_pkey'
      AND n.nspname = 'public'
      AND c.relname = 'conversations'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."conversations"
    ADD CONSTRAINT "conversations_pkey" PRIMARY KEY ("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: dispute_actions dispute_actions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'dispute_actions_pkey'
      AND n.nspname = 'public'
      AND c.relname = 'dispute_actions'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."dispute_actions"
    ADD CONSTRAINT "dispute_actions_pkey" PRIMARY KEY ("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: disputes disputes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'disputes_pkey'
      AND n.nspname = 'public'
      AND c.relname = 'disputes'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."disputes"
    ADD CONSTRAINT "disputes_pkey" PRIMARY KEY ("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: forward_bids forward_bids_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'forward_bids_pkey'
      AND n.nspname = 'public'
      AND c.relname = 'forward_bids'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."forward_bids"
    ADD CONSTRAINT "forward_bids_pkey" PRIMARY KEY ("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: fraud_alerts fraud_alerts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'fraud_alerts_pkey'
      AND n.nspname = 'public'
      AND c.relname = 'fraud_alerts'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."fraud_alerts"
    ADD CONSTRAINT "fraud_alerts_pkey" PRIMARY KEY ("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: image_sync_logs image_sync_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'image_sync_logs_pkey'
      AND n.nspname = 'public'
      AND c.relname = 'image_sync_logs'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."image_sync_logs"
    ADD CONSTRAINT "image_sync_logs_pkey" PRIMARY KEY ("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: instant_quote_requests instant_quote_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'instant_quote_requests_pkey'
      AND n.nspname = 'public'
      AND c.relname = 'instant_quote_requests'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."instant_quote_requests"
    ADD CONSTRAINT "instant_quote_requests_pkey" PRIMARY KEY ("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: lead_credit_transactions lead_credit_transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'lead_credit_transactions_pkey'
      AND n.nspname = 'public'
      AND c.relname = 'lead_credit_transactions'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."lead_credit_transactions"
    ADD CONSTRAINT "lead_credit_transactions_pkey" PRIMARY KEY ("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'messages_pkey'
      AND n.nspname = 'public'
      AND c.relname = 'messages'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."messages"
    ADD CONSTRAINT "messages_pkey" PRIMARY KEY ("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'notifications_pkey'
      AND n.nspname = 'public'
      AND c.relname = 'notifications'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."notifications"
    ADD CONSTRAINT "notifications_pkey" PRIMARY KEY ("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: order_milestone_logs order_milestone_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'order_milestone_logs_pkey'
      AND n.nspname = 'public'
      AND c.relname = 'order_milestone_logs'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."order_milestone_logs"
    ADD CONSTRAINT "order_milestone_logs_pkey" PRIMARY KEY ("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: order_milestones order_milestones_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'order_milestones_pkey'
      AND n.nspname = 'public'
      AND c.relname = 'order_milestones'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."order_milestones"
    ADD CONSTRAINT "order_milestones_pkey" PRIMARY KEY ("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: order_status_history order_status_history_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'order_status_history_pkey'
      AND n.nspname = 'public'
      AND c.relname = 'order_status_history'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."order_status_history"
    ADD CONSTRAINT "order_status_history_pkey" PRIMARY KEY ("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: orders orders_order_number_key; Type: CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'orders_order_number_key'
      AND n.nspname = 'public'
      AND c.relname = 'orders'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."orders"
    ADD CONSTRAINT "orders_order_number_key" UNIQUE ("order_number");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'orders_pkey'
      AND n.nspname = 'public'
      AND c.relname = 'orders'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."orders"
    ADD CONSTRAINT "orders_pkey" PRIMARY KEY ("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: pixabay_search_cache pixabay_search_cache_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'pixabay_search_cache_pkey'
      AND n.nspname = 'public'
      AND c.relname = 'pixabay_search_cache'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."pixabay_search_cache"
    ADD CONSTRAINT "pixabay_search_cache_pkey" PRIMARY KEY ("query_hash");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: product_inventory product_inventory_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'product_inventory_pkey'
      AND n.nspname = 'public'
      AND c.relname = 'product_inventory'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."product_inventory"
    ADD CONSTRAINT "product_inventory_pkey" PRIMARY KEY ("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: product_promotions product_promotions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'product_promotions_pkey'
      AND n.nspname = 'public'
      AND c.relname = 'product_promotions'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."product_promotions"
    ADD CONSTRAINT "product_promotions_pkey" PRIMARY KEY ("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'products_pkey'
      AND n.nspname = 'public'
      AND c.relname = 'products'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."products"
    ADD CONSTRAINT "products_pkey" PRIMARY KEY ("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: products products_slug_key; Type: CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'products_slug_key'
      AND n.nspname = 'public'
      AND c.relname = 'products'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."products"
    ADD CONSTRAINT "products_slug_key" UNIQUE ("slug");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: profiles profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'profiles_pkey'
      AND n.nspname = 'public'
      AND c.relname = 'profiles'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_pkey" PRIMARY KEY ("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: quotations quotations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'quotations_pkey'
      AND n.nspname = 'public'
      AND c.relname = 'quotations'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."quotations"
    ADD CONSTRAINT "quotations_pkey" PRIMARY KEY ("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: reports reports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'reports_pkey'
      AND n.nspname = 'public'
      AND c.relname = 'reports'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."reports"
    ADD CONSTRAINT "reports_pkey" PRIMARY KEY ("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: requirements requirements_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'requirements_pkey'
      AND n.nspname = 'public'
      AND c.relname = 'requirements'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."requirements"
    ADD CONSTRAINT "requirements_pkey" PRIMARY KEY ("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: requirements requirements_req_number_key; Type: CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'requirements_req_number_key'
      AND n.nspname = 'public'
      AND c.relname = 'requirements'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."requirements"
    ADD CONSTRAINT "requirements_req_number_key" UNIQUE ("req_number");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: rfq_lead_views rfq_lead_views_company_id_requirement_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'rfq_lead_views_company_id_requirement_id_key'
      AND n.nspname = 'public'
      AND c.relname = 'rfq_lead_views'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."rfq_lead_views"
    ADD CONSTRAINT "rfq_lead_views_company_id_requirement_id_key" UNIQUE ("company_id", "requirement_id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: rfq_lead_views rfq_lead_views_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'rfq_lead_views_pkey'
      AND n.nspname = 'public'
      AND c.relname = 'rfq_lead_views'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."rfq_lead_views"
    ADD CONSTRAINT "rfq_lead_views_pkey" PRIMARY KEY ("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: rfq_match_log rfq_match_log_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'rfq_match_log_pkey'
      AND n.nspname = 'public'
      AND c.relname = 'rfq_match_log'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."rfq_match_log"
    ADD CONSTRAINT "rfq_match_log_pkey" PRIMARY KEY ("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: rfq_match_log rfq_match_log_requirement_id_company_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'rfq_match_log_requirement_id_company_id_key'
      AND n.nspname = 'public'
      AND c.relname = 'rfq_match_log'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."rfq_match_log"
    ADD CONSTRAINT "rfq_match_log_requirement_id_company_id_key" UNIQUE ("requirement_id", "company_id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: rfq_matches rfq_matches_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'rfq_matches_pkey'
      AND n.nspname = 'public'
      AND c.relname = 'rfq_matches'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."rfq_matches"
    ADD CONSTRAINT "rfq_matches_pkey" PRIMARY KEY ("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: rfq_matches rfq_matches_rfq_id_company_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'rfq_matches_rfq_id_company_id_key'
      AND n.nspname = 'public'
      AND c.relname = 'rfq_matches'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."rfq_matches"
    ADD CONSTRAINT "rfq_matches_rfq_id_company_id_key" UNIQUE ("rfq_id", "company_id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: sample_requests sample_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'sample_requests_pkey'
      AND n.nspname = 'public'
      AND c.relname = 'sample_requests'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."sample_requests"
    ADD CONSTRAINT "sample_requests_pkey" PRIMARY KEY ("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: saved_manufacturers saved_manufacturers_buyer_id_company_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'saved_manufacturers_buyer_id_company_id_key'
      AND n.nspname = 'public'
      AND c.relname = 'saved_manufacturers'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."saved_manufacturers"
    ADD CONSTRAINT "saved_manufacturers_buyer_id_company_id_key" UNIQUE ("buyer_id", "company_id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: saved_manufacturers saved_manufacturers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'saved_manufacturers_pkey'
      AND n.nspname = 'public'
      AND c.relname = 'saved_manufacturers'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."saved_manufacturers"
    ADD CONSTRAINT "saved_manufacturers_pkey" PRIMARY KEY ("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: shipping_quotes shipping_quotes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'shipping_quotes_pkey'
      AND n.nspname = 'public'
      AND c.relname = 'shipping_quotes'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."shipping_quotes"
    ADD CONSTRAINT "shipping_quotes_pkey" PRIMARY KEY ("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: subscription_invoices subscription_invoices_invoice_number_key; Type: CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'subscription_invoices_invoice_number_key'
      AND n.nspname = 'public'
      AND c.relname = 'subscription_invoices'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."subscription_invoices"
    ADD CONSTRAINT "subscription_invoices_invoice_number_key" UNIQUE ("invoice_number");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: subscription_invoices subscription_invoices_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'subscription_invoices_pkey'
      AND n.nspname = 'public'
      AND c.relname = 'subscription_invoices'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."subscription_invoices"
    ADD CONSTRAINT "subscription_invoices_pkey" PRIMARY KEY ("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: subscription_orders subscription_orders_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'subscription_orders_pkey'
      AND n.nspname = 'public'
      AND c.relname = 'subscription_orders'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."subscription_orders"
    ADD CONSTRAINT "subscription_orders_pkey" PRIMARY KEY ("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: subscription_orders subscription_orders_stripe_session_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'subscription_orders_stripe_session_id_key'
      AND n.nspname = 'public'
      AND c.relname = 'subscription_orders'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."subscription_orders"
    ADD CONSTRAINT "subscription_orders_stripe_session_id_key" UNIQUE ("stripe_session_id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: subscriptions subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'subscriptions_pkey'
      AND n.nspname = 'public'
      AND c.relname = 'subscriptions'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."subscriptions"
    ADD CONSTRAINT "subscriptions_pkey" PRIMARY KEY ("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: supplier_auto_quote_settings supplier_auto_quote_settings_company_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'supplier_auto_quote_settings_company_id_key'
      AND n.nspname = 'public'
      AND c.relname = 'supplier_auto_quote_settings'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."supplier_auto_quote_settings"
    ADD CONSTRAINT "supplier_auto_quote_settings_company_id_key" UNIQUE ("company_id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: supplier_auto_quote_settings supplier_auto_quote_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'supplier_auto_quote_settings_pkey'
      AND n.nspname = 'public'
      AND c.relname = 'supplier_auto_quote_settings'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."supplier_auto_quote_settings"
    ADD CONSTRAINT "supplier_auto_quote_settings_pkey" PRIMARY KEY ("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: withdrawal_requests withdrawal_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'withdrawal_requests_pkey'
      AND n.nspname = 'public'
      AND c.relname = 'withdrawal_requests'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."withdrawal_requests"
    ADD CONSTRAINT "withdrawal_requests_pkey" PRIMARY KEY ("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: idx_audit_logs_actor; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX IF NOT EXISTS "idx_audit_logs_actor" ON "public"."audit_logs" USING "btree" ("actor_id");


--
-- Name: idx_audit_logs_created; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX IF NOT EXISTS "idx_audit_logs_created" ON "public"."audit_logs" USING "btree" ("created_at" DESC);


--
-- Name: idx_auto_quotations_buyer; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX IF NOT EXISTS "idx_auto_quotations_buyer" ON "public"."auto_quotations" USING "btree" ("buyer_id");


--
-- Name: idx_auto_quotations_requirement; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX IF NOT EXISTS "idx_auto_quotations_requirement" ON "public"."auto_quotations" USING "btree" ("requirement_id");


--
-- Name: idx_auto_quotations_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX IF NOT EXISTS "idx_auto_quotations_status" ON "public"."auto_quotations" USING "btree" ("status");


--
-- Name: idx_auto_quotations_supplier; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX IF NOT EXISTS "idx_auto_quotations_supplier" ON "public"."auto_quotations" USING "btree" ("supplier_company_id");


--
-- Name: idx_bulk_discount_product; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX IF NOT EXISTS "idx_bulk_discount_product" ON "public"."bulk_discount_rules" USING "btree" ("product_id");


--
-- Name: idx_conv_buyer_supplier_product; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX IF NOT EXISTS "idx_conv_buyer_supplier_product" ON "public"."conversations" USING "btree" ("buyer_id", "supplier_id", "product_id") WHERE ("product_id" IS NOT NULL);


--
-- Name: idx_conv_buyer_supplier_requirement; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX IF NOT EXISTS "idx_conv_buyer_supplier_requirement" ON "public"."conversations" USING "btree" ("buyer_id", "supplier_id", "requirement_id") WHERE (("requirement_id" IS NOT NULL) AND ("product_id" IS NULL));


--
-- Name: idx_disputes_order; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX IF NOT EXISTS "idx_disputes_order" ON "public"."disputes" USING "btree" ("order_id");


--
-- Name: idx_disputes_raised_by; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX IF NOT EXISTS "idx_disputes_raised_by" ON "public"."disputes" USING "btree" ("raised_by");


--
-- Name: idx_fraud_alerts_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX IF NOT EXISTS "idx_fraud_alerts_user" ON "public"."fraud_alerts" USING "btree" ("user_id");


--
-- Name: idx_image_sync_logs_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX IF NOT EXISTS "idx_image_sync_logs_created_at" ON "public"."image_sync_logs" USING "btree" ("created_at" DESC);


--
-- Name: idx_image_sync_logs_entity; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX IF NOT EXISTS "idx_image_sync_logs_entity" ON "public"."image_sync_logs" USING "btree" ("entity_type", "entity_id");


--
-- Name: idx_inventory_company; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX IF NOT EXISTS "idx_inventory_company" ON "public"."product_inventory" USING "btree" ("company_id");


--
-- Name: idx_inventory_product; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX IF NOT EXISTS "idx_inventory_product" ON "public"."product_inventory" USING "btree" ("product_id");


--
-- Name: idx_iqr_buyer; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX IF NOT EXISTS "idx_iqr_buyer" ON "public"."instant_quote_requests" USING "btree" ("buyer_id");


--
-- Name: idx_iqr_supplier; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX IF NOT EXISTS "idx_iqr_supplier" ON "public"."instant_quote_requests" USING "btree" ("supplier_company_id");


--
-- Name: idx_lead_credit_company; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX IF NOT EXISTS "idx_lead_credit_company" ON "public"."lead_credit_transactions" USING "btree" ("company_id");


--
-- Name: idx_milestone_logs_order_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX IF NOT EXISTS "idx_milestone_logs_order_id" ON "public"."order_milestone_logs" USING "btree" ("order_id");


--
-- Name: idx_notifications_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX IF NOT EXISTS "idx_notifications_user" ON "public"."notifications" USING "btree" ("user_id", "is_read", "created_at" DESC);


--
-- Name: idx_order_milestones_order; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX IF NOT EXISTS "idx_order_milestones_order" ON "public"."order_milestones" USING "btree" ("order_id");


--
-- Name: idx_orders_buyer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX IF NOT EXISTS "idx_orders_buyer_id" ON "public"."orders" USING "btree" ("buyer_id");


--
-- Name: idx_orders_quotation_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX IF NOT EXISTS "idx_orders_quotation_id" ON "public"."orders" USING "btree" ("quotation_id");


--
-- Name: idx_orders_supplier_company_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX IF NOT EXISTS "idx_orders_supplier_company_id" ON "public"."orders" USING "btree" ("supplier_company_id");


--
-- Name: idx_product_promotions_company; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX IF NOT EXISTS "idx_product_promotions_company" ON "public"."product_promotions" USING "btree" ("company_id");


--
-- Name: idx_product_promotions_product; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX IF NOT EXISTS "idx_product_promotions_product" ON "public"."product_promotions" USING "btree" ("product_id");


--
-- Name: idx_product_promotions_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX IF NOT EXISTS "idx_product_promotions_status" ON "public"."product_promotions" USING "btree" ("status");


--
-- Name: idx_rfq_match_log_company; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX IF NOT EXISTS "idx_rfq_match_log_company" ON "public"."rfq_match_log" USING "btree" ("company_id");


--
-- Name: idx_rfq_match_log_req; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX IF NOT EXISTS "idx_rfq_match_log_req" ON "public"."rfq_match_log" USING "btree" ("requirement_id");


--
-- Name: idx_sample_requests_buyer; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX IF NOT EXISTS "idx_sample_requests_buyer" ON "public"."sample_requests" USING "btree" ("buyer_id");


--
-- Name: idx_sample_requests_supplier; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX IF NOT EXISTS "idx_sample_requests_supplier" ON "public"."sample_requests" USING "btree" ("supplier_company_id");


--
-- Name: idx_saved_manufacturers_buyer; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX IF NOT EXISTS "idx_saved_manufacturers_buyer" ON "public"."saved_manufacturers" USING "btree" ("buyer_id");


--
-- Name: idx_saved_manufacturers_company; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX IF NOT EXISTS "idx_saved_manufacturers_company" ON "public"."saved_manufacturers" USING "btree" ("company_id");


--
-- Name: idx_shipping_quotes_requester; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX IF NOT EXISTS "idx_shipping_quotes_requester" ON "public"."shipping_quotes" USING "btree" ("requester_id");


--
-- Name: idx_sub_invoices_company; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX IF NOT EXISTS "idx_sub_invoices_company" ON "public"."subscription_invoices" USING "btree" ("company_id");


--
-- Name: idx_sub_invoices_order; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX IF NOT EXISTS "idx_sub_invoices_order" ON "public"."subscription_invoices" USING "btree" ("subscription_order_id");


--
-- Name: idx_sub_invoices_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX IF NOT EXISTS "idx_sub_invoices_user" ON "public"."subscription_invoices" USING "btree" ("user_id");


--
-- Name: idx_sub_orders_company; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX IF NOT EXISTS "idx_sub_orders_company" ON "public"."subscription_orders" USING "btree" ("company_id");


--
-- Name: idx_sub_orders_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX IF NOT EXISTS "idx_sub_orders_status" ON "public"."subscription_orders" USING "btree" ("status");


--
-- Name: idx_sub_orders_stripe; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX IF NOT EXISTS "idx_sub_orders_stripe" ON "public"."subscription_orders" USING "btree" ("stripe_session_id");


--
-- Name: idx_sub_orders_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX IF NOT EXISTS "idx_sub_orders_user" ON "public"."subscription_orders" USING "btree" ("user_id");


--
-- Name: idx_subscription_orders_razorpay_order_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX IF NOT EXISTS "idx_subscription_orders_razorpay_order_id" ON "public"."subscription_orders" USING "btree" ("razorpay_order_id") WHERE ("razorpay_order_id" IS NOT NULL);


--
-- Name: osh_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX IF NOT EXISTS "osh_created_at_idx" ON "public"."order_status_history" USING "btree" ("created_at" DESC);


--
-- Name: osh_order_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX IF NOT EXISTS "osh_order_id_idx" ON "public"."order_status_history" USING "btree" ("order_id");


--
-- Name: rfq_matches_company_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX IF NOT EXISTS "rfq_matches_company_id_idx" ON "public"."rfq_matches" USING "btree" ("company_id");


--
-- Name: rfq_matches_rfq_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX IF NOT EXISTS "rfq_matches_rfq_id_idx" ON "public"."rfq_matches" USING "btree" ("rfq_id");


--
-- Name: rfq_matches_score_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX IF NOT EXISTS "rfq_matches_score_idx" ON "public"."rfq_matches" USING "btree" ("match_score" DESC);


--
-- Name: orders set_order_number; Type: TRIGGER; Schema: public; Owner: -
--

CREATE OR REPLACE TRIGGER "set_order_number" BEFORE INSERT ON "public"."orders" FOR EACH ROW EXECUTE FUNCTION "public"."generate_order_number"();


--
-- Name: orders trg_generate_order_number; Type: TRIGGER; Schema: public; Owner: -
--

CREATE OR REPLACE TRIGGER "trg_generate_order_number" BEFORE INSERT ON "public"."orders" FOR EACH ROW EXECUTE FUNCTION "public"."generate_order_number"();


--
-- Name: orders trg_log_milestone; Type: TRIGGER; Schema: public; Owner: -
--

CREATE OR REPLACE TRIGGER "trg_log_milestone" AFTER UPDATE ON "public"."orders" FOR EACH ROW EXECUTE FUNCTION "public"."log_order_milestone"();


--
-- Name: companies trg_match_on_new_manufacturer; Type: TRIGGER; Schema: public; Owner: -
--

CREATE OR REPLACE TRIGGER "trg_match_on_new_manufacturer" AFTER INSERT ON "public"."companies" FOR EACH ROW EXECUTE FUNCTION "public"."trigger_match_on_new_manufacturer"();


--
-- Name: quotations trg_notify_buyer_on_quote; Type: TRIGGER; Schema: public; Owner: -
--

CREATE OR REPLACE TRIGGER "trg_notify_buyer_on_quote" AFTER INSERT ON "public"."quotations" FOR EACH ROW EXECUTE FUNCTION "public"."notify_buyer_on_quote"();


--
-- Name: products trg_notify_followers; Type: TRIGGER; Schema: public; Owner: -
--

CREATE OR REPLACE TRIGGER "trg_notify_followers" AFTER INSERT ON "public"."products" FOR EACH ROW EXECUTE FUNCTION "public"."notify_followers_on_product"();


--
-- Name: messages trg_notify_new_message; Type: TRIGGER; Schema: public; Owner: -
--

CREATE OR REPLACE TRIGGER "trg_notify_new_message" AFTER INSERT ON "public"."messages" FOR EACH ROW EXECUTE FUNCTION "public"."trg_notify_new_message_fn"();


--
-- Name: quotations trg_notify_new_quotation; Type: TRIGGER; Schema: public; Owner: -
--

CREATE OR REPLACE TRIGGER "trg_notify_new_quotation" AFTER INSERT ON "public"."quotations" FOR EACH ROW EXECUTE FUNCTION "public"."trg_notify_new_quotation_fn"();


--
-- Name: requirements trg_notify_supplier_on_deal_status; Type: TRIGGER; Schema: public; Owner: -
--

CREATE OR REPLACE TRIGGER "trg_notify_supplier_on_deal_status" AFTER UPDATE ON "public"."requirements" FOR EACH ROW EXECUTE FUNCTION "public"."notify_supplier_on_deal_status"();


--
-- Name: orders trg_orders_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE OR REPLACE TRIGGER "trg_orders_updated_at" BEFORE UPDATE ON "public"."orders" FOR EACH ROW EXECUTE FUNCTION "public"."update_orders_updated_at"();


--
-- Name: requirements trg_req_number; Type: TRIGGER; Schema: public; Owner: -
--

CREATE OR REPLACE TRIGGER "trg_req_number" BEFORE INSERT ON "public"."requirements" FOR EACH ROW EXECUTE FUNCTION "public"."generate_req_number"();


--
-- Name: requirements trg_rfq_matching_on_new_req; Type: TRIGGER; Schema: public; Owner: -
--

CREATE OR REPLACE TRIGGER "trg_rfq_matching_on_new_req" AFTER INSERT ON "public"."requirements" FOR EACH ROW EXECUTE FUNCTION "public"."trigger_rfq_matching_on_new_req"();


--
-- Name: messages trg_update_conv_on_message; Type: TRIGGER; Schema: public; Owner: -
--

CREATE OR REPLACE TRIGGER "trg_update_conv_on_message" AFTER INSERT ON "public"."messages" FOR EACH ROW EXECUTE FUNCTION "public"."update_conv_on_message"();


--
-- Name: quotations trg_update_response_rate; Type: TRIGGER; Schema: public; Owner: -
--

CREATE OR REPLACE TRIGGER "trg_update_response_rate" AFTER INSERT OR UPDATE ON "public"."quotations" FOR EACH ROW EXECUTE FUNCTION "public"."update_company_response_rate"();


--
-- Name: quotations trg_verify_quotation_subscription; Type: TRIGGER; Schema: public; Owner: -
--

CREATE OR REPLACE TRIGGER "trg_verify_quotation_subscription" BEFORE INSERT ON "public"."quotations" FOR EACH ROW EXECUTE FUNCTION "public"."trg_check_quotation_subscription"();


--
-- Name: auction_bids auction_bids_auction_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'auction_bids_auction_id_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'auction_bids'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."auction_bids"
    ADD CONSTRAINT "auction_bids_auction_id_fkey" FOREIGN KEY ("auction_id") REFERENCES "public"."auctions"("id") ON DELETE CASCADE;
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: auction_bids auction_bids_bidder_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'auction_bids_bidder_company_id_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'auction_bids'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."auction_bids"
    ADD CONSTRAINT "auction_bids_bidder_company_id_fkey" FOREIGN KEY ("bidder_company_id") REFERENCES "public"."companies"("id") ON DELETE SET NULL;
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: auction_bids auction_bids_bidder_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'auction_bids_bidder_user_id_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'auction_bids'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."auction_bids"
    ADD CONSTRAINT "auction_bids_bidder_user_id_fkey" FOREIGN KEY ("bidder_user_id") REFERENCES "auth"."users"("id") ON DELETE SET NULL;
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: auctions auctions_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'auctions_category_id_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'auctions'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."auctions"
    ADD CONSTRAINT "auctions_category_id_fkey" FOREIGN KEY ("category_id") REFERENCES "public"."categories"("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: auctions auctions_highest_bidder_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'auctions_highest_bidder_id_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'auctions'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."auctions"
    ADD CONSTRAINT "auctions_highest_bidder_id_fkey" FOREIGN KEY ("highest_bidder_id") REFERENCES "public"."profiles"("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: auctions auctions_seller_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'auctions_seller_company_id_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'auctions'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."auctions"
    ADD CONSTRAINT "auctions_seller_company_id_fkey" FOREIGN KEY ("seller_company_id") REFERENCES "public"."companies"("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: auctions auctions_seller_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'auctions_seller_id_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'auctions'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."auctions"
    ADD CONSTRAINT "auctions_seller_id_fkey" FOREIGN KEY ("seller_id") REFERENCES "public"."profiles"("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: auctions auctions_winner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'auctions_winner_id_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'auctions'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."auctions"
    ADD CONSTRAINT "auctions_winner_id_fkey" FOREIGN KEY ("winner_id") REFERENCES "public"."profiles"("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: audit_logs audit_logs_actor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'audit_logs_actor_id_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'audit_logs'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."audit_logs"
    ADD CONSTRAINT "audit_logs_actor_id_fkey" FOREIGN KEY ("actor_id") REFERENCES "public"."profiles"("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: auto_quotations auto_quotations_quotation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'auto_quotations_quotation_id_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'auto_quotations'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."auto_quotations"
    ADD CONSTRAINT "auto_quotations_quotation_id_fkey" FOREIGN KEY ("quotation_id") REFERENCES "public"."quotations"("id") ON DELETE SET NULL;
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: auto_quotations auto_quotations_requirement_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'auto_quotations_requirement_id_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'auto_quotations'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."auto_quotations"
    ADD CONSTRAINT "auto_quotations_requirement_id_fkey" FOREIGN KEY ("requirement_id") REFERENCES "public"."requirements"("id") ON DELETE CASCADE;
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: auto_quotations auto_quotations_supplier_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'auto_quotations_supplier_company_id_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'auto_quotations'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."auto_quotations"
    ADD CONSTRAINT "auto_quotations_supplier_company_id_fkey" FOREIGN KEY ("supplier_company_id") REFERENCES "public"."companies"("id") ON DELETE CASCADE;
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: blocked_users blocked_users_blocked_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'blocked_users_blocked_id_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'blocked_users'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."blocked_users"
    ADD CONSTRAINT "blocked_users_blocked_id_fkey" FOREIGN KEY ("blocked_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: blocked_users blocked_users_blocker_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'blocked_users_blocker_id_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'blocked_users'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."blocked_users"
    ADD CONSTRAINT "blocked_users_blocker_id_fkey" FOREIGN KEY ("blocker_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: bulk_discount_rules bulk_discount_rules_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'bulk_discount_rules_company_id_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'bulk_discount_rules'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."bulk_discount_rules"
    ADD CONSTRAINT "bulk_discount_rules_company_id_fkey" FOREIGN KEY ("company_id") REFERENCES "public"."companies"("id") ON DELETE CASCADE;
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: bulk_discount_rules bulk_discount_rules_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'bulk_discount_rules_product_id_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'bulk_discount_rules'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."bulk_discount_rules"
    ADD CONSTRAINT "bulk_discount_rules_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "public"."products"("id") ON DELETE CASCADE;
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: buyer_profiles buyer_profiles_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'buyer_profiles_user_id_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'buyer_profiles'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."buyer_profiles"
    ADD CONSTRAINT "buyer_profiles_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: buyer_profiles buyer_profiles_verified_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'buyer_profiles_verified_by_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'buyer_profiles'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."buyer_profiles"
    ADD CONSTRAINT "buyer_profiles_verified_by_fkey" FOREIGN KEY ("verified_by") REFERENCES "public"."profiles"("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: buyer_subscriptions buyer_subscriptions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'buyer_subscriptions_user_id_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'buyer_subscriptions'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."buyer_subscriptions"
    ADD CONSTRAINT "buyer_subscriptions_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: categories categories_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'categories_parent_id_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'categories'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."categories"
    ADD CONSTRAINT "categories_parent_id_fkey" FOREIGN KEY ("parent_id") REFERENCES "public"."categories"("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: companies companies_owner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'companies_owner_id_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'companies'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."companies"
    ADD CONSTRAINT "companies_owner_id_fkey" FOREIGN KEY ("owner_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: companies companies_verified_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'companies_verified_by_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'companies'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."companies"
    ADD CONSTRAINT "companies_verified_by_fkey" FOREIGN KEY ("verified_by") REFERENCES "public"."profiles"("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: company_certifications company_certifications_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'company_certifications_company_id_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'company_certifications'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."company_certifications"
    ADD CONSTRAINT "company_certifications_company_id_fkey" FOREIGN KEY ("company_id") REFERENCES "public"."companies"("id") ON DELETE CASCADE;
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: company_reviews company_reviews_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'company_reviews_company_id_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'company_reviews'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."company_reviews"
    ADD CONSTRAINT "company_reviews_company_id_fkey" FOREIGN KEY ("company_id") REFERENCES "public"."companies"("id") ON DELETE CASCADE;
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: company_reviews company_reviews_reviewer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'company_reviews_reviewer_id_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'company_reviews'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."company_reviews"
    ADD CONSTRAINT "company_reviews_reviewer_id_fkey" FOREIGN KEY ("reviewer_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: conversations conversations_buyer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'conversations_buyer_id_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'conversations'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."conversations"
    ADD CONSTRAINT "conversations_buyer_id_fkey" FOREIGN KEY ("buyer_id") REFERENCES "public"."profiles"("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: conversations conversations_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'conversations_order_id_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'conversations'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."conversations"
    ADD CONSTRAINT "conversations_order_id_fkey" FOREIGN KEY ("order_id") REFERENCES "public"."orders"("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: conversations conversations_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'conversations_product_id_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'conversations'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."conversations"
    ADD CONSTRAINT "conversations_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "public"."products"("id") ON DELETE SET NULL;
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: conversations conversations_quotation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'conversations_quotation_id_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'conversations'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."conversations"
    ADD CONSTRAINT "conversations_quotation_id_fkey" FOREIGN KEY ("quotation_id") REFERENCES "public"."quotations"("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: conversations conversations_requirement_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'conversations_requirement_id_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'conversations'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."conversations"
    ADD CONSTRAINT "conversations_requirement_id_fkey" FOREIGN KEY ("requirement_id") REFERENCES "public"."requirements"("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: conversations conversations_supplier_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'conversations_supplier_company_id_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'conversations'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."conversations"
    ADD CONSTRAINT "conversations_supplier_company_id_fkey" FOREIGN KEY ("supplier_company_id") REFERENCES "public"."companies"("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: conversations conversations_supplier_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'conversations_supplier_id_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'conversations'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."conversations"
    ADD CONSTRAINT "conversations_supplier_id_fkey" FOREIGN KEY ("supplier_id") REFERENCES "public"."profiles"("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: dispute_actions dispute_actions_actor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'dispute_actions_actor_id_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'dispute_actions'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."dispute_actions"
    ADD CONSTRAINT "dispute_actions_actor_id_fkey" FOREIGN KEY ("actor_id") REFERENCES "public"."profiles"("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: dispute_actions dispute_actions_dispute_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'dispute_actions_dispute_id_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'dispute_actions'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."dispute_actions"
    ADD CONSTRAINT "dispute_actions_dispute_id_fkey" FOREIGN KEY ("dispute_id") REFERENCES "public"."disputes"("id") ON DELETE CASCADE;
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: disputes disputes_against_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'disputes_against_user_id_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'disputes'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."disputes"
    ADD CONSTRAINT "disputes_against_user_id_fkey" FOREIGN KEY ("against_user_id") REFERENCES "public"."profiles"("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: disputes disputes_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'disputes_order_id_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'disputes'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."disputes"
    ADD CONSTRAINT "disputes_order_id_fkey" FOREIGN KEY ("order_id") REFERENCES "public"."orders"("id") ON DELETE CASCADE;
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: disputes disputes_raised_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'disputes_raised_by_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'disputes'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."disputes"
    ADD CONSTRAINT "disputes_raised_by_fkey" FOREIGN KEY ("raised_by") REFERENCES "public"."profiles"("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: disputes disputes_resolved_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'disputes_resolved_by_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'disputes'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."disputes"
    ADD CONSTRAINT "disputes_resolved_by_fkey" FOREIGN KEY ("resolved_by") REFERENCES "public"."profiles"("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: forward_bids forward_bids_auction_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'forward_bids_auction_id_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'forward_bids'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."forward_bids"
    ADD CONSTRAINT "forward_bids_auction_id_fkey" FOREIGN KEY ("auction_id") REFERENCES "public"."auctions"("id") ON DELETE CASCADE;
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: fraud_alerts fraud_alerts_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'fraud_alerts_company_id_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'fraud_alerts'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."fraud_alerts"
    ADD CONSTRAINT "fraud_alerts_company_id_fkey" FOREIGN KEY ("company_id") REFERENCES "public"."companies"("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: fraud_alerts fraud_alerts_resolved_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'fraud_alerts_resolved_by_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'fraud_alerts'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."fraud_alerts"
    ADD CONSTRAINT "fraud_alerts_resolved_by_fkey" FOREIGN KEY ("resolved_by") REFERENCES "public"."profiles"("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: fraud_alerts fraud_alerts_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'fraud_alerts_user_id_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'fraud_alerts'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."fraud_alerts"
    ADD CONSTRAINT "fraud_alerts_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."profiles"("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: instant_quote_requests instant_quote_requests_buyer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'instant_quote_requests_buyer_id_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'instant_quote_requests'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."instant_quote_requests"
    ADD CONSTRAINT "instant_quote_requests_buyer_id_fkey" FOREIGN KEY ("buyer_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: instant_quote_requests instant_quote_requests_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'instant_quote_requests_product_id_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'instant_quote_requests'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."instant_quote_requests"
    ADD CONSTRAINT "instant_quote_requests_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "public"."products"("id") ON DELETE CASCADE;
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: instant_quote_requests instant_quote_requests_supplier_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'instant_quote_requests_supplier_company_id_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'instant_quote_requests'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."instant_quote_requests"
    ADD CONSTRAINT "instant_quote_requests_supplier_company_id_fkey" FOREIGN KEY ("supplier_company_id") REFERENCES "public"."companies"("id") ON DELETE CASCADE;
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: lead_credit_transactions lead_credit_transactions_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'lead_credit_transactions_company_id_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'lead_credit_transactions'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."lead_credit_transactions"
    ADD CONSTRAINT "lead_credit_transactions_company_id_fkey" FOREIGN KEY ("company_id") REFERENCES "public"."companies"("id") ON DELETE CASCADE;
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: messages messages_conversation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'messages_conversation_id_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'messages'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."messages"
    ADD CONSTRAINT "messages_conversation_id_fkey" FOREIGN KEY ("conversation_id") REFERENCES "public"."conversations"("id") ON DELETE CASCADE;
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: messages messages_sender_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'messages_sender_id_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'messages'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."messages"
    ADD CONSTRAINT "messages_sender_id_fkey" FOREIGN KEY ("sender_id") REFERENCES "public"."profiles"("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: notifications notifications_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'notifications_user_id_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'notifications'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."notifications"
    ADD CONSTRAINT "notifications_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: order_milestone_logs order_milestone_logs_changed_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'order_milestone_logs_changed_by_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'order_milestone_logs'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."order_milestone_logs"
    ADD CONSTRAINT "order_milestone_logs_changed_by_fkey" FOREIGN KEY ("changed_by") REFERENCES "auth"."users"("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: order_milestone_logs order_milestone_logs_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'order_milestone_logs_order_id_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'order_milestone_logs'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."order_milestone_logs"
    ADD CONSTRAINT "order_milestone_logs_order_id_fkey" FOREIGN KEY ("order_id") REFERENCES "public"."orders"("id") ON DELETE CASCADE;
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: order_milestones order_milestones_changed_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'order_milestones_changed_by_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'order_milestones'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."order_milestones"
    ADD CONSTRAINT "order_milestones_changed_by_fkey" FOREIGN KEY ("changed_by") REFERENCES "public"."profiles"("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: order_milestones order_milestones_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'order_milestones_order_id_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'order_milestones'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."order_milestones"
    ADD CONSTRAINT "order_milestones_order_id_fkey" FOREIGN KEY ("order_id") REFERENCES "public"."orders"("id") ON DELETE CASCADE;
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: order_status_history order_status_history_changed_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'order_status_history_changed_by_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'order_status_history'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."order_status_history"
    ADD CONSTRAINT "order_status_history_changed_by_fkey" FOREIGN KEY ("changed_by") REFERENCES "auth"."users"("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: order_status_history order_status_history_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'order_status_history_order_id_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'order_status_history'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."order_status_history"
    ADD CONSTRAINT "order_status_history_order_id_fkey" FOREIGN KEY ("order_id") REFERENCES "public"."orders"("id") ON DELETE CASCADE;
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: orders orders_buyer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'orders_buyer_id_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'orders'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."orders"
    ADD CONSTRAINT "orders_buyer_id_fkey" FOREIGN KEY ("buyer_id") REFERENCES "public"."profiles"("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: orders orders_cancelled_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'orders_cancelled_by_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'orders'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."orders"
    ADD CONSTRAINT "orders_cancelled_by_fkey" FOREIGN KEY ("cancelled_by") REFERENCES "public"."profiles"("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: orders orders_quotation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'orders_quotation_id_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'orders'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."orders"
    ADD CONSTRAINT "orders_quotation_id_fkey" FOREIGN KEY ("quotation_id") REFERENCES "public"."quotations"("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: orders orders_requirement_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'orders_requirement_id_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'orders'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."orders"
    ADD CONSTRAINT "orders_requirement_id_fkey" FOREIGN KEY ("requirement_id") REFERENCES "public"."requirements"("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: orders orders_supplier_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'orders_supplier_company_id_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'orders'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."orders"
    ADD CONSTRAINT "orders_supplier_company_id_fkey" FOREIGN KEY ("supplier_company_id") REFERENCES "public"."companies"("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: orders orders_supplier_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'orders_supplier_id_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'orders'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."orders"
    ADD CONSTRAINT "orders_supplier_id_fkey" FOREIGN KEY ("supplier_id") REFERENCES "public"."profiles"("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: product_inventory product_inventory_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'product_inventory_company_id_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'product_inventory'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."product_inventory"
    ADD CONSTRAINT "product_inventory_company_id_fkey" FOREIGN KEY ("company_id") REFERENCES "public"."companies"("id") ON DELETE CASCADE;
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: product_inventory product_inventory_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'product_inventory_product_id_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'product_inventory'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."product_inventory"
    ADD CONSTRAINT "product_inventory_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "public"."products"("id") ON DELETE CASCADE;
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: product_promotions product_promotions_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'product_promotions_company_id_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'product_promotions'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."product_promotions"
    ADD CONSTRAINT "product_promotions_company_id_fkey" FOREIGN KEY ("company_id") REFERENCES "public"."companies"("id") ON DELETE CASCADE;
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: product_promotions product_promotions_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'product_promotions_product_id_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'product_promotions'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."product_promotions"
    ADD CONSTRAINT "product_promotions_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "public"."products"("id") ON DELETE CASCADE;
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: products products_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'products_category_id_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'products'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."products"
    ADD CONSTRAINT "products_category_id_fkey" FOREIGN KEY ("category_id") REFERENCES "public"."categories"("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: products products_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'products_company_id_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'products'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."products"
    ADD CONSTRAINT "products_company_id_fkey" FOREIGN KEY ("company_id") REFERENCES "public"."companies"("id") ON DELETE CASCADE;
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: profiles profiles_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'profiles_id_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'profiles'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_id_fkey" FOREIGN KEY ("id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: quotations quotations_buyer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'quotations_buyer_id_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'quotations'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."quotations"
    ADD CONSTRAINT "quotations_buyer_id_fkey" FOREIGN KEY ("buyer_id") REFERENCES "public"."profiles"("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: quotations quotations_requirement_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'quotations_requirement_id_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'quotations'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."quotations"
    ADD CONSTRAINT "quotations_requirement_id_fkey" FOREIGN KEY ("requirement_id") REFERENCES "public"."requirements"("id") ON DELETE CASCADE;
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: quotations quotations_supplier_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'quotations_supplier_company_id_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'quotations'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."quotations"
    ADD CONSTRAINT "quotations_supplier_company_id_fkey" FOREIGN KEY ("supplier_company_id") REFERENCES "public"."companies"("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: quotations quotations_supplier_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'quotations_supplier_id_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'quotations'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."quotations"
    ADD CONSTRAINT "quotations_supplier_id_fkey" FOREIGN KEY ("supplier_id") REFERENCES "public"."profiles"("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: reports reports_reported_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'reports_reported_company_id_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'reports'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."reports"
    ADD CONSTRAINT "reports_reported_company_id_fkey" FOREIGN KEY ("reported_company_id") REFERENCES "public"."companies"("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: reports reports_reported_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'reports_reported_product_id_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'reports'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."reports"
    ADD CONSTRAINT "reports_reported_product_id_fkey" FOREIGN KEY ("reported_product_id") REFERENCES "public"."products"("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: reports reports_reported_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'reports_reported_user_id_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'reports'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."reports"
    ADD CONSTRAINT "reports_reported_user_id_fkey" FOREIGN KEY ("reported_user_id") REFERENCES "public"."profiles"("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: reports reports_reporter_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'reports_reporter_id_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'reports'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."reports"
    ADD CONSTRAINT "reports_reporter_id_fkey" FOREIGN KEY ("reporter_id") REFERENCES "public"."profiles"("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: requirements requirements_buyer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'requirements_buyer_id_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'requirements'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."requirements"
    ADD CONSTRAINT "requirements_buyer_id_fkey" FOREIGN KEY ("buyer_id") REFERENCES "public"."profiles"("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: requirements requirements_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'requirements_category_id_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'requirements'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."requirements"
    ADD CONSTRAINT "requirements_category_id_fkey" FOREIGN KEY ("category_id") REFERENCES "public"."categories"("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: rfq_lead_views rfq_lead_views_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'rfq_lead_views_company_id_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'rfq_lead_views'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."rfq_lead_views"
    ADD CONSTRAINT "rfq_lead_views_company_id_fkey" FOREIGN KEY ("company_id") REFERENCES "public"."companies"("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: rfq_lead_views rfq_lead_views_requirement_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'rfq_lead_views_requirement_id_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'rfq_lead_views'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."rfq_lead_views"
    ADD CONSTRAINT "rfq_lead_views_requirement_id_fkey" FOREIGN KEY ("requirement_id") REFERENCES "public"."requirements"("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: rfq_lead_views rfq_lead_views_supplier_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'rfq_lead_views_supplier_id_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'rfq_lead_views'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."rfq_lead_views"
    ADD CONSTRAINT "rfq_lead_views_supplier_id_fkey" FOREIGN KEY ("supplier_id") REFERENCES "public"."profiles"("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: rfq_match_log rfq_match_log_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'rfq_match_log_company_id_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'rfq_match_log'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."rfq_match_log"
    ADD CONSTRAINT "rfq_match_log_company_id_fkey" FOREIGN KEY ("company_id") REFERENCES "public"."companies"("id") ON DELETE CASCADE;
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: rfq_match_log rfq_match_log_requirement_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'rfq_match_log_requirement_id_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'rfq_match_log'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."rfq_match_log"
    ADD CONSTRAINT "rfq_match_log_requirement_id_fkey" FOREIGN KEY ("requirement_id") REFERENCES "public"."requirements"("id") ON DELETE CASCADE;
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: rfq_matches rfq_matches_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'rfq_matches_company_id_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'rfq_matches'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."rfq_matches"
    ADD CONSTRAINT "rfq_matches_company_id_fkey" FOREIGN KEY ("company_id") REFERENCES "public"."companies"("id") ON DELETE CASCADE;
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: rfq_matches rfq_matches_rfq_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'rfq_matches_rfq_id_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'rfq_matches'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."rfq_matches"
    ADD CONSTRAINT "rfq_matches_rfq_id_fkey" FOREIGN KEY ("rfq_id") REFERENCES "public"."requirements"("id") ON DELETE CASCADE;
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: sample_requests sample_requests_buyer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'sample_requests_buyer_id_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'sample_requests'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."sample_requests"
    ADD CONSTRAINT "sample_requests_buyer_id_fkey" FOREIGN KEY ("buyer_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: sample_requests sample_requests_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'sample_requests_product_id_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'sample_requests'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."sample_requests"
    ADD CONSTRAINT "sample_requests_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "public"."products"("id") ON DELETE CASCADE;
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: sample_requests sample_requests_supplier_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'sample_requests_supplier_company_id_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'sample_requests'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."sample_requests"
    ADD CONSTRAINT "sample_requests_supplier_company_id_fkey" FOREIGN KEY ("supplier_company_id") REFERENCES "public"."companies"("id") ON DELETE CASCADE;
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: saved_manufacturers saved_manufacturers_buyer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'saved_manufacturers_buyer_id_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'saved_manufacturers'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."saved_manufacturers"
    ADD CONSTRAINT "saved_manufacturers_buyer_id_fkey" FOREIGN KEY ("buyer_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: saved_manufacturers saved_manufacturers_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'saved_manufacturers_company_id_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'saved_manufacturers'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."saved_manufacturers"
    ADD CONSTRAINT "saved_manufacturers_company_id_fkey" FOREIGN KEY ("company_id") REFERENCES "public"."companies"("id") ON DELETE CASCADE;
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: shipping_quotes shipping_quotes_requester_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'shipping_quotes_requester_id_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'shipping_quotes'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."shipping_quotes"
    ADD CONSTRAINT "shipping_quotes_requester_id_fkey" FOREIGN KEY ("requester_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: subscription_invoices subscription_invoices_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'subscription_invoices_company_id_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'subscription_invoices'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."subscription_invoices"
    ADD CONSTRAINT "subscription_invoices_company_id_fkey" FOREIGN KEY ("company_id") REFERENCES "public"."companies"("id") ON DELETE CASCADE;
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: subscription_invoices subscription_invoices_subscription_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'subscription_invoices_subscription_order_id_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'subscription_invoices'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."subscription_invoices"
    ADD CONSTRAINT "subscription_invoices_subscription_order_id_fkey" FOREIGN KEY ("subscription_order_id") REFERENCES "public"."subscription_orders"("id") ON DELETE SET NULL;
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: subscription_invoices subscription_invoices_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'subscription_invoices_user_id_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'subscription_invoices'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."subscription_invoices"
    ADD CONSTRAINT "subscription_invoices_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: subscription_orders subscription_orders_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'subscription_orders_company_id_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'subscription_orders'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."subscription_orders"
    ADD CONSTRAINT "subscription_orders_company_id_fkey" FOREIGN KEY ("company_id") REFERENCES "public"."companies"("id") ON DELETE CASCADE;
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: subscription_orders subscription_orders_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'subscription_orders_user_id_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'subscription_orders'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."subscription_orders"
    ADD CONSTRAINT "subscription_orders_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: subscriptions subscriptions_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'subscriptions_company_id_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'subscriptions'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."subscriptions"
    ADD CONSTRAINT "subscriptions_company_id_fkey" FOREIGN KEY ("company_id") REFERENCES "public"."companies"("id") ON DELETE CASCADE;
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: supplier_auto_quote_settings supplier_auto_quote_settings_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'supplier_auto_quote_settings_company_id_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'supplier_auto_quote_settings'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."supplier_auto_quote_settings"
    ADD CONSTRAINT "supplier_auto_quote_settings_company_id_fkey" FOREIGN KEY ("company_id") REFERENCES "public"."companies"("id") ON DELETE CASCADE;
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: withdrawal_requests withdrawal_requests_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'withdrawal_requests_company_id_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'withdrawal_requests'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."withdrawal_requests"
    ADD CONSTRAINT "withdrawal_requests_company_id_fkey" FOREIGN KEY ("company_id") REFERENCES "public"."companies"("id") ON DELETE CASCADE;
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: withdrawal_requests withdrawal_requests_processed_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE con.conname = 'withdrawal_requests_processed_by_fkey'
      AND n.nspname = 'public'
      AND c.relname = 'withdrawal_requests'
  ) THEN
    EXECUTE $pg_schema_sql$
ALTER TABLE ONLY "public"."withdrawal_requests"
    ADD CONSTRAINT "withdrawal_requests_processed_by_fkey" FOREIGN KEY ("processed_by") REFERENCES "public"."profiles"("id");
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: company_certifications Admin can manage all certs; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'Admin can manage all certs'
      AND n.nspname = 'public'
      AND c.relname = 'company_certifications'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "Admin can manage all certs" ON "public"."company_certifications" USING ((EXISTS ( SELECT 1
   FROM "public"."profiles"
  WHERE (("profiles"."id" = "auth"."uid"()) AND ("profiles"."role" = 'admin'::"public"."user_role")))));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: reports Admin can manage all reports; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'Admin can manage all reports'
      AND n.nspname = 'public'
      AND c.relname = 'reports'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "Admin can manage all reports" ON "public"."reports" USING ((EXISTS ( SELECT 1
   FROM "public"."profiles"
  WHERE (("profiles"."id" = "auth"."uid"()) AND ("profiles"."role" = 'admin'::"public"."user_role")))));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: subscriptions Admin can manage all subscriptions; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'Admin can manage all subscriptions'
      AND n.nspname = 'public'
      AND c.relname = 'subscriptions'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "Admin can manage all subscriptions" ON "public"."subscriptions" USING ((EXISTS ( SELECT 1
   FROM "public"."profiles"
  WHERE (("profiles"."id" = "auth"."uid"()) AND ("profiles"."role" = 'admin'::"public"."user_role")))));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: orders Admins full access orders; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'Admins full access orders'
      AND n.nspname = 'public'
      AND c.relname = 'orders'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "Admins full access orders" ON "public"."orders" USING ((EXISTS ( SELECT 1
   FROM "public"."profiles"
  WHERE (("profiles"."id" = "auth"."uid"()) AND ("profiles"."role" = 'admin'::"public"."user_role")))));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: withdrawal_requests Admins manage all withdrawal requests; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'Admins manage all withdrawal requests'
      AND n.nspname = 'public'
      AND c.relname = 'withdrawal_requests'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "Admins manage all withdrawal requests" ON "public"."withdrawal_requests" USING ((EXISTS ( SELECT 1
   FROM "public"."profiles"
  WHERE (("profiles"."id" = "auth"."uid"()) AND ("profiles"."role" = 'admin'::"public"."user_role")))));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: pixabay_search_cache Allow anon and auth read cache; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'Allow anon and auth read cache'
      AND n.nspname = 'public'
      AND c.relname = 'pixabay_search_cache'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "Allow anon and auth read cache" ON "public"."pixabay_search_cache" FOR SELECT USING (true);
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: image_sync_logs Allow insert on image_sync_logs; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'Allow insert on image_sync_logs'
      AND n.nspname = 'public'
      AND c.relname = 'image_sync_logs'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "Allow insert on image_sync_logs" ON "public"."image_sync_logs" FOR INSERT WITH CHECK (true);
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: image_sync_logs Allow read on image_sync_logs; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'Allow read on image_sync_logs'
      AND n.nspname = 'public'
      AND c.relname = 'image_sync_logs'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "Allow read on image_sync_logs" ON "public"."image_sync_logs" FOR SELECT USING (true);
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: pixabay_search_cache Allow service role and authenticated insert cache; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'Allow service role and authenticated insert cache'
      AND n.nspname = 'public'
      AND c.relname = 'pixabay_search_cache'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "Allow service role and authenticated insert cache" ON "public"."pixabay_search_cache" FOR INSERT WITH CHECK (true);
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: pixabay_search_cache Allow update cache; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'Allow update cache'
      AND n.nspname = 'public'
      AND c.relname = 'pixabay_search_cache'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "Allow update cache" ON "public"."pixabay_search_cache" FOR UPDATE USING (true);
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: company_reviews Authenticated buyer can insert review; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'Authenticated buyer can insert review'
      AND n.nspname = 'public'
      AND c.relname = 'company_reviews'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "Authenticated buyer can insert review" ON "public"."company_reviews" FOR INSERT WITH CHECK (("reviewer_id" = "auth"."uid"()));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: auctions Authenticated users can create auctions; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'Authenticated users can create auctions'
      AND n.nspname = 'public'
      AND c.relname = 'auctions'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "Authenticated users can create auctions" ON "public"."auctions" FOR INSERT WITH CHECK (("auth"."role"() = 'authenticated'::"text"));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: forward_bids Authenticated users can insert bids; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'Authenticated users can insert bids'
      AND n.nspname = 'public'
      AND c.relname = 'forward_bids'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "Authenticated users can insert bids" ON "public"."forward_bids" FOR INSERT WITH CHECK (("auth"."role"() = 'authenticated'::"text"));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: auction_bids Authenticated users can place auction bids; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'Authenticated users can place auction bids'
      AND n.nspname = 'public'
      AND c.relname = 'auction_bids'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "Authenticated users can place auction bids" ON "public"."auction_bids" FOR INSERT WITH CHECK (("auth"."role"() = 'authenticated'::"text"));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: buyer_profiles Buyer can insert own profile; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'Buyer can insert own profile'
      AND n.nspname = 'public'
      AND c.relname = 'buyer_profiles'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "Buyer can insert own profile" ON "public"."buyer_profiles" FOR INSERT WITH CHECK (("user_id" = "auth"."uid"()));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: buyer_profiles Buyer can update own profile; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'Buyer can update own profile'
      AND n.nspname = 'public'
      AND c.relname = 'buyer_profiles'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "Buyer can update own profile" ON "public"."buyer_profiles" FOR UPDATE USING (("user_id" = "auth"."uid"()));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: buyer_profiles Buyer can view own profile; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'Buyer can view own profile'
      AND n.nspname = 'public'
      AND c.relname = 'buyer_profiles'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "Buyer can view own profile" ON "public"."buyer_profiles" FOR SELECT USING (("user_id" = "auth"."uid"()));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: orders Buyers create orders; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'Buyers create orders'
      AND n.nspname = 'public'
      AND c.relname = 'orders'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "Buyers create orders" ON "public"."orders" FOR INSERT WITH CHECK (("buyer_id" = "auth"."uid"()));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: orders Buyers see their own orders; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'Buyers see their own orders'
      AND n.nspname = 'public'
      AND c.relname = 'orders'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "Buyers see their own orders" ON "public"."orders" FOR SELECT USING (("buyer_id" = "auth"."uid"()));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: withdrawal_requests Company members can manage own withdrawal requests; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'Company members can manage own withdrawal requests'
      AND n.nspname = 'public'
      AND c.relname = 'withdrawal_requests'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "Company members can manage own withdrawal requests" ON "public"."withdrawal_requests" USING (("company_id" IN ( SELECT "companies"."id"
   FROM "public"."companies"
  WHERE ("companies"."owner_id" = "auth"."uid"()))));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: subscriptions Company owner can insert subscription; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'Company owner can insert subscription'
      AND n.nspname = 'public'
      AND c.relname = 'subscriptions'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "Company owner can insert subscription" ON "public"."subscriptions" FOR INSERT WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."companies" "c"
  WHERE (("c"."id" = "subscriptions"."company_id") AND ("c"."owner_id" = "auth"."uid"())))));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: subscriptions Company owner can update subscription; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'Company owner can update subscription'
      AND n.nspname = 'public'
      AND c.relname = 'subscriptions'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "Company owner can update subscription" ON "public"."subscriptions" FOR UPDATE USING ((EXISTS ( SELECT 1
   FROM "public"."companies" "c"
  WHERE (("c"."id" = "subscriptions"."company_id") AND ("c"."owner_id" = "auth"."uid"())))));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: subscriptions Company owner can view own subscription; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'Company owner can view own subscription'
      AND n.nspname = 'public'
      AND c.relname = 'subscriptions'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "Company owner can view own subscription" ON "public"."subscriptions" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "public"."companies" "c"
  WHERE (("c"."id" = "subscriptions"."company_id") AND ("c"."owner_id" = "auth"."uid"())))));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: order_milestone_logs Order parties insert milestone logs; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'Order parties insert milestone logs'
      AND n.nspname = 'public'
      AND c.relname = 'order_milestone_logs'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "Order parties insert milestone logs" ON "public"."order_milestone_logs" FOR INSERT WITH CHECK ((("changed_by" = "auth"."uid"()) AND ("order_id" IN ( SELECT "orders"."id"
   FROM "public"."orders"
  WHERE (("orders"."buyer_id" = "auth"."uid"()) OR ("orders"."supplier_company_id" IN ( SELECT "companies"."id"
           FROM "public"."companies"
          WHERE ("companies"."owner_id" = "auth"."uid"()))))))));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: order_milestone_logs Order parties see milestone logs; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'Order parties see milestone logs'
      AND n.nspname = 'public'
      AND c.relname = 'order_milestone_logs'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "Order parties see milestone logs" ON "public"."order_milestone_logs" FOR SELECT USING ((("order_id" IN ( SELECT "orders"."id"
   FROM "public"."orders"
  WHERE (("orders"."buyer_id" = "auth"."uid"()) OR ("orders"."supplier_company_id" IN ( SELECT "companies"."id"
           FROM "public"."companies"
          WHERE ("companies"."owner_id" = "auth"."uid"())))))) OR (EXISTS ( SELECT 1
   FROM "public"."profiles"
  WHERE (("profiles"."id" = "auth"."uid"()) AND ("profiles"."role" = 'admin'::"public"."user_role"))))));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: orders Order parties update orders; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'Order parties update orders'
      AND n.nspname = 'public'
      AND c.relname = 'orders'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "Order parties update orders" ON "public"."orders" FOR UPDATE USING ((("buyer_id" = "auth"."uid"()) OR ("supplier_company_id" IN ( SELECT "companies"."id"
   FROM "public"."companies"
  WHERE ("companies"."owner_id" = "auth"."uid"()))) OR (EXISTS ( SELECT 1
   FROM "public"."profiles"
  WHERE (("profiles"."id" = "auth"."uid"()) AND ("profiles"."role" = 'admin'::"public"."user_role"))))));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: company_certifications Owner can manage own certs; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'Owner can manage own certs'
      AND n.nspname = 'public'
      AND c.relname = 'company_certifications'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "Owner can manage own certs" ON "public"."company_certifications" USING ((EXISTS ( SELECT 1
   FROM "public"."companies" "c"
  WHERE (("c"."id" = "company_certifications"."company_id") AND ("c"."owner_id" = "auth"."uid"())))));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: auction_bids Public can view auction bids; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'Public can view auction bids'
      AND n.nspname = 'public'
      AND c.relname = 'auction_bids'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "Public can view auction bids" ON "public"."auction_bids" FOR SELECT USING (true);
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: company_reviews Public can view reviews; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'Public can view reviews'
      AND n.nspname = 'public'
      AND c.relname = 'company_reviews'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "Public can view reviews" ON "public"."company_reviews" FOR SELECT USING (true);
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: company_certifications Public can view verified certs; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'Public can view verified certs'
      AND n.nspname = 'public'
      AND c.relname = 'company_certifications'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "Public can view verified certs" ON "public"."company_certifications" FOR SELECT USING (true);
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: auctions Public read access to auctions; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'Public read access to auctions'
      AND n.nspname = 'public'
      AND c.relname = 'auctions'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "Public read access to auctions" ON "public"."auctions" FOR SELECT USING (true);
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: forward_bids Public read access to forward_bids; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'Public read access to forward_bids'
      AND n.nspname = 'public'
      AND c.relname = 'forward_bids'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "Public read access to forward_bids" ON "public"."forward_bids" FOR SELECT USING (true);
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: reports Reporter can insert reports; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'Reporter can insert reports'
      AND n.nspname = 'public'
      AND c.relname = 'reports'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "Reporter can insert reports" ON "public"."reports" FOR INSERT WITH CHECK (("reporter_id" = "auth"."uid"()));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: reports Reporter can view own reports; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'Reporter can view own reports'
      AND n.nspname = 'public'
      AND c.relname = 'reports'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "Reporter can view own reports" ON "public"."reports" FOR SELECT USING (("reporter_id" = "auth"."uid"()));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: company_reviews Reviewer can update own review; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'Reviewer can update own review'
      AND n.nspname = 'public'
      AND c.relname = 'company_reviews'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "Reviewer can update own review" ON "public"."company_reviews" FOR UPDATE USING (("reviewer_id" = "auth"."uid"()));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: auctions Sellers and admins can update auctions; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'Sellers and admins can update auctions'
      AND n.nspname = 'public'
      AND c.relname = 'auctions'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "Sellers and admins can update auctions" ON "public"."auctions" FOR UPDATE USING ((("auth"."uid"() = "seller_id") OR (EXISTS ( SELECT 1
   FROM "public"."profiles"
  WHERE (("profiles"."id" = "auth"."uid"()) AND ("profiles"."role" = 'admin'::"public"."user_role"))))));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: subscription_orders Service role can manage subscription orders; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'Service role can manage subscription orders'
      AND n.nspname = 'public'
      AND c.relname = 'subscription_orders'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "Service role can manage subscription orders" ON "public"."subscription_orders" USING ((("auth"."jwt"() ->> 'role'::"text") = 'service_role'::"text")) WITH CHECK ((("auth"."jwt"() ->> 'role'::"text") = 'service_role'::"text"));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: orders Suppliers see orders for their company; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'Suppliers see orders for their company'
      AND n.nspname = 'public'
      AND c.relname = 'orders'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "Suppliers see orders for their company" ON "public"."orders" FOR SELECT USING (("supplier_company_id" IN ( SELECT "companies"."id"
   FROM "public"."companies"
  WHERE ("companies"."owner_id" = "auth"."uid"()))));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: notifications User can update own notifications; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'User can update own notifications'
      AND n.nspname = 'public'
      AND c.relname = 'notifications'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "User can update own notifications" ON "public"."notifications" FOR UPDATE USING (("user_id" = "auth"."uid"()));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: notifications User can view own notifications; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'User can view own notifications'
      AND n.nspname = 'public'
      AND c.relname = 'notifications'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "User can view own notifications" ON "public"."notifications" FOR SELECT USING (("user_id" = "auth"."uid"()));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: subscription_orders Users can view own subscription orders; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'Users can view own subscription orders'
      AND n.nspname = 'public'
      AND c.relname = 'subscription_orders'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "Users can view own subscription orders" ON "public"."subscription_orders" FOR SELECT USING (("auth"."uid"() = "user_id"));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: order_status_history admin_read_all_order_history; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'admin_read_all_order_history'
      AND n.nspname = 'public'
      AND c.relname = 'order_status_history'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "admin_read_all_order_history" ON "public"."order_status_history" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "public"."profiles"
  WHERE (("profiles"."id" = "auth"."uid"()) AND ("profiles"."role" = 'admin'::"public"."user_role")))));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: shipping_quotes admin_read_all_shipping_quotes; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'admin_read_all_shipping_quotes'
      AND n.nspname = 'public'
      AND c.relname = 'shipping_quotes'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "admin_read_all_shipping_quotes" ON "public"."shipping_quotes" FOR SELECT USING ((( SELECT "profiles"."role"
   FROM "public"."profiles"
  WHERE ("profiles"."id" = "auth"."uid"())) = 'admin'::"public"."user_role"));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: rfq_matches admins_read_all_matches; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'admins_read_all_matches'
      AND n.nspname = 'public'
      AND c.relname = 'rfq_matches'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "admins_read_all_matches" ON "public"."rfq_matches" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "public"."profiles"
  WHERE (("profiles"."id" = "auth"."uid"()) AND ("profiles"."role" = 'admin'::"public"."user_role")))));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: auction_bids; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."auction_bids" ENABLE ROW LEVEL SECURITY;

--
-- Name: auctions; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."auctions" ENABLE ROW LEVEL SECURITY;

--
-- Name: audit_logs; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."audit_logs" ENABLE ROW LEVEL SECURITY;

--
-- Name: audit_logs audit_logs_admin; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'audit_logs_admin'
      AND n.nspname = 'public'
      AND c.relname = 'audit_logs'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "audit_logs_admin" ON "public"."audit_logs" FOR SELECT TO "authenticated" USING (("public"."get_my_role"() = 'admin'::"text"));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: audit_logs audit_logs_insert; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'audit_logs_insert'
      AND n.nspname = 'public'
      AND c.relname = 'audit_logs'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "audit_logs_insert" ON "public"."audit_logs" FOR INSERT TO "authenticated" WITH CHECK (true);
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: auto_quotations; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."auto_quotations" ENABLE ROW LEVEL SECURITY;

--
-- Name: blocked_users blocked_delete; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'blocked_delete'
      AND n.nspname = 'public'
      AND c.relname = 'blocked_users'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "blocked_delete" ON "public"."blocked_users" FOR DELETE TO "authenticated" USING (("blocker_id" = "auth"."uid"()));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: blocked_users blocked_insert; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'blocked_insert'
      AND n.nspname = 'public'
      AND c.relname = 'blocked_users'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "blocked_insert" ON "public"."blocked_users" FOR INSERT TO "authenticated" WITH CHECK (("blocker_id" = "auth"."uid"()));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: blocked_users blocked_select; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'blocked_select'
      AND n.nspname = 'public'
      AND c.relname = 'blocked_users'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "blocked_select" ON "public"."blocked_users" FOR SELECT TO "authenticated" USING ((("blocker_id" = "auth"."uid"()) OR ("blocked_id" = "auth"."uid"())));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: blocked_users; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."blocked_users" ENABLE ROW LEVEL SECURITY;

--
-- Name: bulk_discount_rules; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."bulk_discount_rules" ENABLE ROW LEVEL SECURITY;

--
-- Name: instant_quote_requests buyer_manage_iqr; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'buyer_manage_iqr'
      AND n.nspname = 'public'
      AND c.relname = 'instant_quote_requests'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "buyer_manage_iqr" ON "public"."instant_quote_requests" USING (("buyer_id" = "auth"."uid"()));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: sample_requests buyer_manage_own_samples; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'buyer_manage_own_samples'
      AND n.nspname = 'public'
      AND c.relname = 'sample_requests'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "buyer_manage_own_samples" ON "public"."sample_requests" USING (("buyer_id" = "auth"."uid"()));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: buyer_profiles; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."buyer_profiles" ENABLE ROW LEVEL SECURITY;

--
-- Name: buyer_profiles buyer_profiles_delete_admin; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'buyer_profiles_delete_admin'
      AND n.nspname = 'public'
      AND c.relname = 'buyer_profiles'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "buyer_profiles_delete_admin" ON "public"."buyer_profiles" FOR DELETE USING ("public"."is_admin"());
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: buyer_profiles buyer_profiles_insert_own; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'buyer_profiles_insert_own'
      AND n.nspname = 'public'
      AND c.relname = 'buyer_profiles'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "buyer_profiles_insert_own" ON "public"."buyer_profiles" FOR INSERT WITH CHECK (("user_id" = "auth"."uid"()));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: buyer_profiles buyer_profiles_select_own; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'buyer_profiles_select_own'
      AND n.nspname = 'public'
      AND c.relname = 'buyer_profiles'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "buyer_profiles_select_own" ON "public"."buyer_profiles" FOR SELECT USING ((("user_id" = "auth"."uid"()) OR "public"."is_admin"()));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: buyer_profiles buyer_profiles_update_own; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'buyer_profiles_update_own'
      AND n.nspname = 'public'
      AND c.relname = 'buyer_profiles'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "buyer_profiles_update_own" ON "public"."buyer_profiles" FOR UPDATE USING ((("user_id" = "auth"."uid"()) OR "public"."is_admin"()));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: order_status_history buyer_read_own_order_history; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'buyer_read_own_order_history'
      AND n.nspname = 'public'
      AND c.relname = 'order_status_history'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "buyer_read_own_order_history" ON "public"."order_status_history" FOR SELECT USING (("order_id" IN ( SELECT "orders"."id"
   FROM "public"."orders"
  WHERE ("orders"."buyer_id" = "auth"."uid"()))));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: buyer_subscriptions buyer_sub_admin_all; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'buyer_sub_admin_all'
      AND n.nspname = 'public'
      AND c.relname = 'buyer_subscriptions'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "buyer_sub_admin_all" ON "public"."buyer_subscriptions" USING ((EXISTS ( SELECT 1
   FROM "public"."profiles"
  WHERE (("profiles"."id" = "auth"."uid"()) AND ("profiles"."role" = 'admin'::"public"."user_role")))));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: buyer_subscriptions buyer_sub_insert_own; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'buyer_sub_insert_own'
      AND n.nspname = 'public'
      AND c.relname = 'buyer_subscriptions'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "buyer_sub_insert_own" ON "public"."buyer_subscriptions" FOR INSERT WITH CHECK (("auth"."uid"() = "user_id"));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: buyer_subscriptions buyer_sub_select_own; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'buyer_sub_select_own'
      AND n.nspname = 'public'
      AND c.relname = 'buyer_subscriptions'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "buyer_sub_select_own" ON "public"."buyer_subscriptions" FOR SELECT USING (("auth"."uid"() = "user_id"));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: buyer_subscriptions buyer_sub_update_own; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'buyer_sub_update_own'
      AND n.nspname = 'public'
      AND c.relname = 'buyer_subscriptions'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "buyer_sub_update_own" ON "public"."buyer_subscriptions" FOR UPDATE USING (("auth"."uid"() = "user_id"));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: buyer_subscriptions; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."buyer_subscriptions" ENABLE ROW LEVEL SECURITY;

--
-- Name: auto_quotations buyer_update_auto_quotations; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'buyer_update_auto_quotations'
      AND n.nspname = 'public'
      AND c.relname = 'auto_quotations'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "buyer_update_auto_quotations" ON "public"."auto_quotations" FOR UPDATE USING (("buyer_id" = "auth"."uid"())) WITH CHECK (("buyer_id" = "auth"."uid"()));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: auto_quotations buyer_view_auto_quotations; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'buyer_view_auto_quotations'
      AND n.nspname = 'public'
      AND c.relname = 'auto_quotations'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "buyer_view_auto_quotations" ON "public"."auto_quotations" FOR SELECT USING (("buyer_id" = "auth"."uid"()));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: rfq_matches buyers_read_own_rfq_matches; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'buyers_read_own_rfq_matches'
      AND n.nspname = 'public'
      AND c.relname = 'rfq_matches'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "buyers_read_own_rfq_matches" ON "public"."rfq_matches" FOR SELECT USING (("rfq_id" IN ( SELECT "requirements"."id"
   FROM "public"."requirements"
  WHERE ("requirements"."buyer_id" = "auth"."uid"()))));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: categories; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."categories" ENABLE ROW LEVEL SECURITY;

--
-- Name: categories categories_delete_admin; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'categories_delete_admin'
      AND n.nspname = 'public'
      AND c.relname = 'categories'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "categories_delete_admin" ON "public"."categories" FOR DELETE USING ("public"."is_admin"());
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: categories categories_insert_admin; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'categories_insert_admin'
      AND n.nspname = 'public'
      AND c.relname = 'categories'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "categories_insert_admin" ON "public"."categories" FOR INSERT WITH CHECK ("public"."is_admin"());
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: categories categories_select_all; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'categories_select_all'
      AND n.nspname = 'public'
      AND c.relname = 'categories'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "categories_select_all" ON "public"."categories" FOR SELECT USING (true);
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: categories categories_update_admin; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'categories_update_admin'
      AND n.nspname = 'public'
      AND c.relname = 'categories'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "categories_update_admin" ON "public"."categories" FOR UPDATE USING ("public"."is_admin"());
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: companies; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."companies" ENABLE ROW LEVEL SECURITY;

--
-- Name: companies companies_delete_own; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'companies_delete_own'
      AND n.nspname = 'public'
      AND c.relname = 'companies'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "companies_delete_own" ON "public"."companies" FOR DELETE USING (("public"."owns_company"("id") OR "public"."is_admin"()));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: companies companies_insert_own; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'companies_insert_own'
      AND n.nspname = 'public'
      AND c.relname = 'companies'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "companies_insert_own" ON "public"."companies" FOR INSERT WITH CHECK (("owner_id" = "auth"."uid"()));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: companies companies_select_public; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'companies_select_public'
      AND n.nspname = 'public'
      AND c.relname = 'companies'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "companies_select_public" ON "public"."companies" FOR SELECT USING (true);
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: companies companies_update_own; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'companies_update_own'
      AND n.nspname = 'public'
      AND c.relname = 'companies'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "companies_update_own" ON "public"."companies" FOR UPDATE USING (("public"."owns_company"("id") OR "public"."is_admin"()));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: company_certifications; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."company_certifications" ENABLE ROW LEVEL SECURITY;

--
-- Name: company_reviews; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."company_reviews" ENABLE ROW LEVEL SECURITY;

--
-- Name: conversations; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."conversations" ENABLE ROW LEVEL SECURITY;

--
-- Name: conversations conversations_delete_admin; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'conversations_delete_admin'
      AND n.nspname = 'public'
      AND c.relname = 'conversations'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "conversations_delete_admin" ON "public"."conversations" FOR DELETE USING ("public"."is_admin"());
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: conversations conversations_insert_parties; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'conversations_insert_parties'
      AND n.nspname = 'public'
      AND c.relname = 'conversations'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "conversations_insert_parties" ON "public"."conversations" FOR INSERT TO "authenticated" WITH CHECK ((((("auth"."uid"() = "buyer_id") OR ("auth"."uid"() = "supplier_id")) AND "public"."is_chat_eligible"("supplier_id")) OR "public"."is_admin"()));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: conversations conversations_select_parties; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'conversations_select_parties'
      AND n.nspname = 'public'
      AND c.relname = 'conversations'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "conversations_select_parties" ON "public"."conversations" FOR SELECT USING ((("auth"."uid"() = "buyer_id") OR ("auth"."uid"() = "supplier_id")));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: conversations conversations_update_parties; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'conversations_update_parties'
      AND n.nspname = 'public'
      AND c.relname = 'conversations'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "conversations_update_parties" ON "public"."conversations" FOR UPDATE USING ((("auth"."uid"() = "buyer_id") OR ("auth"."uid"() = "supplier_id")));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: dispute_actions; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."dispute_actions" ENABLE ROW LEVEL SECURITY;

--
-- Name: dispute_actions dispute_actions_insert; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'dispute_actions_insert'
      AND n.nspname = 'public'
      AND c.relname = 'dispute_actions'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "dispute_actions_insert" ON "public"."dispute_actions" FOR INSERT TO "authenticated" WITH CHECK ((("actor_id" = "auth"."uid"()) OR ("public"."get_my_role"() = 'admin'::"text")));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: dispute_actions dispute_actions_select; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'dispute_actions_select'
      AND n.nspname = 'public'
      AND c.relname = 'dispute_actions'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "dispute_actions_select" ON "public"."dispute_actions" FOR SELECT TO "authenticated" USING ((("public"."get_my_role"() = 'admin'::"text") OR ("actor_id" = "auth"."uid"()) OR (EXISTS ( SELECT 1
   FROM "public"."disputes" "d"
  WHERE (("d"."id" = "dispute_actions"."dispute_id") AND (("d"."raised_by" = "auth"."uid"()) OR ("d"."against_user_id" = "auth"."uid"())))))));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: disputes; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."disputes" ENABLE ROW LEVEL SECURITY;

--
-- Name: disputes disputes_insert; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'disputes_insert'
      AND n.nspname = 'public'
      AND c.relname = 'disputes'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "disputes_insert" ON "public"."disputes" FOR INSERT TO "authenticated" WITH CHECK (("raised_by" = "auth"."uid"()));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: disputes disputes_select; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'disputes_select'
      AND n.nspname = 'public'
      AND c.relname = 'disputes'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "disputes_select" ON "public"."disputes" FOR SELECT TO "authenticated" USING ((("raised_by" = "auth"."uid"()) OR ("against_user_id" = "auth"."uid"()) OR ("public"."get_my_role"() = 'admin'::"text")));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: disputes disputes_update; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'disputes_update'
      AND n.nspname = 'public'
      AND c.relname = 'disputes'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "disputes_update" ON "public"."disputes" FOR UPDATE TO "authenticated" USING ((("raised_by" = "auth"."uid"()) OR ("public"."get_my_role"() = 'admin'::"text")));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: forward_bids; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."forward_bids" ENABLE ROW LEVEL SECURITY;

--
-- Name: fraud_alerts; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."fraud_alerts" ENABLE ROW LEVEL SECURITY;

--
-- Name: fraud_alerts fraud_alerts_admin; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'fraud_alerts_admin'
      AND n.nspname = 'public'
      AND c.relname = 'fraud_alerts'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "fraud_alerts_admin" ON "public"."fraud_alerts" TO "authenticated" USING (("public"."get_my_role"() = 'admin'::"text")) WITH CHECK (("public"."get_my_role"() = 'admin'::"text"));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: image_sync_logs; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."image_sync_logs" ENABLE ROW LEVEL SECURITY;

--
-- Name: order_status_history insert_order_history; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'insert_order_history'
      AND n.nspname = 'public'
      AND c.relname = 'order_status_history'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "insert_order_history" ON "public"."order_status_history" FOR INSERT WITH CHECK (("changed_by" = "auth"."uid"()));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: instant_quote_requests; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."instant_quote_requests" ENABLE ROW LEVEL SECURITY;

--
-- Name: subscription_invoices invoices_select_own; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'invoices_select_own'
      AND n.nspname = 'public'
      AND c.relname = 'subscription_invoices'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "invoices_select_own" ON "public"."subscription_invoices" FOR SELECT USING (("auth"."uid"() = "user_id"));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: subscription_invoices invoices_service_all; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'invoices_service_all'
      AND n.nspname = 'public'
      AND c.relname = 'subscription_invoices'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "invoices_service_all" ON "public"."subscription_invoices" USING ((("auth"."jwt"() ->> 'role'::"text") = 'service_role'::"text")) WITH CHECK ((("auth"."jwt"() ->> 'role'::"text") = 'service_role'::"text"));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: lead_credit_transactions; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."lead_credit_transactions" ENABLE ROW LEVEL SECURITY;

--
-- Name: messages; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."messages" ENABLE ROW LEVEL SECURITY;

--
-- Name: messages messages_delete_admin; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'messages_delete_admin'
      AND n.nspname = 'public'
      AND c.relname = 'messages'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "messages_delete_admin" ON "public"."messages" FOR DELETE USING ("public"."is_admin"());
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: messages messages_insert_parties; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'messages_insert_parties'
      AND n.nspname = 'public'
      AND c.relname = 'messages'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "messages_insert_parties" ON "public"."messages" FOR INSERT WITH CHECK ((("sender_id" = "auth"."uid"()) AND "public"."is_chat_eligible"("auth"."uid"()) AND (EXISTS ( SELECT 1
   FROM "public"."conversations" "c"
  WHERE (("c"."id" = "messages"."conversation_id") AND (("c"."buyer_id" = "auth"."uid"()) OR ("c"."supplier_id" = "auth"."uid"())))))));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: messages messages_select_parties; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'messages_select_parties'
      AND n.nspname = 'public'
      AND c.relname = 'messages'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "messages_select_parties" ON "public"."messages" FOR SELECT USING (((EXISTS ( SELECT 1
   FROM "public"."conversations" "c"
  WHERE (("c"."id" = "messages"."conversation_id") AND (("c"."buyer_id" = "auth"."uid"()) OR ("c"."supplier_id" = "auth"."uid"()))))) OR "public"."is_admin"()));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: messages messages_update_sender; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'messages_update_sender'
      AND n.nspname = 'public'
      AND c.relname = 'messages'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "messages_update_sender" ON "public"."messages" FOR UPDATE USING ((("sender_id" = "auth"."uid"()) OR "public"."is_admin"()));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: notifications; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."notifications" ENABLE ROW LEVEL SECURITY;

--
-- Name: notifications notifications_delete_own; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'notifications_delete_own'
      AND n.nspname = 'public'
      AND c.relname = 'notifications'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "notifications_delete_own" ON "public"."notifications" FOR DELETE TO "authenticated" USING ((("user_id" = "auth"."uid"()) OR "public"."is_admin"()));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: notifications notifications_insert_authenticated; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'notifications_insert_authenticated'
      AND n.nspname = 'public'
      AND c.relname = 'notifications'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "notifications_insert_authenticated" ON "public"."notifications" FOR INSERT TO "authenticated" WITH CHECK (true);
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: notifications notifications_select_own; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'notifications_select_own'
      AND n.nspname = 'public'
      AND c.relname = 'notifications'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "notifications_select_own" ON "public"."notifications" FOR SELECT USING ((("user_id" = "auth"."uid"()) OR "public"."is_admin"()));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: notifications notifications_update_own; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'notifications_update_own'
      AND n.nspname = 'public'
      AND c.relname = 'notifications'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "notifications_update_own" ON "public"."notifications" FOR UPDATE TO "authenticated" USING ((("user_id" = "auth"."uid"()) OR "public"."is_admin"())) WITH CHECK ((("user_id" = "auth"."uid"()) OR "public"."is_admin"()));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: order_milestone_logs; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."order_milestone_logs" ENABLE ROW LEVEL SECURITY;

--
-- Name: order_milestones; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."order_milestones" ENABLE ROW LEVEL SECURITY;

--
-- Name: order_milestones order_milestones_insert; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'order_milestones_insert'
      AND n.nspname = 'public'
      AND c.relname = 'order_milestones'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "order_milestones_insert" ON "public"."order_milestones" FOR INSERT TO "authenticated" WITH CHECK ((("public"."get_my_role"() = 'admin'::"text") OR (EXISTS ( SELECT 1
   FROM "public"."orders" "o"
  WHERE (("o"."id" = "order_milestones"."order_id") AND (("o"."buyer_id" = "auth"."uid"()) OR ("o"."supplier_id" = "auth"."uid"())))))));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: order_milestones order_milestones_select; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'order_milestones_select'
      AND n.nspname = 'public'
      AND c.relname = 'order_milestones'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "order_milestones_select" ON "public"."order_milestones" FOR SELECT TO "authenticated" USING ((("public"."get_my_role"() = 'admin'::"text") OR (EXISTS ( SELECT 1
   FROM "public"."orders" "o"
  WHERE (("o"."id" = "order_milestones"."order_id") AND (("o"."buyer_id" = "auth"."uid"()) OR ("o"."supplier_id" = "auth"."uid"())))))));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: order_status_history; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."order_status_history" ENABLE ROW LEVEL SECURITY;

--
-- Name: orders; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."orders" ENABLE ROW LEVEL SECURITY;

--
-- Name: orders orders_delete_admin; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'orders_delete_admin'
      AND n.nspname = 'public'
      AND c.relname = 'orders'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "orders_delete_admin" ON "public"."orders" FOR DELETE USING ("public"."is_admin"());
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: orders orders_insert_buyer; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'orders_insert_buyer'
      AND n.nspname = 'public'
      AND c.relname = 'orders'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "orders_insert_buyer" ON "public"."orders" FOR INSERT WITH CHECK (("buyer_id" = "auth"."uid"()));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: orders orders_select_parties; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'orders_select_parties'
      AND n.nspname = 'public'
      AND c.relname = 'orders'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "orders_select_parties" ON "public"."orders" FOR SELECT USING ((("buyer_id" = "auth"."uid"()) OR (EXISTS ( SELECT 1
   FROM "public"."companies"
  WHERE (("companies"."id" = "orders"."supplier_company_id") AND ("companies"."owner_id" = "auth"."uid"())))) OR "public"."is_admin"()));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: orders orders_update_parties; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'orders_update_parties'
      AND n.nspname = 'public'
      AND c.relname = 'orders'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "orders_update_parties" ON "public"."orders" FOR UPDATE USING ((("buyer_id" = "auth"."uid"()) OR (EXISTS ( SELECT 1
   FROM "public"."companies"
  WHERE (("companies"."id" = "orders"."supplier_company_id") AND ("companies"."owner_id" = "auth"."uid"())))) OR "public"."is_admin"()));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: pixabay_search_cache; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."pixabay_search_cache" ENABLE ROW LEVEL SECURITY;

--
-- Name: product_inventory; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."product_inventory" ENABLE ROW LEVEL SECURITY;

--
-- Name: product_promotions; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."product_promotions" ENABLE ROW LEVEL SECURITY;

--
-- Name: products; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."products" ENABLE ROW LEVEL SECURITY;

--
-- Name: products products_delete_own; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'products_delete_own'
      AND n.nspname = 'public'
      AND c.relname = 'products'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "products_delete_own" ON "public"."products" FOR DELETE USING (((EXISTS ( SELECT 1
   FROM "public"."companies"
  WHERE (("companies"."id" = "products"."company_id") AND ("companies"."owner_id" = "auth"."uid"())))) OR "public"."is_admin"()));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: products products_insert_own; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'products_insert_own'
      AND n.nspname = 'public'
      AND c.relname = 'products'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "products_insert_own" ON "public"."products" FOR INSERT WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."companies"
  WHERE (("companies"."id" = "products"."company_id") AND ("companies"."owner_id" = "auth"."uid"())))));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: products products_select_all; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'products_select_all'
      AND n.nspname = 'public'
      AND c.relname = 'products'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "products_select_all" ON "public"."products" FOR SELECT USING (true);
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: products products_update_own; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'products_update_own'
      AND n.nspname = 'public'
      AND c.relname = 'products'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "products_update_own" ON "public"."products" FOR UPDATE USING (((EXISTS ( SELECT 1
   FROM "public"."companies"
  WHERE (("companies"."id" = "products"."company_id") AND ("companies"."owner_id" = "auth"."uid"())))) OR "public"."is_admin"()));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: profiles; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."profiles" ENABLE ROW LEVEL SECURITY;

--
-- Name: profiles profiles_delete_admin; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'profiles_delete_admin'
      AND n.nspname = 'public'
      AND c.relname = 'profiles'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "profiles_delete_admin" ON "public"."profiles" FOR DELETE USING ("public"."is_admin"());
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: profiles profiles_insert_own; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'profiles_insert_own'
      AND n.nspname = 'public'
      AND c.relname = 'profiles'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "profiles_insert_own" ON "public"."profiles" FOR INSERT WITH CHECK (("id" = "auth"."uid"()));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: profiles profiles_select_public; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'profiles_select_public'
      AND n.nspname = 'public'
      AND c.relname = 'profiles'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "profiles_select_public" ON "public"."profiles" FOR SELECT USING (true);
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: profiles profiles_update_own; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'profiles_update_own'
      AND n.nspname = 'public'
      AND c.relname = 'profiles'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "profiles_update_own" ON "public"."profiles" FOR UPDATE USING ((("id" = "auth"."uid"()) OR "public"."is_admin"()));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: product_promotions public_read_active_promotions; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'public_read_active_promotions'
      AND n.nspname = 'public'
      AND c.relname = 'product_promotions'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "public_read_active_promotions" ON "public"."product_promotions" FOR SELECT USING (("status" = 'active'::"text"));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: bulk_discount_rules public_read_discounts; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'public_read_discounts'
      AND n.nspname = 'public'
      AND c.relname = 'bulk_discount_rules'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "public_read_discounts" ON "public"."bulk_discount_rules" FOR SELECT USING (true);
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: product_inventory public_read_inventory; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'public_read_inventory'
      AND n.nspname = 'public'
      AND c.relname = 'product_inventory'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "public_read_inventory" ON "public"."product_inventory" FOR SELECT USING (true);
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: quotations; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."quotations" ENABLE ROW LEVEL SECURITY;

--
-- Name: quotations quotations_delete_admin; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'quotations_delete_admin'
      AND n.nspname = 'public'
      AND c.relname = 'quotations'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "quotations_delete_admin" ON "public"."quotations" FOR DELETE USING ("public"."is_admin"());
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: quotations quotations_insert_subscribed_supplier; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'quotations_insert_subscribed_supplier'
      AND n.nspname = 'public'
      AND c.relname = 'quotations'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "quotations_insert_subscribed_supplier" ON "public"."quotations" FOR INSERT WITH CHECK ((("supplier_id" = "auth"."uid"()) AND "public"."is_supplier_subscribed"("auth"."uid"())));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: quotations quotations_select_parties; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'quotations_select_parties'
      AND n.nspname = 'public'
      AND c.relname = 'quotations'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "quotations_select_parties" ON "public"."quotations" FOR SELECT USING ((("buyer_id" = "auth"."uid"()) OR ("supplier_id" = "auth"."uid"()) OR "public"."is_admin"()));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: quotations quotations_update_supplier; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'quotations_update_supplier'
      AND n.nspname = 'public'
      AND c.relname = 'quotations'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "quotations_update_supplier" ON "public"."quotations" FOR UPDATE USING ((("supplier_id" = "auth"."uid"()) OR ("buyer_id" = "auth"."uid"()) OR "public"."is_admin"()));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: reports; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."reports" ENABLE ROW LEVEL SECURITY;

--
-- Name: reports reports_delete_admin; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'reports_delete_admin'
      AND n.nspname = 'public'
      AND c.relname = 'reports'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "reports_delete_admin" ON "public"."reports" FOR DELETE USING ("public"."is_admin"());
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: reports reports_insert_auth; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'reports_insert_auth'
      AND n.nspname = 'public'
      AND c.relname = 'reports'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "reports_insert_auth" ON "public"."reports" FOR INSERT WITH CHECK (("reporter_id" = "auth"."uid"()));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: reports reports_select_own_admin; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'reports_select_own_admin'
      AND n.nspname = 'public'
      AND c.relname = 'reports'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "reports_select_own_admin" ON "public"."reports" FOR SELECT USING ((("reporter_id" = "auth"."uid"()) OR "public"."is_admin"()));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: reports reports_update_admin; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'reports_update_admin'
      AND n.nspname = 'public'
      AND c.relname = 'reports'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "reports_update_admin" ON "public"."reports" FOR UPDATE USING ("public"."is_admin"());
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: requirements; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."requirements" ENABLE ROW LEVEL SECURITY;

--
-- Name: requirements requirements_delete_buyer; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'requirements_delete_buyer'
      AND n.nspname = 'public'
      AND c.relname = 'requirements'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "requirements_delete_buyer" ON "public"."requirements" FOR DELETE USING ((("buyer_id" = "auth"."uid"()) OR "public"."is_admin"()));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: requirements requirements_insert_buyer; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'requirements_insert_buyer'
      AND n.nspname = 'public'
      AND c.relname = 'requirements'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "requirements_insert_buyer" ON "public"."requirements" FOR INSERT WITH CHECK (("buyer_id" = "auth"."uid"()));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: requirements requirements_select_all; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'requirements_select_all'
      AND n.nspname = 'public'
      AND c.relname = 'requirements'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "requirements_select_all" ON "public"."requirements" FOR SELECT USING (true);
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: requirements requirements_update_buyer; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'requirements_update_buyer'
      AND n.nspname = 'public'
      AND c.relname = 'requirements'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "requirements_update_buyer" ON "public"."requirements" FOR UPDATE USING ((("buyer_id" = "auth"."uid"()) OR "public"."is_admin"()));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: rfq_lead_views; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."rfq_lead_views" ENABLE ROW LEVEL SECURITY;

--
-- Name: rfq_match_log rfq_match_insert; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'rfq_match_insert'
      AND n.nspname = 'public'
      AND c.relname = 'rfq_match_log'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "rfq_match_insert" ON "public"."rfq_match_log" FOR INSERT TO "authenticated" WITH CHECK (("public"."get_my_role"() = 'admin'::"text"));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: rfq_match_log; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."rfq_match_log" ENABLE ROW LEVEL SECURITY;

--
-- Name: rfq_match_log rfq_match_select; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'rfq_match_select'
      AND n.nspname = 'public'
      AND c.relname = 'rfq_match_log'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "rfq_match_select" ON "public"."rfq_match_log" FOR SELECT TO "authenticated" USING ((("public"."get_my_role"() = 'admin'::"text") OR "public"."is_company_owner"("company_id")));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: rfq_matches; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."rfq_matches" ENABLE ROW LEVEL SECURITY;

--
-- Name: rfq_matches rfq_matches_manage_own; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'rfq_matches_manage_own'
      AND n.nspname = 'public'
      AND c.relname = 'rfq_matches'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "rfq_matches_manage_own" ON "public"."rfq_matches" TO "authenticated" USING ((("company_id" IN ( SELECT "companies"."id"
   FROM "public"."companies"
  WHERE ("companies"."owner_id" = "auth"."uid"()))) OR "public"."is_admin"())) WITH CHECK ((("company_id" IN ( SELECT "companies"."id"
   FROM "public"."companies"
  WHERE ("companies"."owner_id" = "auth"."uid"()))) OR "public"."is_admin"()));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: rfq_matches rfq_matches_select_own; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'rfq_matches_select_own'
      AND n.nspname = 'public'
      AND c.relname = 'rfq_matches'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "rfq_matches_select_own" ON "public"."rfq_matches" FOR SELECT TO "authenticated" USING ((("company_id" IN ( SELECT "companies"."id"
   FROM "public"."companies"
  WHERE ("companies"."owner_id" = "auth"."uid"()))) OR "public"."is_admin"()));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: rfq_lead_views rfq_views_delete_admin; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'rfq_views_delete_admin'
      AND n.nspname = 'public'
      AND c.relname = 'rfq_lead_views'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "rfq_views_delete_admin" ON "public"."rfq_lead_views" FOR DELETE USING ("public"."is_admin"());
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: rfq_lead_views rfq_views_insert_own; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'rfq_views_insert_own'
      AND n.nspname = 'public'
      AND c.relname = 'rfq_lead_views'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "rfq_views_insert_own" ON "public"."rfq_lead_views" FOR INSERT WITH CHECK (("supplier_id" = "auth"."uid"()));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: rfq_lead_views rfq_views_select_own; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'rfq_views_select_own'
      AND n.nspname = 'public'
      AND c.relname = 'rfq_lead_views'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "rfq_views_select_own" ON "public"."rfq_lead_views" FOR SELECT USING ((("supplier_id" = "auth"."uid"()) OR "public"."is_admin"()));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: rfq_lead_views rfq_views_update_admin; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'rfq_views_update_admin'
      AND n.nspname = 'public'
      AND c.relname = 'rfq_lead_views'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "rfq_views_update_admin" ON "public"."rfq_lead_views" FOR UPDATE USING ("public"."is_admin"());
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: sample_requests; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."sample_requests" ENABLE ROW LEVEL SECURITY;

--
-- Name: saved_manufacturers saved_delete; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'saved_delete'
      AND n.nspname = 'public'
      AND c.relname = 'saved_manufacturers'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "saved_delete" ON "public"."saved_manufacturers" FOR DELETE TO "authenticated" USING (("buyer_id" = "auth"."uid"()));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: saved_manufacturers saved_insert; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'saved_insert'
      AND n.nspname = 'public'
      AND c.relname = 'saved_manufacturers'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "saved_insert" ON "public"."saved_manufacturers" FOR INSERT TO "authenticated" WITH CHECK (("buyer_id" = "auth"."uid"()));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: saved_manufacturers; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."saved_manufacturers" ENABLE ROW LEVEL SECURITY;

--
-- Name: saved_manufacturers saved_select; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'saved_select'
      AND n.nspname = 'public'
      AND c.relname = 'saved_manufacturers'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "saved_select" ON "public"."saved_manufacturers" FOR SELECT TO "authenticated" USING ((("buyer_id" = "auth"."uid"()) OR ("public"."get_my_role"() = 'admin'::"text")));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: rfq_matches service_insert_matches; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'service_insert_matches'
      AND n.nspname = 'public'
      AND c.relname = 'rfq_matches'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "service_insert_matches" ON "public"."rfq_matches" FOR INSERT WITH CHECK (true);
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: rfq_matches service_update_matches; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'service_update_matches'
      AND n.nspname = 'public'
      AND c.relname = 'rfq_matches'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "service_update_matches" ON "public"."rfq_matches" FOR UPDATE USING (true);
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: shipping_quotes; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."shipping_quotes" ENABLE ROW LEVEL SECURITY;

--
-- Name: subscription_invoices; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."subscription_invoices" ENABLE ROW LEVEL SECURITY;

--
-- Name: subscription_orders; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."subscription_orders" ENABLE ROW LEVEL SECURITY;

--
-- Name: subscriptions; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."subscriptions" ENABLE ROW LEVEL SECURITY;

--
-- Name: subscriptions subscriptions_delete_admin; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'subscriptions_delete_admin'
      AND n.nspname = 'public'
      AND c.relname = 'subscriptions'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "subscriptions_delete_admin" ON "public"."subscriptions" FOR DELETE USING ("public"."is_admin"());
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: subscriptions subscriptions_insert_own; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'subscriptions_insert_own'
      AND n.nspname = 'public'
      AND c.relname = 'subscriptions'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "subscriptions_insert_own" ON "public"."subscriptions" FOR INSERT WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."companies"
  WHERE (("companies"."id" = "subscriptions"."company_id") AND ("companies"."owner_id" = "auth"."uid"())))));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: subscriptions subscriptions_select_own; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'subscriptions_select_own'
      AND n.nspname = 'public'
      AND c.relname = 'subscriptions'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "subscriptions_select_own" ON "public"."subscriptions" FOR SELECT USING (((EXISTS ( SELECT 1
   FROM "public"."companies"
  WHERE (("companies"."id" = "subscriptions"."company_id") AND ("companies"."owner_id" = "auth"."uid"())))) OR "public"."is_admin"()));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: subscriptions subscriptions_update_own; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'subscriptions_update_own'
      AND n.nspname = 'public'
      AND c.relname = 'subscriptions'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "subscriptions_update_own" ON "public"."subscriptions" FOR UPDATE USING (((EXISTS ( SELECT 1
   FROM "public"."companies"
  WHERE (("companies"."id" = "subscriptions"."company_id") AND ("companies"."owner_id" = "auth"."uid"())))) OR "public"."is_admin"()));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: supplier_auto_quote_settings; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."supplier_auto_quote_settings" ENABLE ROW LEVEL SECURITY;

--
-- Name: auto_quotations supplier_manage_auto_quotations; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'supplier_manage_auto_quotations'
      AND n.nspname = 'public'
      AND c.relname = 'auto_quotations'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "supplier_manage_auto_quotations" ON "public"."auto_quotations" USING (("supplier_company_id" IN ( SELECT "companies"."id"
   FROM "public"."companies"
  WHERE ("companies"."owner_id" = "auth"."uid"()))));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: supplier_auto_quote_settings supplier_manage_auto_settings; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'supplier_manage_auto_settings'
      AND n.nspname = 'public'
      AND c.relname = 'supplier_auto_quote_settings'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "supplier_manage_auto_settings" ON "public"."supplier_auto_quote_settings" USING (("company_id" IN ( SELECT "companies"."id"
   FROM "public"."companies"
  WHERE ("companies"."owner_id" = "auth"."uid"()))));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: bulk_discount_rules supplier_manage_discounts; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'supplier_manage_discounts'
      AND n.nspname = 'public'
      AND c.relname = 'bulk_discount_rules'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "supplier_manage_discounts" ON "public"."bulk_discount_rules" USING (("company_id" IN ( SELECT "companies"."id"
   FROM "public"."companies"
  WHERE ("companies"."owner_id" = "auth"."uid"()))));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: product_inventory supplier_manage_inventory; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'supplier_manage_inventory'
      AND n.nspname = 'public'
      AND c.relname = 'product_inventory'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "supplier_manage_inventory" ON "public"."product_inventory" USING (("company_id" IN ( SELECT "companies"."id"
   FROM "public"."companies"
  WHERE ("companies"."owner_id" = "auth"."uid"()))));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: product_promotions supplier_manage_promotions; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'supplier_manage_promotions'
      AND n.nspname = 'public'
      AND c.relname = 'product_promotions'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "supplier_manage_promotions" ON "public"."product_promotions" TO "authenticated" USING ((("company_id" IN ( SELECT "companies"."id"
   FROM "public"."companies"
  WHERE ("companies"."owner_id" = "auth"."uid"()))) OR "public"."is_admin"())) WITH CHECK ((("company_id" IN ( SELECT "companies"."id"
   FROM "public"."companies"
  WHERE ("companies"."owner_id" = "auth"."uid"()))) OR "public"."is_admin"()));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: order_status_history supplier_read_own_order_history; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'supplier_read_own_order_history'
      AND n.nspname = 'public'
      AND c.relname = 'order_status_history'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "supplier_read_own_order_history" ON "public"."order_status_history" FOR SELECT USING (("order_id" IN ( SELECT "o"."id"
   FROM ("public"."orders" "o"
     JOIN "public"."companies" "c" ON (("c"."id" = "o"."supplier_company_id")))
  WHERE ("c"."owner_id" = "auth"."uid"()))));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: instant_quote_requests supplier_respond_iqr; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'supplier_respond_iqr'
      AND n.nspname = 'public'
      AND c.relname = 'instant_quote_requests'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "supplier_respond_iqr" ON "public"."instant_quote_requests" FOR UPDATE USING (("supplier_company_id" IN ( SELECT "companies"."id"
   FROM "public"."companies"
  WHERE ("companies"."owner_id" = "auth"."uid"()))));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: sample_requests supplier_update_own_samples; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'supplier_update_own_samples'
      AND n.nspname = 'public'
      AND c.relname = 'sample_requests'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "supplier_update_own_samples" ON "public"."sample_requests" FOR UPDATE USING (("supplier_company_id" IN ( SELECT "companies"."id"
   FROM "public"."companies"
  WHERE ("companies"."owner_id" = "auth"."uid"()))));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: instant_quote_requests supplier_view_iqr; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'supplier_view_iqr'
      AND n.nspname = 'public'
      AND c.relname = 'instant_quote_requests'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "supplier_view_iqr" ON "public"."instant_quote_requests" FOR SELECT USING (("supplier_company_id" IN ( SELECT "companies"."id"
   FROM "public"."companies"
  WHERE ("companies"."owner_id" = "auth"."uid"()))));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: lead_credit_transactions supplier_view_own_credits; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'supplier_view_own_credits'
      AND n.nspname = 'public'
      AND c.relname = 'lead_credit_transactions'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "supplier_view_own_credits" ON "public"."lead_credit_transactions" USING (("company_id" IN ( SELECT "companies"."id"
   FROM "public"."companies"
  WHERE ("companies"."owner_id" = "auth"."uid"()))));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: sample_requests supplier_view_own_samples; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'supplier_view_own_samples'
      AND n.nspname = 'public'
      AND c.relname = 'sample_requests'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "supplier_view_own_samples" ON "public"."sample_requests" FOR SELECT USING (("supplier_company_id" IN ( SELECT "companies"."id"
   FROM "public"."companies"
  WHERE ("companies"."owner_id" = "auth"."uid"()))));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: rfq_matches suppliers_read_own_matches; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'suppliers_read_own_matches'
      AND n.nspname = 'public'
      AND c.relname = 'rfq_matches'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "suppliers_read_own_matches" ON "public"."rfq_matches" FOR SELECT USING (("company_id" IN ( SELECT "companies"."id"
   FROM "public"."companies"
  WHERE ("companies"."owner_id" = "auth"."uid"()))));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: shipping_quotes user_manage_own_shipping_quotes; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'user_manage_own_shipping_quotes'
      AND n.nspname = 'public'
      AND c.relname = 'shipping_quotes'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "user_manage_own_shipping_quotes" ON "public"."shipping_quotes" USING (("requester_id" = "auth"."uid"()));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: withdrawal_requests withdrawal_insert; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'withdrawal_insert'
      AND n.nspname = 'public'
      AND c.relname = 'withdrawal_requests'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "withdrawal_insert" ON "public"."withdrawal_requests" FOR INSERT TO "authenticated" WITH CHECK ("public"."is_company_owner"("company_id"));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: withdrawal_requests; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."withdrawal_requests" ENABLE ROW LEVEL SECURITY;

--
-- Name: withdrawal_requests withdrawal_select; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'withdrawal_select'
      AND n.nspname = 'public'
      AND c.relname = 'withdrawal_requests'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "withdrawal_select" ON "public"."withdrawal_requests" FOR SELECT TO "authenticated" USING ((("public"."get_my_role"() = 'admin'::"text") OR "public"."is_company_owner"("company_id")));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- Name: withdrawal_requests withdrawal_update_admin; Type: POLICY; Schema: public; Owner: -
--

DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'withdrawal_update_admin'
      AND n.nspname = 'public'
      AND c.relname = 'withdrawal_requests'
  ) THEN
    EXECUTE $pg_schema_sql$
CREATE POLICY "withdrawal_update_admin" ON "public"."withdrawal_requests" FOR UPDATE TO "authenticated" USING (("public"."get_my_role"() = 'admin'::"text"));
$pg_schema_sql$;
  END IF;
END
$pg_schema_restore$;


--
-- PostgreSQL database dump complete
--




-- ============================================================
-- SECTION: DIFF FILTER OBJECTS
-- ============================================================
-- Objects that match diff-filter.json but cannot be represented
-- precisely by pg_dump --filter.

-- auth.users trigger: on_auth_user_created
DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger t
    JOIN pg_class c ON c.oid = t.tgrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE NOT t.tgisinternal
      AND t.tgname = 'on_auth_user_created'
      AND n.nspname = 'auth'
      AND c.relname = 'users'
  ) THEN
    EXECUTE 'CREATE TRIGGER on_auth_user_created AFTER INSERT ON auth.users FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();';
  END IF;
END
$pg_schema_restore$;
-- policy: "Authenticated and anon users can upload rfq images" on storage.objects
DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'Authenticated and anon users can upload rfq images'
      AND n.nspname = 'storage'
      AND c.relname = 'objects'
  ) THEN
    EXECUTE 'CREATE POLICY "Authenticated and anon users can upload rfq images" ON storage.objects AS PERMISSIVE FOR INSERT TO PUBLIC WITH CHECK ((bucket_id = ANY (ARRAY[''product-images''::text, ''company-assets''::text, ''rfq-images''::text, ''attachments''::text, ''avatars''::text])));';
  END IF;
END
$pg_schema_restore$;
-- policy: "Authenticated users can upload company assets" on storage.objects
DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'Authenticated users can upload company assets'
      AND n.nspname = 'storage'
      AND c.relname = 'objects'
  ) THEN
    EXECUTE 'CREATE POLICY "Authenticated users can upload company assets" ON storage.objects AS PERMISSIVE FOR INSERT TO PUBLIC WITH CHECK (((bucket_id = ''company-assets''::text) AND (auth.role() = ''authenticated''::text)));';
  END IF;
END
$pg_schema_restore$;
-- policy: "Authenticated users upload dispute evidence" on storage.objects
DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'Authenticated users upload dispute evidence'
      AND n.nspname = 'storage'
      AND c.relname = 'objects'
  ) THEN
    EXECUTE 'CREATE POLICY "Authenticated users upload dispute evidence" ON storage.objects AS PERMISSIVE FOR INSERT TO PUBLIC WITH CHECK (((bucket_id = ''dispute-evidence''::text) AND (auth.uid() IS NOT NULL)));';
  END IF;
END
$pg_schema_restore$;
-- policy: "Company assets are publicly readable" on storage.objects
DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'Company assets are publicly readable'
      AND n.nspname = 'storage'
      AND c.relname = 'objects'
  ) THEN
    EXECUTE 'CREATE POLICY "Company assets are publicly readable" ON storage.objects AS PERMISSIVE FOR SELECT TO PUBLIC USING ((bucket_id = ''company-assets''::text));';
  END IF;
END
$pg_schema_restore$;
-- policy: "Owner can update company assets" on storage.objects
DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'Owner can update company assets'
      AND n.nspname = 'storage'
      AND c.relname = 'objects'
  ) THEN
    EXECUTE 'CREATE POLICY "Owner can update company assets" ON storage.objects AS PERMISSIVE FOR UPDATE TO PUBLIC USING (((bucket_id = ''company-assets''::text) AND (auth.role() = ''authenticated''::text)));';
  END IF;
END
$pg_schema_restore$;
-- policy: "Public can view rfq images" on storage.objects
DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'Public can view rfq images'
      AND n.nspname = 'storage'
      AND c.relname = 'objects'
  ) THEN
    EXECUTE 'CREATE POLICY "Public can view rfq images" ON storage.objects AS PERMISSIVE FOR SELECT TO PUBLIC USING ((bucket_id = ANY (ARRAY[''product-images''::text, ''company-assets''::text, ''rfq-images''::text, ''attachments''::text, ''avatars''::text])));';
  END IF;
END
$pg_schema_restore$;
-- policy: "Public delete access for product-images" on storage.objects
DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'Public delete access for product-images'
      AND n.nspname = 'storage'
      AND c.relname = 'objects'
  ) THEN
    EXECUTE 'CREATE POLICY "Public delete access for product-images" ON storage.objects AS PERMISSIVE FOR DELETE TO PUBLIC USING ((bucket_id = ''product-images''::text));';
  END IF;
END
$pg_schema_restore$;
-- policy: "Public insert access for avatars" on storage.objects
DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'Public insert access for avatars'
      AND n.nspname = 'storage'
      AND c.relname = 'objects'
  ) THEN
    EXECUTE 'CREATE POLICY "Public insert access for avatars" ON storage.objects AS PERMISSIVE FOR INSERT TO PUBLIC WITH CHECK ((bucket_id = ''avatars''::text));';
  END IF;
END
$pg_schema_restore$;
-- policy: "Public insert access for company-assets" on storage.objects
DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'Public insert access for company-assets'
      AND n.nspname = 'storage'
      AND c.relname = 'objects'
  ) THEN
    EXECUTE 'CREATE POLICY "Public insert access for company-assets" ON storage.objects AS PERMISSIVE FOR INSERT TO PUBLIC WITH CHECK ((bucket_id = ''company-assets''::text));';
  END IF;
END
$pg_schema_restore$;
-- policy: "Public insert access for product-images" on storage.objects
DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'Public insert access for product-images'
      AND n.nspname = 'storage'
      AND c.relname = 'objects'
  ) THEN
    EXECUTE 'CREATE POLICY "Public insert access for product-images" ON storage.objects AS PERMISSIVE FOR INSERT TO PUBLIC WITH CHECK ((bucket_id = ''product-images''::text));';
  END IF;
END
$pg_schema_restore$;
-- policy: "Public insert access for verification-docs" on storage.objects
DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'Public insert access for verification-docs'
      AND n.nspname = 'storage'
      AND c.relname = 'objects'
  ) THEN
    EXECUTE 'CREATE POLICY "Public insert access for verification-docs" ON storage.objects AS PERMISSIVE FOR INSERT TO PUBLIC WITH CHECK ((bucket_id = ''verification-docs''::text));';
  END IF;
END
$pg_schema_restore$;
-- policy: "Public read access for avatars" on storage.objects
DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'Public read access for avatars'
      AND n.nspname = 'storage'
      AND c.relname = 'objects'
  ) THEN
    EXECUTE 'CREATE POLICY "Public read access for avatars" ON storage.objects AS PERMISSIVE FOR SELECT TO PUBLIC USING ((bucket_id = ''avatars''::text));';
  END IF;
END
$pg_schema_restore$;
-- policy: "Public read access for company-assets" on storage.objects
DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'Public read access for company-assets'
      AND n.nspname = 'storage'
      AND c.relname = 'objects'
  ) THEN
    EXECUTE 'CREATE POLICY "Public read access for company-assets" ON storage.objects AS PERMISSIVE FOR SELECT TO PUBLIC USING ((bucket_id = ''company-assets''::text));';
  END IF;
END
$pg_schema_restore$;
-- policy: "Public read access for product-images" on storage.objects
DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'Public read access for product-images'
      AND n.nspname = 'storage'
      AND c.relname = 'objects'
  ) THEN
    EXECUTE 'CREATE POLICY "Public read access for product-images" ON storage.objects AS PERMISSIVE FOR SELECT TO PUBLIC USING ((bucket_id = ''product-images''::text));';
  END IF;
END
$pg_schema_restore$;
-- policy: "Public read access for verification-docs" on storage.objects
DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'Public read access for verification-docs'
      AND n.nspname = 'storage'
      AND c.relname = 'objects'
  ) THEN
    EXECUTE 'CREATE POLICY "Public read access for verification-docs" ON storage.objects AS PERMISSIVE FOR SELECT TO PUBLIC USING ((bucket_id = ''verification-docs''::text));';
  END IF;
END
$pg_schema_restore$;
-- policy: "Public update access for avatars" on storage.objects
DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'Public update access for avatars'
      AND n.nspname = 'storage'
      AND c.relname = 'objects'
  ) THEN
    EXECUTE 'CREATE POLICY "Public update access for avatars" ON storage.objects AS PERMISSIVE FOR UPDATE TO PUBLIC USING ((bucket_id = ''avatars''::text));';
  END IF;
END
$pg_schema_restore$;
-- policy: "Public update access for company-assets" on storage.objects
DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'Public update access for company-assets'
      AND n.nspname = 'storage'
      AND c.relname = 'objects'
  ) THEN
    EXECUTE 'CREATE POLICY "Public update access for company-assets" ON storage.objects AS PERMISSIVE FOR UPDATE TO PUBLIC USING ((bucket_id = ''company-assets''::text));';
  END IF;
END
$pg_schema_restore$;
-- policy: "Public update access for product-images" on storage.objects
DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'Public update access for product-images'
      AND n.nspname = 'storage'
      AND c.relname = 'objects'
  ) THEN
    EXECUTE 'CREATE POLICY "Public update access for product-images" ON storage.objects AS PERMISSIVE FOR UPDATE TO PUBLIC USING ((bucket_id = ''product-images''::text));';
  END IF;
END
$pg_schema_restore$;
-- policy: "Users access own dispute evidence" on storage.objects
DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'Users access own dispute evidence'
      AND n.nspname = 'storage'
      AND c.relname = 'objects'
  ) THEN
    EXECUTE 'CREATE POLICY "Users access own dispute evidence" ON storage.objects AS PERMISSIVE FOR SELECT TO PUBLIC USING (((bucket_id = ''dispute-evidence''::text) AND (((auth.uid())::text = (storage.foldername(name))[1]) OR (EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = ''admin''::public.user_role)))))));';
  END IF;
END
$pg_schema_restore$;
-- policy: "Users can update and delete their uploaded objects" on storage.objects
DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'Users can update and delete their uploaded objects'
      AND n.nspname = 'storage'
      AND c.relname = 'objects'
  ) THEN
    EXECUTE 'CREATE POLICY "Users can update and delete their uploaded objects" ON storage.objects AS PERMISSIVE FOR UPDATE TO PUBLIC USING ((bucket_id = ANY (ARRAY[''product-images''::text, ''company-assets''::text, ''rfq-images''::text, ''attachments''::text, ''avatars''::text])));';
  END IF;
END
$pg_schema_restore$;
-- policy: avatars_owner_write on storage.objects
DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'avatars_owner_write'
      AND n.nspname = 'storage'
      AND c.relname = 'objects'
  ) THEN
    EXECUTE 'CREATE POLICY avatars_owner_write ON storage.objects AS PERMISSIVE FOR INSERT TO PUBLIC WITH CHECK (((bucket_id = ''avatars''::text) AND ((auth.uid())::text = (storage.foldername(name))[1])));';
  END IF;
END
$pg_schema_restore$;
-- policy: avatars_public_read on storage.objects
DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'avatars_public_read'
      AND n.nspname = 'storage'
      AND c.relname = 'objects'
  ) THEN
    EXECUTE 'CREATE POLICY avatars_public_read ON storage.objects AS PERMISSIVE FOR SELECT TO PUBLIC USING ((bucket_id = ''avatars''::text));';
  END IF;
END
$pg_schema_restore$;
-- policy: business_docs_owner on storage.objects
DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'business_docs_owner'
      AND n.nspname = 'storage'
      AND c.relname = 'objects'
  ) THEN
    EXECUTE 'CREATE POLICY business_docs_owner ON storage.objects AS PERMISSIVE FOR ALL TO PUBLIC USING (((bucket_id = ''business-docs''::text) AND ((auth.uid())::text = (storage.foldername(name))[1])));';
  END IF;
END
$pg_schema_restore$;
-- policy: chat_files_parties on storage.objects
DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'chat_files_parties'
      AND n.nspname = 'storage'
      AND c.relname = 'objects'
  ) THEN
    EXECUTE 'CREATE POLICY chat_files_parties ON storage.objects AS PERMISSIVE FOR ALL TO authenticated USING (((bucket_id = ''chat-files''::text) AND ((storage.foldername(name))[1] = (auth.uid())::text))) WITH CHECK (((bucket_id = ''chat-files''::text) AND ((storage.foldername(name))[1] = (auth.uid())::text)));';
  END IF;
END
$pg_schema_restore$;
-- policy: dispute_evidence_parties on storage.objects
DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'dispute_evidence_parties'
      AND n.nspname = 'storage'
      AND c.relname = 'objects'
  ) THEN
    EXECUTE 'CREATE POLICY dispute_evidence_parties ON storage.objects AS PERMISSIVE FOR ALL TO authenticated USING (((bucket_id = ''dispute-evidence''::text) AND ((storage.foldername(name))[1] = (auth.uid())::text))) WITH CHECK (((bucket_id = ''dispute-evidence''::text) AND ((storage.foldername(name))[1] = (auth.uid())::text)));';
  END IF;
END
$pg_schema_restore$;
-- policy: invoice_pdf_select_own on storage.objects
DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'invoice_pdf_select_own'
      AND n.nspname = 'storage'
      AND c.relname = 'objects'
  ) THEN
    EXECUTE 'CREATE POLICY invoice_pdf_select_own ON storage.objects AS PERMISSIVE FOR SELECT TO PUBLIC USING (((bucket_id = ''invoices-pdfs''::text) AND ((auth.uid())::text = (storage.foldername(name))[1])));';
  END IF;
END
$pg_schema_restore$;
-- policy: invoice_pdf_service_all on storage.objects
DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'invoice_pdf_service_all'
      AND n.nspname = 'storage'
      AND c.relname = 'objects'
  ) THEN
    EXECUTE 'CREATE POLICY invoice_pdf_service_all ON storage.objects AS PERMISSIVE FOR ALL TO PUBLIC USING (((bucket_id = ''invoices-pdfs''::text) AND ((auth.jwt() ->> ''role''::text) = ''service_role''::text))) WITH CHECK (((bucket_id = ''invoices-pdfs''::text) AND ((auth.jwt() ->> ''role''::text) = ''service_role''::text)));';
  END IF;
END
$pg_schema_restore$;
-- policy: product_images_owner_write on storage.objects
DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'product_images_owner_write'
      AND n.nspname = 'storage'
      AND c.relname = 'objects'
  ) THEN
    EXECUTE 'CREATE POLICY product_images_owner_write ON storage.objects AS PERMISSIVE FOR INSERT TO PUBLIC WITH CHECK (((bucket_id = ''product-images''::text) AND ((auth.uid())::text = (storage.foldername(name))[1])));';
  END IF;
END
$pg_schema_restore$;
-- policy: product_images_public_read on storage.objects
DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'product_images_public_read'
      AND n.nspname = 'storage'
      AND c.relname = 'objects'
  ) THEN
    EXECUTE 'CREATE POLICY product_images_public_read ON storage.objects AS PERMISSIVE FOR SELECT TO PUBLIC USING ((bucket_id = ''product-images''::text));';
  END IF;
END
$pg_schema_restore$;
-- policy: quotation_pdfs_parties on storage.objects
DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'quotation_pdfs_parties'
      AND n.nspname = 'storage'
      AND c.relname = 'objects'
  ) THEN
    EXECUTE 'CREATE POLICY quotation_pdfs_parties ON storage.objects AS PERMISSIVE FOR ALL TO authenticated USING ((bucket_id = ''quotation-pdfs''::text)) WITH CHECK ((bucket_id = ''quotation-pdfs''::text));';
  END IF;
END
$pg_schema_restore$;
-- policy: verification_docs_admin on storage.objects
DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'verification_docs_admin'
      AND n.nspname = 'storage'
      AND c.relname = 'objects'
  ) THEN
    EXECUTE 'CREATE POLICY verification_docs_admin ON storage.objects AS PERMISSIVE FOR SELECT TO authenticated USING (((bucket_id = ''verification-docs''::text) AND (public.get_my_role() = ''admin''::text)));';
  END IF;
END
$pg_schema_restore$;
-- policy: verification_docs_owner on storage.objects
DO $pg_schema_restore$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE pol.polname = 'verification_docs_owner'
      AND n.nspname = 'storage'
      AND c.relname = 'objects'
  ) THEN
    EXECUTE 'CREATE POLICY verification_docs_owner ON storage.objects AS PERMISSIVE FOR ALL TO authenticated USING (((bucket_id = ''verification-docs''::text) AND ((storage.foldername(name))[1] = (auth.uid())::text))) WITH CHECK (((bucket_id = ''verification-docs''::text) AND ((storage.foldername(name))[1] = (auth.uid())::text)));';
  END IF;
END
$pg_schema_restore$;
-- publication table: supabase_realtime -> public.conversations
DO $pg_schema_restore$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_publication WHERE pubname = 'supabase_realtime') AND NOT EXISTS (
    SELECT 1 FROM pg_publication_rel pr
    JOIN pg_publication p ON p.oid = pr.prpubid
    WHERE p.pubname = 'supabase_realtime'
      AND pr.prrelid = to_regclass('public.conversations')
  ) THEN
    EXECUTE 'ALTER PUBLICATION supabase_realtime ADD TABLE public.conversations;';
  END IF;
END
$pg_schema_restore$;
-- publication table: supabase_realtime -> public.messages
DO $pg_schema_restore$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_publication WHERE pubname = 'supabase_realtime') AND NOT EXISTS (
    SELECT 1 FROM pg_publication_rel pr
    JOIN pg_publication p ON p.oid = pr.prpubid
    WHERE p.pubname = 'supabase_realtime'
      AND pr.prrelid = to_regclass('public.messages')
  ) THEN
    EXECUTE 'ALTER PUBLICATION supabase_realtime ADD TABLE public.messages;';
  END IF;
END
$pg_schema_restore$;
-- publication table: supabase_realtime -> public.notifications
DO $pg_schema_restore$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_publication WHERE pubname = 'supabase_realtime') AND NOT EXISTS (
    SELECT 1 FROM pg_publication_rel pr
    JOIN pg_publication p ON p.oid = pr.prpubid
    WHERE p.pubname = 'supabase_realtime'
      AND pr.prrelid = to_regclass('public.notifications')
  ) THEN
    EXECUTE 'ALTER PUBLICATION supabase_realtime ADD TABLE public.notifications;';
  END IF;
END
$pg_schema_restore$;
-- publication table: supabase_realtime -> public.requirements
DO $pg_schema_restore$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_publication WHERE pubname = 'supabase_realtime') AND NOT EXISTS (
    SELECT 1 FROM pg_publication_rel pr
    JOIN pg_publication p ON p.oid = pr.prpubid
    WHERE p.pubname = 'supabase_realtime'
      AND pr.prrelid = to_regclass('public.requirements')
  ) THEN
    EXECUTE 'ALTER PUBLICATION supabase_realtime ADD TABLE public.requirements;';
  END IF;
END
$pg_schema_restore$;

-- ============================================================
-- SECTION: STORAGE BUCKETS DATA
-- ============================================================

INSERT INTO "storage"."buckets" ("id", "name", "owner", "created_at", "updated_at", "public", "avif_autodetection", "file_size_limit", "allowed_mime_types", "owner_id", "type") VALUES ('attachments', 'attachments', NULL, '2026-09-16 12:53:38.254484+00', '2026-09-16 12:53:38.254484+00', 'false', 'false', NULL, NULL, NULL, 'STANDARD') ON CONFLICT ("id") DO UPDATE SET "name" = EXCLUDED."name", "owner" = EXCLUDED."owner", "created_at" = EXCLUDED."created_at", "updated_at" = EXCLUDED."updated_at", "public" = EXCLUDED."public", "avif_autodetection" = EXCLUDED."avif_autodetection", "file_size_limit" = EXCLUDED."file_size_limit", "allowed_mime_types" = EXCLUDED."allowed_mime_types", "owner_id" = EXCLUDED."owner_id", "type" = EXCLUDED."type";
INSERT INTO "storage"."buckets" ("id", "name", "owner", "created_at", "updated_at", "public", "avif_autodetection", "file_size_limit", "allowed_mime_types", "owner_id", "type") VALUES ('avatars', 'avatars', NULL, '2026-09-16 12:53:38.254484+00', '2026-09-16 12:53:38.254484+00', 'true', 'false', '5242880', '{image/jpeg,image/png,image/webp,image/gif,image/avif}', NULL, 'STANDARD') ON CONFLICT ("id") DO UPDATE SET "name" = EXCLUDED."name", "owner" = EXCLUDED."owner", "created_at" = EXCLUDED."created_at", "updated_at" = EXCLUDED."updated_at", "public" = EXCLUDED."public", "avif_autodetection" = EXCLUDED."avif_autodetection", "file_size_limit" = EXCLUDED."file_size_limit", "allowed_mime_types" = EXCLUDED."allowed_mime_types", "owner_id" = EXCLUDED."owner_id", "type" = EXCLUDED."type";
INSERT INTO "storage"."buckets" ("id", "name", "owner", "created_at", "updated_at", "public", "avif_autodetection", "file_size_limit", "allowed_mime_types", "owner_id", "type") VALUES ('business-docs', 'business-docs', NULL, '2026-09-16 12:53:38.254484+00', '2026-09-16 12:53:38.254484+00', 'false', 'false', NULL, NULL, NULL, 'STANDARD') ON CONFLICT ("id") DO UPDATE SET "name" = EXCLUDED."name", "owner" = EXCLUDED."owner", "created_at" = EXCLUDED."created_at", "updated_at" = EXCLUDED."updated_at", "public" = EXCLUDED."public", "avif_autodetection" = EXCLUDED."avif_autodetection", "file_size_limit" = EXCLUDED."file_size_limit", "allowed_mime_types" = EXCLUDED."allowed_mime_types", "owner_id" = EXCLUDED."owner_id", "type" = EXCLUDED."type";
INSERT INTO "storage"."buckets" ("id", "name", "owner", "created_at", "updated_at", "public", "avif_autodetection", "file_size_limit", "allowed_mime_types", "owner_id", "type") VALUES ('chat-files', 'chat-files', NULL, '2026-09-17 19:18:31.057507+00', '2026-09-17 19:18:31.057507+00', 'false', 'false', NULL, NULL, NULL, 'STANDARD') ON CONFLICT ("id") DO UPDATE SET "name" = EXCLUDED."name", "owner" = EXCLUDED."owner", "created_at" = EXCLUDED."created_at", "updated_at" = EXCLUDED."updated_at", "public" = EXCLUDED."public", "avif_autodetection" = EXCLUDED."avif_autodetection", "file_size_limit" = EXCLUDED."file_size_limit", "allowed_mime_types" = EXCLUDED."allowed_mime_types", "owner_id" = EXCLUDED."owner_id", "type" = EXCLUDED."type";
INSERT INTO "storage"."buckets" ("id", "name", "owner", "created_at", "updated_at", "public", "avif_autodetection", "file_size_limit", "allowed_mime_types", "owner_id", "type") VALUES ('company-assets', 'company-assets', NULL, '2026-09-16 13:15:08.121517+00', '2026-09-16 13:15:08.121517+00', 'true', 'false', '10485760', '{image/jpeg,image/png,image/webp,image/gif,image/avif}', NULL, 'STANDARD') ON CONFLICT ("id") DO UPDATE SET "name" = EXCLUDED."name", "owner" = EXCLUDED."owner", "created_at" = EXCLUDED."created_at", "updated_at" = EXCLUDED."updated_at", "public" = EXCLUDED."public", "avif_autodetection" = EXCLUDED."avif_autodetection", "file_size_limit" = EXCLUDED."file_size_limit", "allowed_mime_types" = EXCLUDED."allowed_mime_types", "owner_id" = EXCLUDED."owner_id", "type" = EXCLUDED."type";
INSERT INTO "storage"."buckets" ("id", "name", "owner", "created_at", "updated_at", "public", "avif_autodetection", "file_size_limit", "allowed_mime_types", "owner_id", "type") VALUES ('dispute-evidence', 'dispute-evidence', NULL, '2026-09-17 19:18:31.057507+00', '2026-09-17 19:18:31.057507+00', 'false', 'false', NULL, NULL, NULL, 'STANDARD') ON CONFLICT ("id") DO UPDATE SET "name" = EXCLUDED."name", "owner" = EXCLUDED."owner", "created_at" = EXCLUDED."created_at", "updated_at" = EXCLUDED."updated_at", "public" = EXCLUDED."public", "avif_autodetection" = EXCLUDED."avif_autodetection", "file_size_limit" = EXCLUDED."file_size_limit", "allowed_mime_types" = EXCLUDED."allowed_mime_types", "owner_id" = EXCLUDED."owner_id", "type" = EXCLUDED."type";
INSERT INTO "storage"."buckets" ("id", "name", "owner", "created_at", "updated_at", "public", "avif_autodetection", "file_size_limit", "allowed_mime_types", "owner_id", "type") VALUES ('invoices-pdfs', 'invoices-pdfs', NULL, '2026-09-21 19:00:20.532919+00', '2026-09-21 19:00:20.532919+00', 'false', 'false', '52428800', '{application/pdf}', NULL, 'STANDARD') ON CONFLICT ("id") DO UPDATE SET "name" = EXCLUDED."name", "owner" = EXCLUDED."owner", "created_at" = EXCLUDED."created_at", "updated_at" = EXCLUDED."updated_at", "public" = EXCLUDED."public", "avif_autodetection" = EXCLUDED."avif_autodetection", "file_size_limit" = EXCLUDED."file_size_limit", "allowed_mime_types" = EXCLUDED."allowed_mime_types", "owner_id" = EXCLUDED."owner_id", "type" = EXCLUDED."type";
INSERT INTO "storage"."buckets" ("id", "name", "owner", "created_at", "updated_at", "public", "avif_autodetection", "file_size_limit", "allowed_mime_types", "owner_id", "type") VALUES ('product-images', 'product-images', NULL, '2026-09-16 12:53:38.254484+00', '2026-09-16 12:53:38.254484+00', 'true', 'false', '10485760', '{image/jpeg,image/png,image/webp,image/gif,image/avif}', NULL, 'STANDARD') ON CONFLICT ("id") DO UPDATE SET "name" = EXCLUDED."name", "owner" = EXCLUDED."owner", "created_at" = EXCLUDED."created_at", "updated_at" = EXCLUDED."updated_at", "public" = EXCLUDED."public", "avif_autodetection" = EXCLUDED."avif_autodetection", "file_size_limit" = EXCLUDED."file_size_limit", "allowed_mime_types" = EXCLUDED."allowed_mime_types", "owner_id" = EXCLUDED."owner_id", "type" = EXCLUDED."type";
INSERT INTO "storage"."buckets" ("id", "name", "owner", "created_at", "updated_at", "public", "avif_autodetection", "file_size_limit", "allowed_mime_types", "owner_id", "type") VALUES ('quotation-pdfs', 'quotation-pdfs', NULL, '2026-09-17 19:18:31.057507+00', '2026-09-17 19:18:31.057507+00', 'false', 'false', NULL, NULL, NULL, 'STANDARD') ON CONFLICT ("id") DO UPDATE SET "name" = EXCLUDED."name", "owner" = EXCLUDED."owner", "created_at" = EXCLUDED."created_at", "updated_at" = EXCLUDED."updated_at", "public" = EXCLUDED."public", "avif_autodetection" = EXCLUDED."avif_autodetection", "file_size_limit" = EXCLUDED."file_size_limit", "allowed_mime_types" = EXCLUDED."allowed_mime_types", "owner_id" = EXCLUDED."owner_id", "type" = EXCLUDED."type";
INSERT INTO "storage"."buckets" ("id", "name", "owner", "created_at", "updated_at", "public", "avif_autodetection", "file_size_limit", "allowed_mime_types", "owner_id", "type") VALUES ('rfq-images', 'rfq-images', NULL, '2026-09-30 04:31:52.506935+00', '2026-09-30 04:31:52.506935+00', 'true', 'false', NULL, NULL, NULL, 'STANDARD') ON CONFLICT ("id") DO UPDATE SET "name" = EXCLUDED."name", "owner" = EXCLUDED."owner", "created_at" = EXCLUDED."created_at", "updated_at" = EXCLUDED."updated_at", "public" = EXCLUDED."public", "avif_autodetection" = EXCLUDED."avif_autodetection", "file_size_limit" = EXCLUDED."file_size_limit", "allowed_mime_types" = EXCLUDED."allowed_mime_types", "owner_id" = EXCLUDED."owner_id", "type" = EXCLUDED."type";
INSERT INTO "storage"."buckets" ("id", "name", "owner", "created_at", "updated_at", "public", "avif_autodetection", "file_size_limit", "allowed_mime_types", "owner_id", "type") VALUES ('verification-docs', 'verification-docs', NULL, '2026-09-17 19:18:31.057507+00', '2026-09-17 19:18:31.057507+00', 'true', 'false', '10485760', '{image/jpeg,image/png,image/webp,application/pdf}', NULL, 'STANDARD') ON CONFLICT ("id") DO UPDATE SET "name" = EXCLUDED."name", "owner" = EXCLUDED."owner", "created_at" = EXCLUDED."created_at", "updated_at" = EXCLUDED."updated_at", "public" = EXCLUDED."public", "avif_autodetection" = EXCLUDED."avif_autodetection", "file_size_limit" = EXCLUDED."file_size_limit", "allowed_mime_types" = EXCLUDED."allowed_mime_types", "owner_id" = EXCLUDED."owner_id", "type" = EXCLUDED."type";

-- ============================================================
-- SECTION: CRON JOBS
-- ============================================================
-- 用户自定义 pg_cron 任务。

DO $pg_cron_restore$
BEGIN
  IF EXISTS (SELECT 1 FROM cron.job WHERE jobname = 'daily-morning-unpaid-manufacturer-reminders') THEN
    PERFORM cron.alter_job(
      job_id := (SELECT jobid FROM cron.job WHERE jobname = 'daily-morning-unpaid-manufacturer-reminders'),
      schedule := '0 8 * * *',
      command := 'SELECT public.notify_unpaid_manufacturers()',
      active := true
    );
  ELSE
    PERFORM cron.schedule('daily-morning-unpaid-manufacturer-reminders', '0 8 * * *', 'SELECT public.notify_unpaid_manufacturers()');
  END IF;
END
$pg_cron_restore$;
DO $pg_cron_restore$
BEGIN
  IF EXISTS (SELECT 1 FROM cron.job WHERE jobname = 'sync-photos-every-minute') THEN
    PERFORM cron.alter_job(
      job_id := (SELECT jobid FROM cron.job WHERE jobname = 'sync-photos-every-minute'),
      schedule := '* * * * *',
      command := '
  SELECT net.http_post(
      url := (SELECT decrypted_secret FROM vault.decrypted_secrets WHERE name = ''project_url'') || ''/functions/v1/pixabay-product-image'',
      headers := jsonb_build_object(
        ''Content-Type'', ''application/json'',
        ''apikey'', (SELECT decrypted_secret FROM vault.decrypted_secrets WHERE name = ''publishable_key''),
        ''Authorization'', ''Bearer '' || (SELECT decrypted_secret FROM vault.decrypted_secrets WHERE name = ''publishable_key'')
      ),
      body := jsonb_build_object(
        ''action'', ''sync_all_posts_and_companies'',
        ''timestamp'', now()
      )
  ) AS request_id;
  ',
      active := true
    );
  ELSE
    PERFORM cron.schedule('sync-photos-every-minute', '* * * * *', '
  SELECT net.http_post(
      url := (SELECT decrypted_secret FROM vault.decrypted_secrets WHERE name = ''project_url'') || ''/functions/v1/pixabay-product-image'',
      headers := jsonb_build_object(
        ''Content-Type'', ''application/json'',
        ''apikey'', (SELECT decrypted_secret FROM vault.decrypted_secrets WHERE name = ''publishable_key''),
        ''Authorization'', ''Bearer '' || (SELECT decrypted_secret FROM vault.decrypted_secrets WHERE name = ''publishable_key'')
      ),
      body := jsonb_build_object(
        ''action'', ''sync_all_posts_and_companies'',
        ''timestamp'', now()
      )
  ) AS request_id;
  ');
  END IF;
END
$pg_cron_restore$;
