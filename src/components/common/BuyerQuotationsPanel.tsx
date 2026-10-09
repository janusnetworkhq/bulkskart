/**
 * BuyerQuotationsPanel
 *
 * Shown inside the "My Requirements" tab when a buyer opens a requirement.
 * Lists all auto_quotations for that requirement.
 * Buyer can accept / reject / counter-offer (price + message) / request revision / download.
 */
import React, { useEffect, useState, useCallback } from 'react';
import { supabase } from '@/db/supabase';
import AutoQuotationCard, { type AutoQuotation } from './AutoQuotationCard';
import { getOrCreateConversation, sendMessage } from '@/lib/api';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '@/contexts/AuthContext';
import { toast } from 'sonner';
import { RefreshCw, FileText, Zap } from 'lucide-react';

interface Props {
  requirementId: string;
  requirementTitle: string;
  buyerId: string;
}

export default function BuyerQuotationsPanel({ requirementId, requirementTitle, buyerId }: Props) {
  const [quotes, setQuotes] = useState<AutoQuotation[]>([]);
  const [loading, setLoading] = useState(true);
  const { user } = useAuth();
  const navigate = useNavigate();

  const fetchQuotes = useCallback(async () => {
    setLoading(true);
    const { data } = await supabase
      .from('auto_quotations')
      .select('*, companies!supplier_company_id(company_name,logo_url,verification_status)')
      .eq('requirement_id', requirementId)
      .in('status', ['sent', 'accepted', 'rejected', 'revised_requested', 'expired'])
      .order('created_at', { ascending: false });
    setQuotes(Array.isArray(data) ? (data as AutoQuotation[]) : []);
    setLoading(false);
  }, [requirementId]);

  useEffect(() => {
    fetchQuotes();
    // Realtime subscription
    let ch: ReturnType<typeof supabase.channel> | null = null;
    try {
      const chName = `auto_quotes_${requirementId}_${Date.now()}_${Math.random().toString(36).slice(2, 6)}`;
      ch = supabase
        .channel(chName)
        .on('postgres_changes', {
          event: '*', schema: 'public', table: 'auto_quotations',
          filter: `requirement_id=eq.${requirementId}`,
        }, () => fetchQuotes())
        .subscribe();
    } catch (e) {
      console.warn('Buyer quotations realtime subscription skipped:', e);
    }
    return () => { 
      if (ch) supabase.removeChannel(ch); 
    };
  }, [requirementId, fetchQuotes]);

  const handleAccept = async (id: string) => {
    const { error } = await supabase
      .from('auto_quotations')
      .update({ status: 'accepted', buyer_action: 'accepted', buyer_action_at: new Date().toISOString() })
      .eq('id', id);
    if (error) { toast.error('Failed to accept quotation'); return; }
    toast.success('Quotation accepted! The supplier will be notified.');
    // Notify supplier
    const q = quotes.find(q => q.id === id);
    if (q) {
      const { data: company } = await supabase
        .from('companies')
        .select('owner_id,company_name')
        .eq('id', q.supplier_company_id)
        .single();
      if (company) {
        await supabase.from('notifications').insert({
          user_id: company.owner_id,
          title: 'Quotation Accepted!',
          message: `Your quotation for "${requirementTitle}" has been accepted by the buyer.`,
          type: 'quote_accepted',
          link: `/dashboard/supplier/rfqs?req=${requirementId}`,
        });
      }
    }
    fetchQuotes();
  };

  const handleReject = async (id: string) => {
    const { error } = await supabase
      .from('auto_quotations')
      .update({ status: 'rejected', buyer_action: 'rejected', buyer_action_at: new Date().toISOString() })
      .eq('id', id);
    if (error) { toast.error('Failed to reject quotation'); return; }
    toast.success('Quotation rejected.');
    const q = quotes.find(q => q.id === id);
    if (q) {
      const { data: company } = await supabase
        .from('companies')
        .select('owner_id')
        .eq('id', q.supplier_company_id)
        .single();
      if (company) {
        await supabase.from('notifications').insert({
          user_id: company.owner_id,
          title: 'Quotation Rejected',
          message: `Your quotation for "${requirementTitle}" was rejected by the buyer.`,
          type: 'quote_rejected',
          link: `/dashboard/supplier/rfqs?req=${requirementId}`,
        });
      }
    }
    fetchQuotes();
  };

  const handleRevise = async (id: string, notes: string) => {
    const { error } = await supabase
      .from('auto_quotations')
      .update({
        status: 'revised_requested',
        buyer_action: 'revised_requested',
        buyer_action_at: new Date().toISOString(),
        buyer_notes: notes,
      })
      .eq('id', id);
    if (error) { toast.error('Failed to request revision'); return; }
    toast.success('Revision request sent to supplier.');
    const q = quotes.find(q => q.id === id);
    if (q) {
      const { data: company } = await supabase
        .from('companies')
        .select('owner_id')
        .eq('id', q.supplier_company_id)
        .single();
      if (company) {
        await supabase.from('notifications').insert({
          user_id: company.owner_id,
          title: 'Revision Requested',
          message: `Buyer requested a revision for "${requirementTitle}": ${notes.slice(0, 80)}`,
          type: 'quote_received',
          link: `/dashboard/supplier/rfqs?req=${requirementId}`,
        });
      }
    }
    fetchQuotes();
  };

  const handleCounterOffer = async (id: string, counterPrice: number, message: string) => {
    if (!user) { toast.error('Please log in'); return; }
    const q = quotes.find(q => q.id === id);
    if (!q) return;

    // 1. Persist counter offer on the auto_quotation row
    const { error } = await supabase
      .from('auto_quotations')
      .update({
        status: 'revised_requested',
        buyer_action: 'revised_requested',
        buyer_action_at: new Date().toISOString(),
        counter_offer_price: counterPrice,
        counter_offer_message: message || null,
        counter_offer_at: new Date().toISOString(),
      })
      .eq('id', id);
    if (error) { toast.error('Failed to send counter offer'); return; }

    // 2. Get supplier owner_id so we can open a conversation
    const { data: company } = await supabase
      .from('companies')
      .select('owner_id, company_name')
      .eq('id', q.supplier_company_id)
      .single();

    if (company) {
      // 3. Open/fetch conversation and send a structured chat message
      try {
        const conv = await getOrCreateConversation(buyerId, company.owner_id, q.supplier_company_id, requirementId);
        if (conv?.id) {
          const currency = q.currency ?? 'INR';
          const fmtPrice = (n: number) => {
            try { return new Intl.NumberFormat('en-IN', { style: 'currency', currency, maximumFractionDigits: 0 }).format(n); }
            catch { return `₹${n.toLocaleString('en-IN')}`; }
          };
          const chatMsg = [
            `💬 **Counter Offer for "${requirementTitle}"**`,
            `📦 Product: ${q.product_name}`,
            `❌ Supplier Quoted: ${fmtPrice(q.total_amount)}`,
            `✅ My Counter Offer: **${fmtPrice(counterPrice)}**`,
            message ? `📝 Note: ${message}` : '',
          ].filter(Boolean).join('\n');
          await sendMessage(conv.id, chatMsg);
        }
      } catch { /* non-critical — counter offer is already saved */ }

      // 4. Notify supplier
      await supabase.from('notifications').insert({
        user_id: company.owner_id,
        title: 'Counter Offer Received',
        message: `Buyer submitted a counter offer for "${requirementTitle}". Please review and respond.`,
        type: 'quote_received',
        link: `/dashboard/supplier/rfqs?req=${requirementId}`,
      });
    }

    toast.success('Counter offer sent! The supplier will respond shortly.');
    fetchQuotes();
  };

  if (loading) {
    return (
      <div className="flex items-center gap-2 py-4 text-muted-foreground text-sm">
        <RefreshCw className="w-4 h-4 animate-spin" /> Loading quotations…
      </div>
    );
  }

  if (quotes.length === 0) {
    return (
      <div className="flex items-center gap-3 py-5 px-4 bg-muted/20 border border-dashed border-border rounded-xl text-sm text-muted-foreground">
        <Zap className="w-5 h-5 text-primary/40 shrink-0" />
        <div>
          <p className="font-medium text-foreground">Waiting for quotations…</p>
          <p className="text-xs mt-0.5">Suppliers with auto-quote enabled will respond automatically. Others may respond manually.</p>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-3">
      <div className="flex items-center gap-2 text-sm font-semibold text-foreground">
        <FileText className="w-4 h-4 text-primary" />
        {quotes.length} Quotation{quotes.length > 1 ? 's' : ''} Received
      </div>
      {quotes.map(q => (
        <AutoQuotationCard
          key={q.id}
          quote={q}
          requirementTitle={requirementTitle}
          requirementId={requirementId}
          onAccept={handleAccept}
          onReject={handleReject}
          onRevise={handleRevise}
          onCounterOffer={handleCounterOffer}
        />
      ))}
    </div>
  );
}
