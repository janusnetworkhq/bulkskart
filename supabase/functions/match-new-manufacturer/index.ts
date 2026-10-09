import { createClient } from 'npm:@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

// Scoring weights (same logic as run-rfq-matching for consistency)
const W = { category: 30, keyword: 25, location: 20, moq: 15, capacity: 10 };
const MIN_SCORE = 40; // lower threshold for new manufacturers (less data available)
const MAX_NOTIFICATIONS = 10; // cap per new signup

function tokenize(text: string): Set<string> {
  return new Set(
    text.toLowerCase()
      .replace(/[^\w\s]/g, ' ')
      .split(/\s+/)
      .filter(t => t.length > 2)
  );
}

function scoreKeyword(companyTokens: Set<string>, rfqTokens: Set<string>): number {
  if (!companyTokens.size || !rfqTokens.size) return 0;
  let matches = 0;
  for (const t of rfqTokens) {
    if (companyTokens.has(t)) matches++;
  }
  const ratio = matches / Math.max(rfqTokens.size, 1);
  if (ratio >= 0.4) return W.keyword;
  if (ratio >= 0.2) return Math.round(W.keyword * 0.6);
  if (ratio >= 0.1) return Math.round(W.keyword * 0.3);
  return 0;
}

function scoreCategory(companyCategories: string[], rfqCategoryId: string | null): number {
  if (!rfqCategoryId) return Math.round(W.category * 0.5);
  if (!companyCategories?.length) return 0;
  return companyCategories.includes(rfqCategoryId) ? W.category : 0;
}

function scoreLocation(
  companyCountry: string, companyState: string | null, companyCity: string | null,
  rfqCountry: string | null, rfqCity: string | null,
): number {
  if (!rfqCountry) return Math.round(W.location * 0.7);
  const cc = (companyCountry || '').toLowerCase();
  const rc = (rfqCountry || '').toLowerCase();
  if (cc !== rc) return 0;
  const rci = (rfqCity || '').toLowerCase();
  const cci = (companyCity || '').toLowerCase();
  if (rci && cci === rci) return W.location;
  return Math.round(W.location * 0.6);
}

function scoreMoq(moqPolicy: string | null, rfqQty: number): number {
  if (!moqPolicy) return Math.round(W.moq * 0.5);
  const m = moqPolicy.match(/(\d+(?:\.\d+)?)/);
  if (!m) return Math.round(W.moq * 0.5);
  const compMoq = parseFloat(m[1]);
  if (compMoq <= rfqQty) return W.moq;
  if (compMoq <= rfqQty * 2) return Math.round(W.moq * 0.5);
  return 0;
}

function scoreCapacity(productionCap: string | null, rfqQty: number): number {
  if (!productionCap) return Math.round(W.capacity * 0.5);
  const m = productionCap.match(/(\d+(?:\.\d+)?)/);
  if (!m) return Math.round(W.capacity * 0.5);
  const cap = parseFloat(m[1]);
  if (cap >= rfqQty) return W.capacity;
  if (cap >= rfqQty * 0.5) return Math.round(W.capacity * 0.5);
  return 0;
}

function getUrgencyLabel(isUrgent: boolean, deadline: string | null, expiresAt: string | null): 'urgent' | 'new' | 'matched' {
  if (isUrgent) return 'urgent';
  if (deadline) {
    const daysLeft = Math.ceil((new Date(deadline).getTime() - Date.now()) / 86_400_000);
    if (daysLeft <= 7) return 'urgent';
    if (daysLeft <= 30) return 'new';
  }
  if (expiresAt) {
    const daysLeft = Math.ceil((new Date(expiresAt).getTime() - Date.now()) / 86_400_000);
    if (daysLeft <= 7) return 'urgent';
  }
  return 'matched';
}

