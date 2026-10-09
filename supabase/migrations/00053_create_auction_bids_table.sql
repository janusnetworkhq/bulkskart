CREATE TABLE IF NOT EXISTS public.auction_bids (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    auction_id UUID NOT NULL REFERENCES public.auctions(id) ON DELETE CASCADE,
    bidder_user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    bidder_company_id UUID REFERENCES public.companies(id) ON DELETE SET NULL,
    bidder_name TEXT NOT NULL,
    bid_amount NUMERIC NOT NULL,
    quantity INTEGER,
    status TEXT DEFAULT 'valid',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.auction_bids ENABLE ROW LEVEL SECURITY;

-- Anyone can view bids on auctions (public market feed)
DROP POLICY IF EXISTS "Public can view auction bids" ON public.auction_bids;
CREATE POLICY "Public can view auction bids"
    ON public.auction_bids FOR SELECT
    USING (true);

-- Authenticated users can insert bids
DROP POLICY IF EXISTS "Authenticated users can place auction bids" ON public.auction_bids;
CREATE POLICY "Authenticated users can place auction bids"
    ON public.auction_bids FOR INSERT
    WITH CHECK (auth.role() = 'authenticated');

-- Function to place a bid safely and update auction totals
CREATE OR REPLACE FUNCTION public.place_auction_bid(
    p_auction_id UUID,
    p_bid_amount NUMERIC,
    p_bidder_name TEXT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
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