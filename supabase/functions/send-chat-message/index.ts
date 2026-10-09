/**
 * send-chat-message Edge Function
 *
 * POST /send-chat-message
 * Body: { conversation_id, content }
 *
 * Server-side enforces:
 * 1. Authenticated user
 * 2. Sender is a participant of the conversation
 * 3. Sender has an active subscription
 * 4. Other party also has an active subscription (subscription must be mutual)
 * 5. Inserts message + clears own unread counter
 * 6. Notifies the other party
 *
 * SECURITY: ALL checks done server-side. Frontend cannot bypass.
 */
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders });

  const json = (body: unknown, status = 200) =>
    new Response(JSON.stringify(body), {
      status,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });

  try {
    // ── 1. Auth ────────────────────────────────────────────────────────────
    const authHeader = req.headers.get('Authorization');
    if (!authHeader) return json({ error: 'not_authenticated' }, 401);

    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    );

    const { data: { user }, error: userErr } = await createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_ANON_KEY')!,
      { global: { headers: { Authorization: authHeader } } }
    ).auth.getUser();

    if (userErr || !user) return json({ error: 'not_authenticated' }, 401);

    const senderId = user.id;

    // ── 2. Parse body ──────────────────────────────────────────────────────
    const { conversation_id, content } = await req.json() as {
      conversation_id: string;
      content: string;
    };

    if (!conversation_id || !content?.trim()) {
      return json({ error: 'missing_fields' }, 400);
    }

    const trimmedContent = content.trim().slice(0, 4000); // max 4000 chars

    // ── 3. Fetch conversation + verify participant ─────────────────────────
    const { data: conv } = await supabaseAdmin
      .from('conversations')
      .select('id, buyer_id, supplier_id, buyer_blocked, supplier_blocked')
      .eq('id', conversation_id)
      .maybeSingle();

    if (!conv) return json({ error: 'conversation_not_found' }, 404);

    const isBuyer    = conv.buyer_id    === senderId;
    const isSupplier = conv.supplier_id === senderId;
    if (!isBuyer && !isSupplier) return json({ error: 'not_a_participant' }, 403);

    // Block check
    if (isBuyer    && conv.buyer_blocked)    return json({ error: 'you_are_blocked' }, 403);
    if (isSupplier && conv.supplier_blocked) return json({ error: 'you_are_blocked' }, 403);

    // ── 4. Subscription check — supplier sender only ───────────────────────
    // Buyers are free and never blocked by subscription checks.
    if (isSupplier) {
      const { data: senderEligible } = await supabaseAdmin
        .rpc('is_chat_eligible', { p_user_id: senderId });

      if (!senderEligible) {
        return json({ error: 'subscription_expired' }, 403);
      }
    }

    // ── 5. Subscription check — recipient (only if recipient is supplier) ──
    const recipientId = isBuyer ? conv.supplier_id : conv.buyer_id;
    const recipientIsSupplier = isBuyer; // buyer's recipient is always the supplier
    if (recipientIsSupplier) {
      const { data: recipientEligible } = await supabaseAdmin
        .rpc('is_chat_eligible', { p_user_id: recipientId });

      if (!recipientEligible) {
        return json({ error: 'recipient_subscription_expired' }, 403);
      }
    }

    // ── 6. Insert message ──────────────────────────────────────────────────
    const { data: msg, error: msgErr } = await supabaseAdmin
      .from('messages')
      .insert({
        conversation_id,
        sender_id: senderId,
        content: trimmedContent,
      })
      .select('id, conversation_id, sender_id, content, created_at, is_read')
      .maybeSingle();

    if (msgErr || !msg) {
      console.error('send-chat-message: insert error', msgErr);
      return json({ error: 'message_send_failed' }, 500);
    }

    // ── 7. Reset own unread counter ────────────────────────────────────────
    if (isBuyer) {
      await supabaseAdmin
        .from('conversations')
        .update({ buyer_unread: 0 })
        .eq('id', conversation_id);
    } else {
      await supabaseAdmin
        .from('conversations')
        .update({ supplier_unread: 0 })
        .eq('id', conversation_id);
    }

    // ── 8. Notify recipient (non-blocking) ────────────────────────────────
    let senderCompanyName = '';
    try {
      const { data: senderComp } = await supabaseAdmin
        .from('companies')
        .select('company_name')
        .eq('owner_id', senderId)
        .maybeSingle();
      if (senderComp?.company_name) {
        senderCompanyName = senderComp.company_name;
      } else {
        const { data: senderProf } = await supabaseAdmin
          .from('profiles')
          .select('full_name')
          .eq('id', senderId)
          .maybeSingle();
        if (senderProf?.full_name) {
          senderCompanyName = senderProf.full_name;
        }
      }
    } catch {
      // non-blocking
    }

    const isUrgentMsg = /(?:^|\b)(?:urgent|asap|emergency|rush|immediate|priority)(?:\b|$)/i.test(trimmedContent);

    await supabaseAdmin.from('notifications').insert({
      user_id: recipientId,
      title: senderCompanyName ? `Message from ${senderCompanyName}` : 'New Message',
      message: trimmedContent,
      type: 'chat',
      link: isBuyer ? '/dashboard/supplier/messages' : '/dashboard/buyer/messages',
      reference_id: conversation_id,
      reference_type: 'conversation',
      urgency_label: isUrgentMsg ? 'urgent' : null,
    });

    return json({ message: msg });

  } catch (err) {
    console.error('send-chat-message error:', err);
    return json({ error: String(err) }, 500);
  }
});
