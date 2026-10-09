import { createClient } from 'npm:@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

// Scoring weights (must sum to 100)
const W = { category: 30, location: 20, moq: 20, capacity: 15, rating: 15 };

function scoreCategory(companyCategories: string[], rfqCategoryId: string | null): number {
  if (!rfqCategoryId) return 15; // neutral if no category specified
  if (!companyCategories?.length) return 0;
  if (companyCategories.includes(rfqCategoryId)) return W.category; // exact
  return 0;
}

function scoreLocation(companyCountry: string, companyState: string | null, companyCity: string | null,
  rfqCountry: string | null, rfqCity: string | null): number {
  if (!rfqCountry) return W.location; // neutral if no destination specified
  const cC = (companyCountry || '').toLowerCase();
  const rC = (rfqCountry || '').toLowerCase();
  const cSt = (companyState || '').toLowerCase();
  const rCi = (rfqCity || '').toLowerCase();
  const cCi = (companyCity || '').toLowerCase();

  if (cC === rC) {
    if (rCi && cCi === rCi) return W.location; // same city
    if (cSt) return 15; // same country, any state
    return 10; // same country
  }
  return 5; // different country
}

function scoreMoq(companyMoqPolicy: string | null, rfqQuantity: number): number {
  // Parse first number from moq_policy string (e.g. "100 Pcs", "50 MT")
  if (!companyMoqPolicy) return 10; // assume compatible if not specified
  const match = companyMoqPolicy.match(/(\d+(?:\.\d+)?)/);
  if (!match) return 10;
  const companyMoq = parseFloat(match[1]);
  if (companyMoq <= rfqQuantity) return W.moq;
  if (companyMoq <= rfqQuantity * 1.5) return 15;
  if (companyMoq <= rfqQuantity * 2) return 10;
  return 0;
}

function scoreCapacity(productionCapacity: string | null, rfqQuantity: number): number {
  if (!productionCapacity) return 8; // partial if not specified
  const match = productionCapacity.match(/(\d+(?:\.\d+)?)/);
  if (!match) return 8;
  const cap = parseFloat(match[1]);
  if (cap >= rfqQuantity * 2) return W.capacity;
  if (cap >= rfqQuantity) return 10;
  if (cap >= rfqQuantity * 0.5) return 5;
  return 0;
}

