-- 1. Ensure authenticated users can insert notifications
DROP POLICY IF EXISTS "notifications_insert_system" ON public.notifications;
DROP POLICY IF EXISTS "notifications_insert_authenticated" ON public.notifications;

CREATE POLICY "notifications_insert_authenticated" ON public.notifications
  FOR INSERT TO authenticated
  WITH CHECK (true);

-- Ensure users can delete/update their own notifications
DROP POLICY IF EXISTS "notifications_update_own" ON public.notifications;
CREATE POLICY "notifications_update_own" ON public.notifications
  FOR UPDATE TO authenticated
  USING (user_id = auth.uid() OR is_admin())
  WITH CHECK (user_id = auth.uid() OR is_admin());

DROP POLICY IF EXISTS "notifications_delete_own" ON public.notifications;
CREATE POLICY "notifications_delete_own" ON public.notifications
  FOR DELETE TO authenticated
  USING (user_id = auth.uid() OR is_admin());

-- 2. Allow paid suppliers or buyers to insert conversations
DROP POLICY IF EXISTS "conversations_insert_parties" ON public.conversations;
CREATE POLICY "conversations_insert_parties" ON public.conversations
  FOR INSERT TO authenticated
  WITH CHECK (
    ((auth.uid() = buyer_id OR auth.uid() = supplier_id) AND is_chat_eligible(supplier_id))
    OR is_admin()
  );

-- 3. Trigger for Real-Time Notification on New Message
CREATE OR REPLACE FUNCTION public.trg_notify_new_message_fn()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
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

DROP TRIGGER IF EXISTS trg_notify_new_message ON public.messages;
CREATE TRIGGER trg_notify_new_message
  AFTER INSERT ON public.messages
  FOR EACH ROW
  EXECUTE FUNCTION public.trg_notify_new_message_fn();

-- 4. Trigger for Real-Time Notification on New Quotation
CREATE OR REPLACE FUNCTION public.trg_notify_new_quotation_fn()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
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

DROP TRIGGER IF EXISTS trg_notify_new_quotation ON public.quotations;
CREATE TRIGGER trg_notify_new_quotation
  AFTER INSERT ON public.quotations
  FOR EACH ROW
  EXECUTE FUNCTION public.trg_notify_new_quotation_fn();

-- 5. Stored function to send subscription pay notifications to unpaid manufacturers
CREATE OR REPLACE FUNCTION public.notify_unpaid_manufacturers()
RETURNS integer
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
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

-- Run now to notify all currently unpaid manufacturers
SELECT public.notify_unpaid_manufacturers();
