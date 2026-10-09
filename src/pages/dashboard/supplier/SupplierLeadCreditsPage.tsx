import React, { useEffect, useState } from 'react';
import DashboardLayout from '@/components/layouts/DashboardLayout';
import PageMeta from '@/components/common/PageMeta';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card';
import { Dialog, DialogContent, DialogHeader, DialogTitle } from '@/components/ui/dialog';
import { useAuth } from '@/contexts/AuthContext';
import { supabase } from '@/db/supabase';
import { toast } from 'sonner';
import {
  Zap, TrendingUp, CreditCard, RefreshCw, CheckCircle2,
  ArrowUpRight, ArrowDownRight, Gift, Package,
} from 'lucide-react';

interface CreditTx {
  id: string;
  type: 'purchase' | 'consume' | 'refund' | 'bonus';
  credits: number;
  amount_inr: number | null;
  description: string | null;
  created_at: string;
}

const PACKS = [
  { credits: 10, price: 299, label: 'Starter', popular: false, perCredit: 29.9 },
  { credits: 25, price: 599, label: 'Growth', popular: true, perCredit: 23.96 },
  { credits: 60, price: 999, label: 'Pro', popular: false, perCredit: 16.65 },
  { credits: 150, price: 1999, label: 'Enterprise', popular: false, perCredit: 13.33 },
];

function TxRow({ tx }: { tx: CreditTx }) {
  const isCredit = tx.type === 'purchase' || tx.type === 'refund' || tx.type === 'bonus';
  return (
    <div className="flex items-center justify-between py-3 border-b border-border last:border-0">
      <div className="flex items-center gap-3">
        <div className={`w-8 h-8 rounded-full flex items-center justify-center shrink-0 ${isCredit ? 'bg-green-100 dark:bg-green-950' : 'bg-red-100 dark:bg-red-950'}`}>
          {isCredit
            ? <ArrowDownRight className="w-4 h-4 text-green-600" />
            : <ArrowUpRight className="w-4 h-4 text-red-500" />
          }
        </div>
        <div>
          <p className="text-sm font-medium text-foreground capitalize">{tx.type === 'consume' ? 'Lead Unlocked' : tx.type}</p>
          <p className="text-xs text-muted-foreground">{tx.description ?? '—'}</p>
        </div>
      </div>
      <div className="text-right shrink-0 ml-3">
        <p className={`text-sm font-bold ${isCredit ? 'text-green-600' : 'text-destructive'}`}>
          {isCredit ? '+' : '-'}{tx.credits} credits
        </p>
        <p className="text-xs text-muted-foreground">{new Date(tx.created_at).toLocaleDateString('en-IN')}</p>
      </div>
    </div>
  );
}