function scoreRating(ratingAvg: number): number {
  if (ratingAvg >= 4.5) return W.rating;
  if (ratingAvg >= 4.0) return 12;
  if (ratingAvg >= 3.5) return 9;
  if (ratingAvg >= 3.0) return 6;
  return 3;
}

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    );

    const body = await req.json();
    const { rfq_id } = body as { rfq_id: string };

    if (!rfq_id) {
      return new Response(JSON.stringify({ error: 'rfq_id required' }), {
        status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    // 1. Fetch the RFQ
    const { data: rfq, error: rfqErr } = await supabase
      .from('requirements')
      .select('id,buyer_id,category_id,quantity,quantity_unit,destination_country,destination_city,title,deadline,is_urgent')
      .eq('id', rfq_id)
      .maybeSingle();

    if (rfqErr || !rfq) {
      return new Response(JSON.stringify({ error: rfqErr?.message ?? 'RFQ not found' }), {
        status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    // 2. Fetch all eligible verified suppliers with active subscriptions
    const { data: companies, error: compErr } = await supabase
      .from('companies')
      .select(`
        id, company_name, city, state, country,
        moq_policy, production_capacity, rating_avg,
        response_rate, avg_response_hours, owner_id
      `)
      .eq('is_verified', true)
      .neq('owner_id', rfq.buyer_id); // exclude buyer's own company

    if (compErr) {
      return new Response(JSON.stringify({ error: compErr.message }), {
        status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    // 3. Fetch category IDs per company via products
    const { data: productCategories } = await supabase
      .from('products')
      .select('company_id, category_id')
      .not('category_id', 'is', null);

    const compCategoryMap: Record<string, string[]> = {};
    for (const p of (productCategories ?? [])) {
      if (!compCategoryMap[p.company_id]) compCategoryMap[p.company_id] = [];
      if (p.category_id && !compCategoryMap[p.company_id].includes(p.category_id)) {
        compCategoryMap[p.company_id].push(p.category_id);
      }
    }

    // 4. Check which companies have active subscriptions
    const { data: activeSubs } = await supabase
      .from('subscriptions')
      .select('company_id')
      .eq('status', 'active');
    const activeSubIds = new Set((activeSubs ?? []).map((s: any) => s.company_id));

    // 5. Score each company
    const matches: Array<{
      rfq_id: string;
      company_id: string;
      match_score: number;
      score_category: number;
      score_location: number;
      score_moq: number;
      score_capacity: number;
      score_rating: number;
      notified_at: string;
      response_status: string;
    }> = [];

    for (const c of (companies ?? [])) {
      // Must have active subscription
      if (!activeSubIds.has(c.id)) continue;

      const catScore = scoreCategory(compCategoryMap[c.id] ?? [], rfq.category_id);
      const locScore = scoreLocation(c.country, c.state, c.city, rfq.destination_country, rfq.destination_city);
      const moqScore = scoreMoq(c.moq_policy, rfq.quantity);
      const capScore = scoreCapacity(c.production_capacity, rfq.quantity);
      const ratScore = scoreRating(c.rating_avg ?? 0);

      const total = catScore + locScore + moqScore + capScore + ratScore;
      if (total < 50) continue; // below threshold

      matches.push({
        rfq_id: rfq.id,
        company_id: c.id,
        match_score: Math.min(100, total),
        score_category: catScore,
        score_location: locScore,
        score_moq: moqScore,
        score_capacity: capScore,
        score_rating: ratScore,
        notified_at: new Date().toISOString(),
        response_status: 'pending',
      });
    }

    // Sort by score desc, take top 20
    matches.sort((a, b) => b.match_score - a.match_score);
    const top20 = matches.slice(0, 20);

    if (top20.length === 0) {
      return new Response(JSON.stringify({ matched: 0, message: 'No eligible suppliers found with score >= 50' }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    // 6. Upsert match results
    const { error: upsertErr } = await supabase
      .from('rfq_matches')
      .upsert(top20, { onConflict: 'rfq_id,company_id', ignoreDuplicates: false });

    if (upsertErr) {
      return new Response(JSON.stringify({ error: upsertErr.message }), {
        status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    // 7. Create rich in-app notifications for matched supplier owners
    const ownerMap: Record<string, string> = {};
    const compNameMap: Record<string, string> = {};
    for (const c of (companies ?? [])) {
      ownerMap[c.id] = c.owner_id;
      compNameMap[c.id] = c.company_name;
    }

    // Determine urgency label for this RFQ
    function getUrgencyLabel(): 'urgent' | 'new' | 'matched' {
      if (rfq.is_urgent) return 'urgent';
      if (rfq.deadline) {
        const daysLeft = Math.ceil((new Date(rfq.deadline).getTime() - Date.now()) / 86_400_000);
        if (daysLeft <= 7) return 'urgent';
        if (daysLeft <= 30) return 'new';
      }
      return 'new'; // freshly posted requirement is always at least "new"
    }

    const urgency = getUrgencyLabel();
    const emojiMap: Record<string, string> = { urgent: '🔥', new: '⚡', matched: '🎯' };
    const labelMap: Record<string, string> = {
      urgent: 'URGENT BUYER REQUIREMENT',
      new: 'NEW BUYER REQUIREMENT',
      matched: 'MATCHED BUYER REQUIREMENT',
    };

    const qtyStr = `${rfq.quantity.toLocaleString()} ${rfq.quantity_unit}`;
    const locStr = [rfq.destination_city, rfq.destination_country].filter(Boolean).join(', ');
    const deadlineStr = rfq.deadline
      ? new Date(rfq.deadline).toLocaleDateString('en-IN', { day: 'numeric', month: 'short', year: 'numeric' })
      : null;

    const notifications = top20.map(m => {
      const uid = ownerMap[m.company_id];
      if (!uid) return null;
      const compName = compNameMap[m.company_id] || 'Your business';
      const msgParts = [
        `${compName} matches a buyer requirement.`,
        `A buyer is looking for: "${rfq.title}"`,
        `📦 Qty: ${qtyStr}`,
        locStr ? `📍 Location: ${locStr}` : null,
        deadlineStr ? `⏰ Required by: ${deadlineStr}` : null,
        'Tap "Apply Fast" to submit your quotation.',
      ].filter(Boolean).join('\n');

      return {
        user_id: uid,
        type: 'rfq_matched',
        title: `${emojiMap[urgency]} ${labelMap[urgency]}`,
        message: msgParts,
        link: `/requirements/${rfq.id}`,
        reference_id: rfq.id,
        reference_type: 'requirement',
        urgency_label: urgency,
        is_read: false,
      };
    }).filter(n => n !== null);

    if (notifications.length > 0) {
      await supabase.from('notifications').insert(notifications);
    }

    return new Response(
      JSON.stringify({ matched: top20.length, scores: top20.map(m => ({ company_id: m.company_id, score: m.match_score })) }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
    );
  } catch (err) {
    return new Response(JSON.stringify({ error: String(err) }), {
      status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }
});
