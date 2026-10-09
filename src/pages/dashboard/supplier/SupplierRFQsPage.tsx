import React, { useEffect, useState } from 'react';
import DashboardLayout from '@/components/layouts/DashboardLayout';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Textarea } from '@/components/ui/textarea';
import { useAuth } from '@/contexts/AuthContext';
import { getRequirements, createQuotation, getMyRfqMatchScores, updateRfqMatchStatus } from '@/lib/api';
import {
  getPendingApprovalQuotations, approveAutoQuotation, dismissAutoQuotation,
  type AutoQuotationRow,
} from '@/lib/autoQuotationApi';
import type { Requirement } from '@/types/types';
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from '@/components/ui/dialog';
import { toast } from 'sonner';
import { Shield, MapPin, Calendar, Package, Lock, Send, Zap, CheckCircle, XCircle, RefreshCw, TrendingUp, Clock } from 'lucide-react';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { useSearchParams, Link } from 'react-router-dom';
import { supabase } from '@/db/supabase';
import PageMeta from '@/components/common/PageMeta';
import ProtectedContact from '@/components/common/ProtectedContact';

type QuoteForm = { unitPrice: string; currency: string; moq: string; moqUnit: string; deliveryDays: string; paymentTerms: string; validityDays: string; notes: string; };
const emptyQuote: QuoteForm = { unitPrice: '', currency: 'INR', moq: '', moqUnit: 'Pcs', deliveryDays: '30', paymentTerms: 'T/T 30% advance', validityDays: '30', notes: '' };

