/**
 * chat-auth Edge Function
 *
 * POST /chat-auth
 * Body: { supplier_id, supplier_company_id, product_id?, requirement_id? }
 *
 * 1. Verifies caller is authenticated
 * 2. Buyers are free — no subscription check on buyer side
 * 3. Verifies supplier's active subscription
 * 4. Gets or creates the conversation (atomic, no duplicates)
 * 5. Returns { conversation_id, buyer_eligible, supplier_eligible, error? }
 *
 * SECURITY: ALL checks are done server-side. Frontend values are never trusted.
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

    // Verify JWT and get caller user
    const { data: { user }, error: userErr } = await createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_ANON_KEY')!,
      { global: { headers: { Authorization: authHeader } } }
    ).auth.getUser();

    if (userErr || !user) return json({ error: 'not_authenticated' }, 401);

    const callerId = user.id;

    // ── 2. Parse body ──────────────────────────────────────────────────────
    const body = await req.json();
    const {
      supplier_id,
      supplier_company_id,
      product_id = null,
      requirement_id = null,
    } = body as {
      supplier_id: string;
      supplier_company_id: string;
      product_id?: string | null;
      requirement_id?: string | null;
    };

    if (!supplier_id || !supplier_company_id) {
      return json({ error: 'missing_supplier_info' }, 400);
    }

    // ── 3. Prevent chatting with yourself ─────────────────────────────────
    if (callerId === supplier_id) {
      return json({ error: 'cannot_chat_with_self' }, 400);
    }

    // ── 4. Determine caller role to assign buyer_id / supplier_id ─────────
    const { data: callerProfile } = await supabaseAdmin
      .from('profiles')
      .select('id, role')
      .eq('id', callerId)
      .maybeSingle();

    if (!callerProfile) return json({ error: 'profile_not_found' }, 404);

    // The "buyer" in the conversation is always the initiating non-supplier user
    // The "supplier" is always the product owner
    const buyerId = callerId;

    // ── 5. Buyers are free — skip buyer subscription check ────────────────

    // ── 6. Check supplier subscription (server-side) ──────────────────────
    const { data: supplierEligible } = await supabaseAdmin
      .rpc('is_chat_eligible', { p_user_id: supplier_id });

    if (!supplierEligible) {
      return json({
        error: 'supplier_not_subscribed',
        buyer_eligible: true,
        supplier_eligible: false,
      });
    }

    // ── 7. Get or create conversation (atomic RPC, no duplicates) ─────────
    const { data: convId, error: convErr } = await supabaseAdmin.rpc(
      'get_or_create_chat_conversation',
      {
        p_buyer_id: buyerId,
        p_supplier_id: supplier_id,
        p_supplier_company_id: supplier_company_id,
        p_product_id: product_id ?? null,
        p_requirement_id: requirement_id ?? null,
      }
    );

    if (convErr || !convId) {
      console.error('chat-auth: get_or_create_chat_conversation error', convErr);
      return json({ error: 'conversation_creation_failed' }, 500);
    }

    // ── 8. Notify supplier of new chat request (non-blocking) ─────────────
    const { data: conv } = await supabaseAdmin
      .from('conversations')
      .select('id, last_message_at, buyer_id')
      .eq('id', convId)
      .maybeSingle();

    // Send notification to supplier only on new conversation (no last message yet)
    if (conv && !conv.last_message_at) {
      await supabaseAdmin.from('notifications').insert({
        user_id: supplier_id,
        title: 'New Chat Request',
        message: 'A buyer wants to chat with you about a product.',
        type: 'chat',
        link: '/dashboard/supplier/messages',
        reference_id: convId,
        reference_type: 'conversation',
      });
    }

    return json({
      conversation_id: convId,
      buyer_eligible: true,
      supplier_eligible: true,
    });

  } catch (err) {
    console.error('chat-auth error:', err);
    return json({ error: String(err) }, 500);
  }
});