function urgencyEmoji(label: 'urgent' | 'new' | 'matched'): string {
  if (label === 'urgent') return '🔥';
  if (label === 'new') return '⚡';
  return '🎯';
}

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders });

  try {
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    );

    const { company_id } = await req.json() as { company_id: string };
    if (!company_id) {
      return new Response(JSON.stringify({ error: 'company_id required' }), {
        status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    // ── 1. Fetch the new company ─────────────────────────────────────────
    const { data: company, error: compErr } = await supabase
      .from('companies')
      .select('id, owner_id, company_name, tagline, business_type, city, state, country, moq_policy, production_capacity, key_products, description')
      .eq('id', company_id)
      .maybeSingle();

    if (compErr || !company) {
      return new Response(JSON.stringify({ error: 'Company not found' }), {
        status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    // ── 2. Fetch this company's product category IDs ─────────────────────
    const { data: compProds } = await supabase
      .from('products')
      .select('category_id, name, tags')
      .eq('company_id', company_id)
      .eq('is_active', true);

    const compCategoryIds = [...new Set((compProds ?? []).filter((p: { category_id: string | null }) => p.category_id).map((p: { category_id: string }) => p.category_id))];
    const compProductNames = (compProds ?? []).map((p: { name: string }) => p.name).join(' ');
    const compTags = (compProds ?? []).flatMap((p: { tags: string[] | null }) => p.tags ?? []).join(' ');

    // Build company token set from all available text signals
    const compText = [
      company.company_name,
      company.tagline ?? '',
      company.business_type ?? '',
      company.description ?? '',
      (company.key_products ?? []).join(' '),
      compProductNames,
      compTags,
    ].join(' ');
    const compTokens = tokenize(compText);

    // ── 3. Fetch active, non-expired requirements ────────────────────────
    const { data: requirements } = await supabase
      .from('requirements')
      .select('id, buyer_id, title, description, category_id, quantity, quantity_unit, destination_country, destination_city, deadline, expires_at, is_urgent, req_number, categories(name)')
      .eq('status', 'active')
      .or('expires_at.is.null,expires_at.gt.' + new Date().toISOString())
      .order('created_at', { ascending: false })
      .limit(500);

    if (!requirements?.length) {
      return new Response(JSON.stringify({ matched: 0 }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    // ── 4. Fetch already-notified requirement IDs for this company ────────
    const { data: alreadyMatched } = await supabase
      .from('rfq_matches')
      .select('rfq_id')
      .eq('company_id', company_id);
    const matchedSet = new Set((alreadyMatched ?? []).map((r: { rfq_id: string }) => r.rfq_id));

    // ── 5. Score each requirement against this company ────────────────────
    const scored: Array<{
      rfq_id: string; score: number; scoreBreakdown: Record<string, number>;
      req: typeof requirements[0]; urgency: 'urgent' | 'new' | 'matched';
    }> = [];

    for (const req of requirements) {
      // Skip if already notified
      if (matchedSet.has(req.id)) continue;
      // Skip buyer's own requirements (shouldn't match their own company)
      if (req.buyer_id === company.owner_id) continue;

      const rfqText = [req.title, req.description ?? '', (req as { categories?: { name: string } }).categories?.name ?? ''].join(' ');
      const rfqTokens = tokenize(rfqText);

      const catScore = scoreCategory(compCategoryIds, req.category_id);
      const kwScore = scoreKeyword(compTokens, rfqTokens);
      const locScore = scoreLocation(company.country, company.state, company.city, req.destination_country, req.destination_city);
      const moqScore = scoreMoq(company.moq_policy, req.quantity);
      const capScore = scoreCapacity(company.production_capacity, req.quantity);

      const total = catScore + kwScore + locScore + moqScore + capScore;
      if (total < MIN_SCORE) continue;

      const urgency = getUrgencyLabel(req.is_urgent, req.deadline, req.expires_at);
      scored.push({ rfq_id: req.id, score: Math.min(100, total), scoreBreakdown: { catScore, kwScore, locScore, moqScore, capScore }, req, urgency });
    }

    // Sort by score desc, take top N
    scored.sort((a, b) => b.score - a.score);
    const top = scored.slice(0, MAX_NOTIFICATIONS);

    if (!top.length) {
      return new Response(JSON.stringify({ matched: 0 }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    // ── 6. Insert rfq_matches rows (deduplication via UNIQUE constraint) ──
    const matchRows = top.map(m => ({
      rfq_id: m.rfq_id,
      company_id: company_id,
      match_score: m.score,
      score_category: m.scoreBreakdown.catScore,
      score_location: m.scoreBreakdown.locScore,
      score_moq: m.scoreBreakdown.moqScore,
      score_capacity: m.scoreBreakdown.capScore,
      score_rating: 0,
      notified_at: new Date().toISOString(),
      response_status: 'pending',
    }));

    await supabase.from('rfq_matches').upsert(matchRows, { onConflict: 'rfq_id,company_id', ignoreDuplicates: true });

    // ── 7. Insert in-app notifications ────────────────────────────────────
    const compDisplayName = company.company_name || 'Your business';
    const notifications = top.map(m => {
      const req = m.req;
      const emoji = urgencyEmoji(m.urgency);
      const labelMap = { urgent: 'URGENT BUYER REQUIREMENT', new: 'NEW BUYER REQUIREMENT', matched: 'MATCHED BUYER REQUIREMENT' };
      const label = labelMap[m.urgency];
      const qtyStr = `${req.quantity.toLocaleString()} ${req.quantity_unit}`;
      const locStr = [req.destination_city, req.destination_country].filter(Boolean).join(', ');
      const deadlineStr = req.deadline ? new Date(req.deadline).toLocaleDateString('en-IN', { day: 'numeric', month: 'short', year: 'numeric' }) : null;

      const title = `${emoji} ${label}`;
      const messageParts = [
        `${compDisplayName} matches a buyer requirement.`,
        `A buyer is looking for: "${req.title}"`,
        `📦 Qty: ${qtyStr}`,
        locStr ? `📍 Location: ${locStr}` : null,
        deadlineStr ? `⏰ Required by: ${deadlineStr}` : null,
        'Tap "Apply Fast" to submit your quotation.',
      ].filter(Boolean).join('\n');

      return {
        user_id: company.owner_id,
        title,
        message: messageParts,
        type: 'rfq_matched',
        link: `/requirements/${req.id}`,
        reference_id: req.id,
        reference_type: 'requirement',
        urgency_label: m.urgency,
        is_read: false,
      };
    });

    await supabase.from('notifications').insert(notifications);

    return new Response(
      JSON.stringify({ matched: top.length, company: compDisplayName }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
    );
  } catch (err) {
    return new Response(JSON.stringify({ error: String(err) }), {
      status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }
});
