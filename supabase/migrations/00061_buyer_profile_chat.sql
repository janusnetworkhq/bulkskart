-- Let a subscribed supplier open one profile-level chat with a public buyer.
-- The conversation shows up in both Messages inboxes.

CREATE OR REPLACE FUNCTION public.start_buyer_profile_chat(p_buyer_id uuid)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_caller uuid := auth.uid();
  v_company_id uuid;
  v_role text;
  v_status text;
  v_eligible boolean;
  v_conv_id uuid;
BEGIN
  IF v_caller IS NULL THEN
    RAISE EXCEPTION 'not_authenticated' USING ERRCODE = '28000';
  END IF;

  IF v_caller = p_buyer_id THEN
    RAISE EXCEPTION 'cannot_chat_with_self' USING ERRCODE = '42501';
  END IF;

  SELECT role::text, status::text INTO v_role, v_status
  FROM public.profiles
  WHERE id = p_buyer_id;

  IF v_role IS DISTINCT FROM 'buyer' OR v_status IS DISTINCT FROM 'active' THEN
    RAISE EXCEPTION 'buyer_not_found' USING ERRCODE = 'P0002';
  END IF;

  SELECT id INTO v_company_id
  FROM public.companies
  WHERE owner_id = v_caller
  ORDER BY created_at ASC
  LIMIT 1;

  IF v_company_id IS NULL THEN
    RAISE EXCEPTION 'supplier_company_required' USING ERRCODE = '42501';
  END IF;

  v_eligible := public.is_chat_eligible(v_caller);
  IF NOT COALESCE(v_eligible, false) THEN
    RAISE EXCEPTION 'supplier_not_subscribed' USING ERRCODE = '42501';
  END IF;

  SELECT id INTO v_conv_id
  FROM public.conversations
  WHERE buyer_id = p_buyer_id
    AND supplier_id = v_caller
    AND product_id IS NULL
    AND requirement_id IS NULL
  ORDER BY created_at ASC
  LIMIT 1;

  IF v_conv_id IS NULL THEN
    INSERT INTO public.conversations (buyer_id, supplier_id, supplier_company_id)
    VALUES (p_buyer_id, v_caller, v_company_id)
    RETURNING id INTO v_conv_id;

    BEGIN
      INSERT INTO public.notifications (
        user_id, title, message, type, link, reference_id, reference_type
      ) VALUES (
        p_buyer_id,
        'New chat from a supplier',
        'A supplier opened a chat from your public buyer profile.',
        'chat',
        '/dashboard/buyer/messages',
        v_conv_id,
        'conversation'
      );
    EXCEPTION WHEN OTHERS THEN
      NULL;
    END;
  END IF;

  RETURN v_conv_id;
END;
$$;

REVOKE ALL ON FUNCTION public.start_buyer_profile_chat(uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.start_buyer_profile_chat(uuid) TO authenticated, service_role;

NOTIFY pgrst, 'reload schema';
