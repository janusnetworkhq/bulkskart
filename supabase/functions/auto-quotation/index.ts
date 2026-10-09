/**
 * auto-quotation Edge Function
 *
 * Triggered after a buyer posts an RFQ.
 * 1. Finds suppliers whose auto_quote settings are enabled.
 * 2. For each, finds a matching product in their catalog.
 * 3. Calculates: subtotal + shipping + tax + other = total.
 * 4. Inserts an auto_quotations row.
 * 5. If auto_send_enabled=true → status='sent', inserts a quotations row, sends buyer notification.
 *    If require_approval=true  → status='pending_approval', sends supplier notification.
 *
 * POST body: { requirement_id }
 */
import { createClient } from 'jsr:@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

function ok(data: unknown) {
  return new Response(JSON.stringify({ code: 'SUCCESS', data }), {
    status: 200, headers: { 'Content-Type': 'application/json', ...corsHeaders },
  });
}
function fail(msg: string, code = 400) {
  return new Response(JSON.stringify({ code: 'FAIL', message: msg }), {
    status: code, headers: { 'Content-Type': 'application/json', ...corsHeaders },
  });
}

const supabase = createClient(
  Deno.env.get('SUPABASE_URL')!,
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
);

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders });
  if (req.method !== 'POST') return new Response('Method not allowed', { status: 405 });

  try {
    const { requirement_id } = await req.json();
    if (!requirement_id) return fail('Missing requirement_id');

    // 1. Fetch requirement details
    const { data: req_row, error: reqErr } = await supabase
      .from('requirements')
      .select('*, categories!category_id(id,name,slug)')
      .eq('id', requirement_id)
      .single();
    if (reqErr || !req_row) return fail('Requirement not found', 404);

    const reqQty = Number(req_row.quantity) || 1;
    const reqCategoryId = req_row.category_id;

    // 2. Find suppliers with auto-quote settings enabled
    const { data: settings } = await supabase
      .from('supplier_auto_quote_settings')
      .select('*, companies!company_id(id,company_name,owner_id,verification_status)')
      .or('auto_send_enabled.eq.true,require_approval.eq.true');

    if (!settings || settings.length === 0) return ok({ matched: 0, message: 'No auto-quote suppliers found' });

    const results: { company_id: string; status: string }[] = [];

    for (const setting of settings) {
      const company = setting.companies as { id: string; company_name: string; owner_id: string; verification_status: string };
      if (!company) continue;

      // Skip already-generated quotes for this requirement+supplier
      const { count: existingCount } = await supabase
        .from('auto_quotations')
        .select('id', { count: 'exact', head: true })
        .eq('requirement_id', requirement_id)
        .eq('supplier_company_id', company.id);
      if ((existingCount ?? 0) > 0) continue;

      // 3. Find a matching product in supplier's catalog
      let productQuery = supabase
        .from('products')
        .select('*')
        .eq('supplier_company_id', company.id)
        .eq('status', 'active')
        .limit(1);

      if (reqCategoryId) {
        productQuery = productQuery.eq('category_id', reqCategoryId);
      }

      const { data: products } = await productQuery;
      // If no category match, try any active product as fallback
      let product = products?.[0] ?? null;
      if (!product && reqCategoryId) {
        const { data: anyProduct } = await supabase
          .from('products')
          .select('*')
          .eq('supplier_company_id', company.id)
          .eq('status', 'active')
          .limit(1);
        product = anyProduct?.[0] ?? null;
      }

      // If still no product, use synthetic pricing from settings
      const unitPrice = product?.price_inr ?? product?.price ?? 100;
      const moq = product?.moq ?? 1;
      const moqUnit = product?.moq_unit ?? req_row.quantity_unit ?? 'Pcs';
      const productName = product?.name ?? req_row.title;
      const productSpecs = product?.specifications ?? req_row.specifications ?? null;

      // 4. Calculate totals
      const subtotal = parseFloat((unitPrice * reqQty).toFixed(2));
      const shippingCost = parseFloat(((subtotal * (Number(setting.shipping_rate_pct) / 100))).toFixed(2));
      const taxAmount = parseFloat(((subtotal * (Number(setting.tax_rate_pct) / 100))).toFixed(2));
      const otherCharges = parseFloat((Number(setting.other_charges) || 0).toFixed(2));
      const totalAmount = parseFloat((subtotal + shippingCost + taxAmount + otherCharges).toFixed(2));

      // Estimated delivery date
      const deliveryDays = setting.default_delivery_days ?? 14;
      const estimatedDate = new Date();
      estimatedDate.setDate(estimatedDate.getDate() + deliveryDays);
      const validUntilDate = new Date();
      validUntilDate.setDate(validUntilDate.getDate() + (setting.default_validity_days ?? 30));

      // 5. Determine status
      const autoSend = setting.auto_send_enabled === true;
      const requireApproval = setting.require_approval === true;
      let status: string;
      if (autoSend && !requireApproval) {
        status = 'sent';
      } else {
        status = 'pending_approval';
      }

      // 6. Insert auto_quotation row
      const { data: aq, error: aqErr } = await supabase
        .from('auto_quotations')
        .insert({
          requirement_id,
          supplier_company_id: company.id,
          buyer_id: req_row.buyer_id,
          status,
          unit_price: unitPrice,
          quantity: reqQty,
          quantity_unit: moqUnit,
          currency: 'INR',
          subtotal,
          shipping_cost: shippingCost,
          tax_amount: taxAmount,
          other_charges: otherCharges,
          total_amount: totalAmount,
          product_name: productName,
          product_specs: productSpecs,
          moq,
          moq_unit: moqUnit,
          delivery_days: deliveryDays,
          estimated_delivery_date: estimatedDate.toISOString().split('T')[0],
          validity_days: setting.default_validity_days ?? 30,
          valid_until: validUntilDate.toISOString().split('T')[0],
          payment_terms: setting.default_payment_terms ?? 'T/T 30% advance',
          terms_and_conditions: setting.terms_and_conditions ?? null,
          is_auto_generated: true,
          auto_sent_at: status === 'sent' ? new Date().toISOString() : null,
        })
        .select()
        .single();

      if (aqErr || !aq) {
        console.error('Failed to insert auto_quotation:', aqErr?.message);
        continue;
      }

      // 7. If auto-sent: create quotations row + notify buyer
      if (status === 'sent') {
        const { data: quotation } = await supabase
          .from('quotations')
          .insert({
            requirement_id,
            supplier_company_id: company.id,
            supplier_id: company.owner_id,
            buyer_id: req_row.buyer_id,
            unit_price: unitPrice,
            currency: 'INR',
            moq,
            moq_unit: moqUnit,
            delivery_days: deliveryDays,
            payment_terms: setting.default_payment_terms ?? 'T/T 30% advance',
            validity_days: setting.default_validity_days ?? 30,
            total_price: totalAmount,
            notes: `Auto-generated quotation from ${company.company_name}`,
            status: 'pending',
            is_draft: false,
          })
          .select('id')
          .single();

        if (quotation?.id) {
          await supabase
            .from('auto_quotations')
            .update({ quotation_id: quotation.id })
            .eq('id', aq.id);
        }

        // Notify buyer
        await supabase.from('notifications').insert({
          user_id: req_row.buyer_id,
          title: `New Auto-Quote from ${company.company_name}`,
          message: `${company.company_name} automatically sent a quotation for "${req_row.title}" — Total: ₹${totalAmount.toLocaleString('en-IN')}`,
          type: 'quote_received',
          link: `/requirements?tab=mine&req=${requirement_id}`,
        });
      }

      // 8. Pending approval: notify supplier
      if (status === 'pending_approval') {
        await supabase.from('notifications').insert({
          user_id: company.owner_id,
          title: `Auto-Quote Ready for Approval`,
          message: `A quotation for "${req_row.title}" (Total: ₹${totalAmount.toLocaleString('en-IN')}) is waiting for your approval.`,
          type: 'rfq_match',
          link: `/dashboard/supplier/rfqs?req=${requirement_id}`,
        });
      }

      results.push({ company_id: company.id, status });
    }

    return ok({ matched: results.length, results });
  } catch (err) {
    console.error('auto-quotation error:', err);
    return fail(err instanceof Error ? err.message : 'Internal error', 500);
  }
});
