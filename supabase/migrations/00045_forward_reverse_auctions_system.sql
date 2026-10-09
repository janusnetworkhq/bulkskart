-- 1. Extend requirements with Reverse Auction fields
ALTER TABLE requirements 
ADD COLUMN IF NOT EXISTS is_reverse_auction boolean DEFAULT true,
ADD COLUMN IF NOT EXISTS auction_end_time timestamptz DEFAULT (now() + interval '60 minutes'),
ADD COLUMN IF NOT EXISTS auction_duration_minutes integer DEFAULT 60,
ADD COLUMN IF NOT EXISTS anti_sniping_enabled boolean DEFAULT true,
ADD COLUMN IF NOT EXISTS target_price_min numeric DEFAULT 60,
ADD COLUMN IF NOT EXISTS target_price_max numeric DEFAULT 75,
ADD COLUMN IF NOT EXISTS delivery_location text DEFAULT 'Tiruppur, Tamil Nadu, India',
ADD COLUMN IF NOT EXISTS lead_time_days integer DEFAULT 7,
ADD COLUMN IF NOT EXISTS payment_terms text DEFAULT '50% advance, 50% before dispatch',
ADD COLUMN IF NOT EXISTS sample_required text DEFAULT 'Yes (5 metre sample)',
ADD COLUMN IF NOT EXISTS interested_suppliers_count integer DEFAULT 120,
ADD COLUMN IF NOT EXISTS awarded_quotation_id uuid,
ADD COLUMN IF NOT EXISTS awarded_supplier_id uuid;

-- 2. Extend quotations with 3-Step Wizard breakdown fields
ALTER TABLE quotations
ADD COLUMN IF NOT EXISTS quotation_number text,
ADD COLUMN IF NOT EXISTS rfq_id_display text,
ADD COLUMN IF NOT EXISTS freight_charges numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS packaging_charges numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS tax_rate numeric DEFAULT 18,
ADD COLUMN IF NOT EXISTS tax_amount numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS subtotal numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS total_quotation_value numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS delivery_lead_days integer DEFAULT 7,
ADD COLUMN IF NOT EXISTS compliance_documents jsonb DEFAULT '[]'::jsonb,
ADD COLUMN IF NOT EXISTS revision_number integer DEFAULT 1,
ADD COLUMN IF NOT EXISTS is_latest boolean DEFAULT true,
ADD COLUMN IF NOT EXISTS parent_quotation_id uuid,
ADD COLUMN IF NOT EXISTS spec_match_score integer DEFAULT 95,
ADD COLUMN IF NOT EXISTS terms_accepted boolean DEFAULT true;

-- 3. Create Auctions Table for Forward (and unified) Auctions
CREATE TABLE IF NOT EXISTS auctions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  auction_number text NOT NULL UNIQUE,
  auction_type text NOT NULL DEFAULT 'forward', -- 'forward' or 'reverse'
  seller_id uuid REFERENCES profiles(id),
  seller_company_id uuid REFERENCES companies(id),
  title text NOT NULL,
  description text,
  category_id uuid REFERENCES categories(id),
  images text[] DEFAULT '{}',
  total_quantity integer NOT NULL DEFAULT 1000,
  moq integer NOT NULL DEFAULT 100,
  quantity_unit text NOT NULL DEFAULT 'Pieces',
  starting_price numeric NOT NULL DEFAULT 100,
  reserve_price numeric NOT NULL DEFAULT 150,
  min_bid_increment numeric NOT NULL DEFAULT 10,
  current_highest_bid numeric NOT NULL DEFAULT 0,
  highest_bidder_id uuid REFERENCES profiles(id),
  highest_bidder_name text,
  total_bids integer NOT NULL DEFAULT 0,
  currency text NOT NULL DEFAULT 'INR',
  duration_minutes integer NOT NULL DEFAULT 60,
  start_time timestamptz NOT NULL DEFAULT now(),
  end_time timestamptz NOT NULL DEFAULT (now() + interval '60 minutes'),
  anti_sniping_enabled boolean NOT NULL DEFAULT true,
  anti_sniping_trigger_seconds integer NOT NULL DEFAULT 120,
  anti_sniping_extend_seconds integer NOT NULL DEFAULT 120,
  status text NOT NULL DEFAULT 'live', -- 'scheduled', 'live', 'closing_soon', 'under_review', 'awarded', 'completed', 'cancelled', 'no_winner'
  winner_id uuid REFERENCES profiles(id),
  winning_bid_id uuid,
  specifications jsonb DEFAULT '{}'::jsonb,
  tax_rate numeric DEFAULT 18,
  freight_terms text DEFAULT 'Ex-Factory / FOB',
  packaging_details text DEFAULT 'Standard export corrugated pallet packing',
  payment_terms text DEFAULT '50% advance, 50% before dispatch',
  delivery_location text DEFAULT 'Nhava Sheva Port / Mumbai, India',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- 4. Create Forward Bids Table
CREATE TABLE IF NOT EXISTS forward_bids (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  auction_id uuid REFERENCES auctions(id) ON DELETE CASCADE NOT NULL,
  bidder_id uuid NOT NULL DEFAULT auth.uid(),
  bidder_company_name text,
  bid_amount numeric NOT NULL,
  quantity integer NOT NULL DEFAULT 1,
  total_value numeric NOT NULL,
  currency text NOT NULL DEFAULT 'INR',
  status text NOT NULL DEFAULT 'accepted', -- 'accepted', 'outbid', 'rejected', 'winning'
  server_timestamp timestamptz NOT NULL DEFAULT now(),
  notes text,
  created_at timestamptz NOT NULL DEFAULT now()
);

-- 5. Enable RLS on all tables
ALTER TABLE auctions ENABLE ROW LEVEL SECURITY;
ALTER TABLE forward_bids ENABLE ROW LEVEL SECURITY;

-- Auctions RLS policies
DROP POLICY IF EXISTS "Public read access to auctions" ON auctions;
CREATE POLICY "Public read access to auctions" ON auctions FOR SELECT USING (true);

DROP POLICY IF EXISTS "Authenticated users can create auctions" ON auctions;
CREATE POLICY "Authenticated users can create auctions" ON auctions FOR INSERT WITH CHECK (auth.role() = 'authenticated');

DROP POLICY IF EXISTS "Sellers and admins can update auctions" ON auctions;
CREATE POLICY "Sellers and admins can update auctions" ON auctions FOR UPDATE USING (
  auth.uid() = seller_id OR 
  EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
);

-- Forward Bids RLS policies
DROP POLICY IF EXISTS "Public read access to forward_bids" ON forward_bids;
CREATE POLICY "Public read access to forward_bids" ON forward_bids FOR SELECT USING (true);

DROP POLICY IF EXISTS "Authenticated users can insert bids" ON forward_bids;
CREATE POLICY "Authenticated users can insert bids" ON forward_bids FOR INSERT WITH CHECK (
  auth.role() = 'authenticated'
);

-- 6. Atomic Bidding Stored Procedure
CREATE OR REPLACE FUNCTION place_forward_bid(
  p_auction_id uuid,
  p_bid_amount numeric,
  p_quantity integer,
  p_bidder_company_name text DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
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
