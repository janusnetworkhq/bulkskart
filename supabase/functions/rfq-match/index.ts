import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders });

  try {
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    );

    const { requirement_id } = await req.json();
    if (!requirement_id) {
      return new Response(JSON.stringify({ error: 'requirement_id required' }), {
        status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    // Fetch requirement
    const { data: req_data, error: reqErr } = await supabase
      .from('requirements')
      .select('*, categories(name, slug)')
      .eq('id', requirement_id)
      .maybeSingle();

    if (reqErr || !req_data) {
      return new Response(JSON.stringify({ error: 'Requirement not found' }), {
        status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    // Fetch active verified companies with at least one product
    const { data: companies } = await supabase
      .from('companies')
      .select('id, owner_id, company_name, business_type, city, country, production_capacity, moq_policy, key_products, is_blocked, verification_status')
      .eq('is_blocked', false)
      .order('is_verified', { ascending: false })
      .limit(200);

    if (!companies?.length) {
      return new Response(JSON.stringify({ matched: 0 }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    // Fetch already-notified companies for this RFQ
    const { data: alreadyNotified } = await supabase
      .from('rfq_match_log')
      .select('company_id')
      .eq('requirement_id', requirement_id);

    const notifiedSet = new Set((alreadyNotified ?? []).map((r: { company_id: string }) => r.company_id));

    const title = (req_data.title || '').toLowerCase();
    const desc = (req_data.description || '').toLowerCase();
    const catName = (req_data.categories?.name || '').toLowerCase();
    const destCountry = (req_data.destination_country || '').toLowerCase();
    const reqMoq = req_data.quantity || 0;

    const scored = companies
      .filter((c: { id: string }) => !notifiedSet.has(c.id))
      .map((c: {
        id: string; owner_id: string; company_name: string; business_type: string | null;
        city: string | null; country: string; production_capacity: string | null;
        moq_policy: string | null; key_products: string[] | null;
      }) => {
        let score = 0;
        const keyProds = (c.key_products || []).join(' ').toLowerCase();

        // Category / keyword match
        if (keyProds.includes(catName) || keyProds.includes(title.slice(0, 15))) score += 40;
        if (keyProds.includes(title) || keyProds.includes(desc.slice(0, 20))) score += 20;

        // Location match
        if (destCountry && (c.country || '').toLowerCase().includes(destCountry)) score += 20;
        if (destCountry && (c.city || '').toLowerCase().includes(destCountry)) score += 10;

        // MOQ compatibility (rough)
        const moqPolicy = (c.moq_policy || '').toLowerCase();
        if (moqPolicy.includes(String(reqMoq)) || moqPolicy === '') score += 10;

        return { ...c, score };
      })
      .filter((c: { score: number }) => c.score > 0)
      .sort((a: { score: number }, b: { score: number }) => b.score - a.score)
      .slice(0, 20);

    if (!scored.length) {
      return new Response(JSON.stringify({ matched: 0 }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    // Insert match log rows (prevents re-notification)
    await supabase.from('rfq_match_log').insert(
      scored.map((c: { id: string; score: number }) => ({
        requirement_id,
        company_id: c.id,
        relevance_score: c.score,
      }))
    );

    // Update matched_count on requirement
    await supabase
      .from('requirements')
      .update({ matched_count: (req_data.matched_count || 0) + scored.length })
      .eq('id', requirement_id);

    // Insert in-app notifications for each matched manufacturer's owner
    const notifications = scored.map((c: { owner_id: string; company_name: string }) => ({
      user_id: c.owner_id,
      title: '🔔 New Matched RFQ',
      message: `A buyer posted a requirement matching your products: "${req_data.title}"`,
      type: 'rfq_match',
      link: `/dashboard/supplier/rfqs`,
      reference_id: requirement_id,
      reference_type: 'requirement',
    }));

    await supabase.from('notifications').insert(notifications);

    return new Response(JSON.stringify({ matched: scored.length }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  } catch (err) {
    return new Response(JSON.stringify({ error: String(err) }), {
      status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }
});