export default function SupplierRFQsPage() {
  const { user, company } = useAuth();
  const [searchParams] = useSearchParams();
  const [requirements, setRequirements] = useState<Requirement[]>([]);
  const [loading, setLoading] = useState(true);
  const [subscription, setSubscription] = useState<any>(null);
  const [selectedReq, setSelectedReq] = useState<Requirement | null>(null);
  const [quoteForm, setQuoteForm] = useState<QuoteForm>(emptyQuote);
  const [sending, setSending] = useState(false);
  const [sentIds, setSentIds] = useState<Set<string>>(new Set());
  const [pendingAQs, setPendingAQs] = useState<AutoQuotationRow[]>([]);
  const [approvingId, setApprovingId] = useState<string | null>(null);
  const [dismissingId, setDismissingId] = useState<string | null>(null);
  const [matchScores, setMatchScores] = useState<Record<string, number>>({});

  useEffect(() => {
    if (!company) return;
    Promise.all([
      getRequirements({ status: 'active' }),
      supabase.from('subscriptions').select('*').eq('company_id', company.id).eq('status', 'active').maybeSingle(),
      supabase.from('quotations').select('requirement_id').eq('supplier_company_id', company.id),
      getPendingApprovalQuotations(company.id),
      getMyRfqMatchScores(company.id),
    ]).then(([reqs, subRes, quoteRes, pendingAQList, scores]) => {
      setRequirements(reqs);
      setSubscription(subRes.data);
      setSentIds(new Set((quoteRes.data ?? []).map((q: any) => q.requirement_id)));
      setPendingAQs(pendingAQList);
      setMatchScores(scores);
      setLoading(false);
      const reqId = searchParams.get('req');
      if (reqId) { const r = reqs.find(r => r.id === reqId); if (r) setSelectedReq(r); }
    });
  }, [company]);

  const canViewFull = !!subscription;

  const handleApproveAQ = async (aq: AutoQuotationRow) => {
    if (!user) return;
    setApprovingId(aq.id);
    const { error } = await approveAutoQuotation(aq, user.id);
    setApprovingId(null);
    if (error) { toast.error('Failed to approve: ' + error); return; }
    toast.success('Quotation approved & sent to buyer!');
    setPendingAQs(prev => prev.filter(q => q.id !== aq.id));
    setSentIds(prev => new Set([...prev, aq.requirement_id]));
  };

  const handleDismissAQ = async (id: string) => {
    setDismissingId(id);
    const { error } = await dismissAutoQuotation(id);
    setDismissingId(null);
    if (error) { toast.error('Failed to dismiss'); return; }
    toast.success('Auto-quotation dismissed.');
    setPendingAQs(prev => prev.filter(q => q.id !== id));
  };

  const setQF = (field: keyof QuoteForm, v: string) => setQuoteForm(p => ({ ...p, [field]: v }));

  const handleSendQuote = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!selectedReq || !company || !user) return;
    setSending(true);
    const { error } = await createQuotation({
      requirement_id: selectedReq.id,
      supplier_company_id: company.id,
      supplier_id: user.id,
      buyer_id: selectedReq.buyer_id,
      unit_price: parseFloat(quoteForm.unitPrice),
      currency: quoteForm.currency,
      moq: parseInt(quoteForm.moq) || 1,
      moq_unit: quoteForm.moqUnit,
      delivery_days: parseInt(quoteForm.deliveryDays) || null,
      payment_terms: quoteForm.paymentTerms || null,
      validity_days: parseInt(quoteForm.validityDays) || 30,
      notes: quoteForm.notes || null,
      status: 'pending',
    });
    setSending(false);
    if (error) { toast.error(error); return; }
    toast.success('Quotation sent to buyer!');
    // Mark match status as quoted (fire-and-forget)
    updateRfqMatchStatus(selectedReq.id, company.id, 'quoted').catch(() => {});
    setSentIds(prev => new Set([...prev, selectedReq.id]));
    setSelectedReq(null);
    setQuoteForm(emptyQuote);
    // Decrement lead count
    if (subscription) {
      await supabase.from('subscriptions').update({ used_rfq_leads: subscription.used_rfq_leads + 1 }).eq('id', subscription.id);
    }
  };

  return (
    <DashboardLayout>
      <PageMeta
        title="RFQ Leads — Supplier | BulkSkart"
        description="BulkSkart dashboard — manage your account, orders and trade activity."
        robots="noindex, nofollow"
      />
      <div className="flex-1 min-w-0 p-4 md:p-6 overflow-y-auto">
        <div className="max-w-5xl w-full mx-auto">
          <div className="flex flex-col gap-1 md:flex-row md:items-center md:justify-between mb-6">
            <div>
              <h1 className="text-xl font-bold text-foreground">RFQ Leads</h1>
              <p className="text-sm text-muted-foreground">Active buyer requirements matching your categories</p>
            </div>
            {subscription && (
              <div className="text-xs text-muted-foreground bg-card border border-border rounded-lg px-3 py-1.5 self-start md:self-auto">
                <span className="text-foreground font-semibold">{subscription.max_rfq_leads - subscription.used_rfq_leads}</span> leads remaining
              </div>
            )}
          </div>

          {/* Loading skeleton */}
          {loading && (
            <div className="space-y-3">
              {[1, 2, 3].map(i => (
                <div key={i} className="h-36 bg-muted rounded-xl animate-pulse border border-border" />
              ))}
            </div>
          )}

          {!loading && !subscription && (
            <div className="mb-4 flex flex-col gap-2 bg-primary/5 border border-primary/20 rounded-xl p-3 md:p-4 text-sm">
              <div className="flex items-start gap-3">
                <Lock className="w-5 h-5 shrink-0 mt-0.5 text-primary" />
                <div className="flex-1 min-w-0">
                  <p className="font-semibold text-foreground">Subscribe to Access Full RFQ Details</p>
                  <p className="text-xs mt-0.5 text-muted-foreground">You need an active subscription to view buyer contact details and send quotations.</p>
                </div>
              </div>
              <a href="/dashboard/supplier/subscription" className="block">
                <Button size="sm" className="bg-primary text-primary-foreground text-xs w-full">View Plans</Button>
              </a>
            </div>
          )}

          {/* ── Pending Auto-Quotations approval queue ─────────────────── */}
          {!loading && pendingAQs.length > 0 && (
            <div className="mb-6">
              <div className="flex items-center gap-2 mb-3">
                <div className="flex items-center gap-1.5 bg-amber-100 text-amber-700 border border-amber-300 rounded-full px-3 py-1 text-xs font-bold">
                  <Clock className="w-3.5 h-3.5" />
                  {pendingAQs.length} Auto-Quote{pendingAQs.length > 1 ? 's' : ''} Pending Your Approval
                </div>
              </div>
              <div className="space-y-3">
                {pendingAQs.map(aq => {
                  const req = aq.requirements;
                  const fmt = (n: number) => new Intl.NumberFormat('en-IN', { style: 'currency', currency: aq.currency, maximumFractionDigits: 0 }).format(n);
                  return (
                    <div key={aq.id} className="bg-card border border-amber-300/50 rounded-xl p-4">
                      <div className="flex items-start justify-between gap-3 flex-wrap mb-3">
                        <div className="flex-1 min-w-0">
                          <div className="flex items-center gap-2 mb-1 flex-wrap">
                            <span className="flex items-center gap-1 text-[10px] font-bold text-primary bg-primary/10 border border-primary/20 rounded-full px-1.5 py-0.5">
                              <Zap className="w-2.5 h-2.5" /> AUTO-GENERATED
                            </span>
                            <Badge className="text-[10px] bg-amber-100 text-amber-700 border-amber-300">Pending Approval</Badge>
                          </div>
                          <p className="text-sm font-semibold text-foreground truncate">{aq.product_name}</p>
                          {req && (
                            <div className="flex flex-wrap gap-2 text-xs text-muted-foreground mt-1">
                              <span className="flex items-center gap-1"><Package className="w-3 h-3" />{req.quantity} {req.quantity_unit}</span>
                              {req.destination_country && <span className="flex items-center gap-1"><MapPin className="w-3 h-3" />{req.destination_country}</span>}
                              {req.deadline && <span className="flex items-center gap-1"><Calendar className="w-3 h-3" />{new Date(req.deadline).toLocaleDateString('en-GB', { day: '2-digit', month: 'short', year: 'numeric' })}</span>}
                            </div>
                          )}
                        </div>
                        <div className="text-right shrink-0">
                          <p className="text-xs text-muted-foreground">Total Amount</p>
                          <p className="text-base font-bold text-primary">{fmt(aq.total_amount)}</p>
                        </div>
                      </div>

                      {/* Breakdown */}
                      <div className="grid grid-cols-2 md:grid-cols-4 gap-2 text-xs bg-muted/30 rounded-lg p-2.5 mb-3 border border-border">
                        <div><p className="text-muted-foreground">Unit Price</p><p className="font-semibold text-foreground">{fmt(aq.unit_price)}</p></div>
                        <div><p className="text-muted-foreground">Subtotal</p><p className="font-semibold text-foreground">{fmt(aq.subtotal)}</p></div>
                        <div><p className="text-muted-foreground">Shipping + Tax</p><p className="font-semibold text-foreground">{fmt(aq.shipping_cost + aq.tax_amount)}</p></div>
                        <div>
                          <p className="text-muted-foreground flex items-center gap-1"><TrendingUp className="w-3 h-3" />MOQ</p>
                          <p className="font-semibold text-foreground">{aq.moq} {aq.moq_unit}</p>
                        </div>
                      </div>

                      <div className="flex items-center gap-2 flex-wrap">
                        <Button
                          size="sm"
                          onClick={() => handleApproveAQ(aq)}
                          disabled={approvingId === aq.id || !!dismissingId}
                          className="h-8 text-xs bg-green-600 hover:bg-green-700 text-white gap-1.5"
                        >
                          {approvingId === aq.id
                            ? <><RefreshCw className="w-3 h-3 animate-spin" /> Approving…</>
                            : <><CheckCircle className="w-3 h-3" /> Approve & Send</>}
                        </Button>
                        <Button
                          size="sm"
                          variant="outline"
                          onClick={() => handleDismissAQ(aq.id)}
                          disabled={dismissingId === aq.id || !!approvingId}
                          className="h-8 text-xs border-red-300 text-red-600 hover:bg-red-50 gap-1.5"
                        >
                          {dismissingId === aq.id
                            ? <RefreshCw className="w-3 h-3 animate-spin" />
                            : <><XCircle className="w-3 h-3" /> Dismiss</>}
                        </Button>
                        {req && <p className="text-xs text-muted-foreground ml-auto">RFQ: {aq.requirement_id.slice(0, 8).toUpperCase()}</p>}
                      </div>
                    </div>
                  );
                })}
              </div>
            </div>
          )}

          {/* ── RFQ lead list (existing, unchanged) ───────────────────── */}
          {loading ? (
            <div className="space-y-3">{[...Array(4)].map((_, i) => <div key={i} className="h-28 bg-muted rounded-xl animate-pulse" />)}</div>
          ) : requirements.length === 0 ? (
            <div className="bg-card border border-border rounded-xl p-12 text-center text-muted-foreground text-sm">No active requirements found.</div>
          ) : (
            <div className="space-y-3">
              {requirements.map(req => (
                <div key={req.id} className="bg-card border border-border rounded-xl p-3 md:p-4 hover:border-primary/30 transition-colors">
                  <div className="flex items-start justify-between gap-4 flex-wrap">
                    <div className="flex-1 min-w-0">
                      <div className="flex items-center gap-2 flex-wrap mb-1">
                        <p className="text-sm font-semibold text-foreground">{req.title}</p>
                        {req.is_verified_buyer && <span className="verified-badge text-[10px]"><Shield className="w-2.5 h-2.5" />Verified Buyer</span>}
                        {matchScores[req.id] != null && (
                          <span className={`text-[10px] font-bold px-1.5 py-0.5 rounded-full border ${
                            matchScores[req.id] >= 90 ? 'bg-green-500/10 border-green-500/30 text-green-500' :
                            matchScores[req.id] >= 70 ? 'bg-yellow-500/10 border-yellow-500/30 text-yellow-500' :
                            'bg-orange-500/10 border-orange-500/30 text-orange-500'
                          }`}>
                            <Zap className="w-2.5 h-2.5 inline mr-0.5" />Match {matchScores[req.id]}/100
                          </span>
                        )}
                      </div>
                      <div className="flex flex-wrap gap-3 text-xs text-muted-foreground">
                        <span className="flex items-center gap-1"><Package className="w-3 h-3" />{req.quantity} {req.quantity_unit}</span>
                        {req.destination_country && <span className="flex items-center gap-1"><MapPin className="w-3 h-3" />{req.destination_country}</span>}
                        {req.deadline && <span className="flex items-center gap-1"><Calendar className="w-3 h-3" />{new Date(req.deadline).toLocaleDateString('en-GB', { day: '2-digit', month: 'short', year: 'numeric' })}</span>}
                      </div>

                      {/* Gated Buyer Contact Phone */}
                      <div className="flex items-center gap-2 mt-2 pt-1.5 border-t border-border/40 text-xs">
                        <span className="text-muted-foreground text-[11px] font-medium">Buyer Contact:</span>
                        <ProtectedContact
                          phone={(req as any).buyer_phone || (req as any).company?.phone || '+91 98201 44892'}
                          contactType="buyer"
                          variant="inline"
                          showActions={true}
                        />
                      </div>

                      {canViewFull && req.description && <p className="text-xs text-muted-foreground mt-2 line-clamp-2">{req.description}</p>}
                    </div>
                    <div className="flex items-center gap-2 shrink-0">
                      {sentIds.has(req.id) ? (
                        <Badge variant="outline" className="text-xs text-green-400 border-green-400/30">Quote Sent</Badge>
                      ) : canViewFull ? (
                        <Dialog onOpenChange={open => { if (open) setSelectedReq(req); else setSelectedReq(null); }}>
                          <DialogTrigger asChild>
                            <Button size="sm" className="bg-primary text-primary-foreground hover:bg-primary/90 text-xs gap-1">
                              <Send className="w-3 h-3" /> Send Quote
                            </Button>
                          </DialogTrigger>
                          <DialogContent className="max-w-[calc(100%-2rem)] md:max-w-lg bg-card border-border max-h-[90dvh] overflow-y-auto">
                            <DialogHeader>
                              <DialogTitle className="text-foreground text-sm">Send Quotation</DialogTitle>
                            </DialogHeader>
                            <div className="text-xs text-muted-foreground bg-muted rounded-lg p-3 mb-4">
                              <p className="font-medium text-foreground">{req.title}</p>
                              <p>Qty: {req.quantity} {req.quantity_unit} · Dest: {req.destination_country ?? 'Any'}</p>
                            </div>
                            <form onSubmit={handleSendQuote} className="space-y-3">
                              <div className="grid grid-cols-1 gap-3">
                                <div className="space-y-1.5">
                                  <Label className="text-xs text-muted-foreground">Unit Price *</Label>
                                  <Input value={quoteForm.unitPrice} onChange={e => setQF('unitPrice', e.target.value)} type="number" required placeholder="e.g. 250" className="bg-input border-border" />
                                </div>
                                <div className="space-y-1.5">
                                  <Label className="text-xs text-muted-foreground">Currency</Label>
                                  <Select value={quoteForm.currency} onValueChange={v => setQF('currency', v)}>
                                    <SelectTrigger className="bg-input border-border"><SelectValue /></SelectTrigger>
                                    <SelectContent className="bg-card border-border">
                                      {['INR', 'USD', 'EUR', 'GBP', 'AED'].map(c => <SelectItem key={c} value={c}>{c}</SelectItem>)}
                                    </SelectContent>
                                  </Select>
                                </div>
                              </div>
                              <div className="grid grid-cols-2 gap-3">
                                <div className="space-y-1.5">
                                  <Label className="text-xs text-muted-foreground">MOQ *</Label>
                                  <Input value={quoteForm.moq} onChange={e => setQF('moq', e.target.value)} type="number" required className="bg-input border-border" />
                                </div>
                                <div className="space-y-1.5">
                                  <Label className="text-xs text-muted-foreground">Delivery (days)</Label>
                                  <Input value={quoteForm.deliveryDays} onChange={e => setQF('deliveryDays', e.target.value)} type="number" className="bg-input border-border" />
                                </div>
                              </div>
                              <div className="space-y-1.5">
                                <Label className="text-xs text-muted-foreground">Payment Terms</Label>
                                <Input value={quoteForm.paymentTerms} onChange={e => setQF('paymentTerms', e.target.value)} placeholder="e.g. T/T 30% advance, 70% before shipment" className="bg-input border-border" />
                              </div>
                              <div className="space-y-1.5">
                                <Label className="text-xs text-muted-foreground">Notes</Label>
                                <Textarea value={quoteForm.notes} onChange={e => setQF('notes', e.target.value)} rows={2} placeholder="Any additional information..." className="bg-input border-border resize-none" />
                              </div>
                              <Button type="submit" disabled={sending} className="w-full bg-primary text-primary-foreground hover:bg-primary/90">
                                {sending ? 'Sending...' : 'Send Quotation'}
                              </Button>
                            </form>
                          </DialogContent>
                        </Dialog>
                      ) : (
                        <Link to="/dashboard/supplier/subscription" className="text-xs text-primary border border-primary/40 rounded-md px-2 py-1 flex items-center gap-1 hover:bg-primary/10 transition-colors font-semibold">
                          <Lock className="w-3 h-3" /> Subscribe
                        </Link>
                      )}
                    </div>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>
    </DashboardLayout>
  );
}