export default function SupplierLeadCreditsPage() {
  const { company } = useAuth();
  const [txs, setTxs] = useState<CreditTx[]>([]);
  const [creditBalance, setCreditBalance] = useState(0);
  const [loading, setLoading] = useState(true);
  const [buyDialogOpen, setBuyDialogOpen] = useState(false);
  const [selectedPack, setSelectedPack] = useState<(typeof PACKS)[0] | null>(null);
  const [purchasing, setPurchasing] = useState(false);

  const fetchData = async () => {
    if (!company) return;
    setLoading(true);
    const [{ data: comp }, { data: history }] = await Promise.all([
      supabase.from('companies').select('lead_credits').eq('id', company.id).maybeSingle(),
      supabase.from('lead_credit_transactions').select('*').eq('company_id', company.id).order('created_at', { ascending: false }).limit(30),
    ]);
    setCreditBalance(comp?.lead_credits ?? 0);
    setTxs((history ?? []) as CreditTx[]);
    setLoading(false);
  };

  useEffect(() => { fetchData(); }, [company]);

  const handlePurchase = async () => {
    if (!company || !selectedPack) return;
    setPurchasing(true);
    // In production this would go via Razorpay Edge Function
    // For now, add credits directly (demo mode)
    const { error } = await supabase.from('lead_credit_transactions').insert({
      company_id: company.id,
      type: 'purchase',
      credits: selectedPack.credits,
      amount_inr: selectedPack.price,
      description: `${selectedPack.label} Pack — ${selectedPack.credits} lead credits`,
    });
    if (!error) {
      await supabase.from('companies').update({ lead_credits: creditBalance + selectedPack.credits }).eq('id', company.id);
    }
    setPurchasing(false);
    setBuyDialogOpen(false);
    setSelectedPack(null);
    if (error) { toast.error(error.message); return; }
    toast.success(`${selectedPack.credits} lead credits added!`);
    fetchData();
  };

  const consumed = txs.filter(t => t.type === 'consume').reduce((s, t) => s + t.credits, 0);
  const earned = txs.filter(t => t.type !== 'consume').reduce((s, t) => s + t.credits, 0);

  return (
    <DashboardLayout>
      <PageMeta title="Lead Credits — Supplier | BulkSkart" description="Purchase and manage lead credits." robots="noindex, nofollow" />
      <div className="flex-1 min-w-0 p-4 md:p-6 overflow-y-auto">
        <div className="max-w-3xl w-full mx-auto">
          <div className="flex flex-col gap-1 md:flex-row md:items-center md:justify-between mb-6">
            <div>
              <h1 className="text-xl font-bold text-foreground">Lead Credits</h1>
              <p className="text-sm text-muted-foreground">Purchase credits to unlock direct buyer contact details</p>
            </div>
            <Button onClick={() => setBuyDialogOpen(true)} className="bg-primary text-primary-foreground gap-2 self-start md:self-auto">
              <CreditCard className="w-4 h-4" /> Buy Credits
            </Button>
          </div>

          {/* Balance cards */}
          <div className="grid grid-cols-1 md:grid-cols-3 gap-3 mb-6">
            <Card className="bg-primary/5 border-primary/20">
              <CardContent className="p-3 text-center">
                <Zap className="w-5 h-5 text-primary mx-auto mb-1" />
                <p className="text-2xl font-bold text-primary">{loading ? '…' : creditBalance}</p>
                <p className="text-xs text-muted-foreground">Available</p>
              </CardContent>
            </Card>
            <Card>
              <CardContent className="p-3 text-center">
                <TrendingUp className="w-5 h-5 text-green-600 mx-auto mb-1" />
                <p className="text-2xl font-bold text-foreground">{earned}</p>
                <p className="text-xs text-muted-foreground">Total Earned</p>
              </CardContent>
            </Card>
            <Card>
              <CardContent className="p-3 text-center">
                <Package className="w-5 h-5 text-muted-foreground mx-auto mb-1" />
                <p className="text-2xl font-bold text-foreground">{consumed}</p>
                <p className="text-xs text-muted-foreground">Leads Unlocked</p>
              </CardContent>
            </Card>
          </div>

          {/* Info */}
          <div className="mb-5 flex items-start gap-3 bg-card border border-border rounded-xl p-3 text-sm">
            <Gift className="w-4 h-4 text-primary shrink-0 mt-0.5" />
            <p className="text-muted-foreground text-xs leading-relaxed">
              Each lead credit unlocks <span className="text-foreground font-medium">1 buyer's full contact details</span> (phone, email, company) from the RFQ feed.
              Credits never expire and roll over between subscription cycles.
            </p>
          </div>

          {/* Transaction history */}
          <Card>
            <CardHeader className="pb-3">
              <CardTitle className="text-base">Transaction History</CardTitle>
              <CardDescription>Your credit purchases and usage</CardDescription>
            </CardHeader>
            <CardContent className="px-4 pb-4">
              {loading ? (
                <div className="space-y-3">
                  {[...Array(4)].map((_, i) => <div key={i} className="h-14 bg-muted rounded-lg animate-pulse" />)}
                </div>
              ) : txs.length === 0 ? (
                <div className="text-center py-8">
                  <CreditCard className="w-8 h-8 text-muted-foreground mx-auto mb-2" />
                  <p className="text-sm text-muted-foreground">No transactions yet. Buy your first pack!</p>
                </div>
              ) : (
                txs.map(tx => <TxRow key={tx.id} tx={tx} />)
              )}
            </CardContent>
          </Card>
        </div>
      </div>

      {/* Buy Dialog */}
      <Dialog open={buyDialogOpen} onOpenChange={open => { setBuyDialogOpen(open); if (!open) setSelectedPack(null); }}>
        <DialogContent className="max-w-[calc(100%-2rem)] md:max-w-lg bg-card border-border max-h-[90dvh] overflow-y-auto">
          <DialogHeader>
            <DialogTitle className="text-foreground">Buy Lead Credits</DialogTitle>
          </DialogHeader>
          <div className="grid grid-cols-2 gap-3 mt-2">
            {PACKS.map(pack => (
              <button
                key={pack.credits}
                onClick={() => setSelectedPack(pack)}
                className={`relative rounded-xl border-2 p-4 text-left transition-all ${selectedPack?.credits === pack.credits ? 'border-primary bg-primary/5' : 'border-border bg-background hover:border-primary/40'}`}
              >
                {pack.popular && (
                  <span className="absolute -top-2 left-1/2 -translate-x-1/2 text-[10px] font-bold bg-primary text-primary-foreground px-2 py-0.5 rounded-full">Popular</span>
                )}
                <p className="text-base font-bold text-foreground">{pack.credits} Credits</p>
                <p className="text-xs text-muted-foreground">{pack.label}</p>
                <p className="text-lg font-bold text-primary mt-2">₹{pack.price}</p>
                <p className="text-[10px] text-muted-foreground">₹{pack.perCredit.toFixed(1)}/credit</p>
              </button>
            ))}
          </div>
          {selectedPack && (
            <div className="mt-3 p-3 bg-muted/50 rounded-lg flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-foreground">{selectedPack.credits} lead credits</p>
                <p className="text-xs text-muted-foreground">{selectedPack.label} Pack</p>
              </div>
              <p className="text-lg font-bold text-primary">₹{selectedPack.price}</p>
            </div>
          )}
          <Button
            onClick={handlePurchase}
            disabled={!selectedPack || purchasing}
            className="w-full bg-primary text-primary-foreground hover:bg-primary/90 mt-2"
          >
            {purchasing ? <><RefreshCw className="w-3.5 h-3.5 mr-1.5 animate-spin" /> Processing…</> : 'Buy Now via Razorpay'}
          </Button>
          <p className="text-center text-xs text-muted-foreground">Secure payment powered by Razorpay · Credits added instantly</p>
        </DialogContent>
      </Dialog>
    </DashboardLayout>
  );
}
