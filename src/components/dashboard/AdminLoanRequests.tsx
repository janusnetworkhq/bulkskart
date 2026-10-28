import { useEffect, useState } from 'react';
import { Badge } from '@/components/ui/badge';
import { supabase } from '@/db/supabase';
import { toast } from 'sonner';

interface LoanRequestRow {
  id: string;
  full_name: string;
  company_name: string;
  email: string;
  phone: string;
  city: string;
  loan_amount: number;
  currency: string;
  tenure_months: number | null;
  monthly_installment: number | null;
  goods_needed: string | null;
  status: string;
  created_at: string;
}

const STATUSES = ['new', 'reviewing', 'contacted', 'closed'] as const;

function money(amount: number, currency: string): string {
  try {
    return new Intl.NumberFormat('en-IN', { style: 'currency', currency, maximumFractionDigits: 0 }).format(amount);
  } catch {
    return `${currency} ${Math.round(amount).toLocaleString('en-IN')}`;
  }
}

export default function AdminLoanRequests() {
  const [rows, setRows] = useState<LoanRequestRow[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let active = true;
    supabase
      .from('loan_requests')
      .select('id, full_name, company_name, email, phone, city, loan_amount, currency, tenure_months, monthly_installment, goods_needed, status, created_at')
      .order('created_at', { ascending: false })
      .limit(100)
      .then(({ data, error }) => {
        if (!active) return;
        if (error) toast.error('Could not load loan requests');
        setRows((data ?? []) as LoanRequestRow[]);
        setLoading(false);
      });
    return () => {
      active = false;
    };
  }, []);

  const updateStatus = async (id: string, status: string) => {
    const previous = rows;
    setRows((current) => current.map((row) => (row.id === id ? { ...row, status } : row)));
    const { error } = await supabase.from('loan_requests').update({ status }).eq('id', id);
    if (error) {
      setRows(previous);
      toast.error('Could not update this request');
    }
  };

  if (loading) {
    return <div className="h-40 rounded-xl bg-muted animate-pulse" />;
  }

  if (rows.length === 0) {
    return (
      <div className="rounded-xl border border-border bg-card p-10 text-center text-sm text-muted-foreground">
        No loan requests yet. New submissions from the landing page will appear here.
      </div>
    );
  }

  return (
    <div className="overflow-hidden rounded-xl border border-border bg-card">
      <div className="overflow-x-auto">
        <table className="w-full whitespace-nowrap">
          <thead>
            <tr className="border-b border-border bg-muted/50">
              {['Buyer', 'Contact', 'Loan', 'Goods', 'Status', 'Submitted'].map((heading) => (
                <th key={heading} className="px-4 py-3 text-left text-xs font-semibold text-muted-foreground">{heading}</th>
              ))}
            </tr>
          </thead>
          <tbody>
            {rows.map((row) => (
              <tr key={row.id} className="border-b border-border align-top">
                <td className="px-4 py-3">
                  <p className="text-sm font-medium text-foreground">{row.full_name}</p>
                  <p className="text-xs text-muted-foreground">{row.company_name}</p>
                  <p className="text-xs text-muted-foreground">{row.city}</p>
                </td>
                <td className="px-4 py-3 text-xs text-muted-foreground">
                  <p>{row.phone}</p>
                  <p>{row.email}</p>
                </td>
                <td className="px-4 py-3 text-xs">
                  <p className="font-semibold text-foreground">{money(Number(row.loan_amount), row.currency || 'INR')}</p>
                  <p className="text-muted-foreground">
                    {row.tenure_months ? `${row.tenure_months} mo` : '—'}
                    {row.monthly_installment ? ` · ${money(Number(row.monthly_installment), row.currency || 'INR')}/mo` : ''}
                  </p>
                </td>
                <td className="px-4 py-3 max-w-[220px] whitespace-normal text-xs text-muted-foreground">{row.goods_needed || '—'}</td>
                <td className="px-4 py-3">
                  <select
                    value={row.status}
                    onChange={(event) => updateStatus(row.id, event.target.value)}
                    className="h-8 rounded-md border border-border bg-background px-2 text-xs"
                    aria-label={`Status for ${row.full_name}`}
                  >
                    {STATUSES.map((status) => (
                      <option key={status} value={status}>{status}</option>
                    ))}
                  </select>
                  {row.status === 'new' ? <Badge className="ml-2 bg-[#FF5A00]/15 text-[#FF5A00]">New</Badge> : null}
                </td>
                <td className="px-4 py-3 text-xs text-muted-foreground">{new Date(row.created_at).toLocaleString('en-IN', { dateStyle: 'medium', timeStyle: 'short' })}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
