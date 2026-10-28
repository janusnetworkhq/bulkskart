/**
 * Order financing math for the landing-page loan calculator.
 * Closed-form reducing-balance EMI: O(1) time, no amortization loop, no network.
 */

export interface LoanRange {
  min: number;
  max: number;
  step: number;
  defaultAmount: number;
  presets: readonly number[];
}

const RANGES: Record<string, LoanRange> = {
  INR: { min: 10_000, max: 50_000_000, step: 10_000, defaultAmount: 250_000, presets: [50_000, 250_000, 1_000_000, 5_000_000] },
  USD: { min: 200, max: 500_000, step: 100, defaultAmount: 5_000, presets: [1_000, 5_000, 25_000, 100_000] },
  EUR: { min: 200, max: 500_000, step: 100, defaultAmount: 5_000, presets: [1_000, 5_000, 25_000, 100_000] },
  GBP: { min: 200, max: 400_000, step: 100, defaultAmount: 4_000, presets: [1_000, 4_000, 20_000, 80_000] },
  AED: { min: 1_000, max: 2_000_000, step: 500, defaultAmount: 20_000, presets: [5_000, 20_000, 75_000, 250_000] },
  JPY: { min: 20_000, max: 50_000_000, step: 10_000, defaultAmount: 750_000, presets: [100_000, 750_000, 3_000_000, 10_000_000] },
  CNY: { min: 1_000, max: 2_000_000, step: 500, defaultAmount: 30_000, presets: [5_000, 30_000, 100_000, 400_000] },
  AUD: { min: 200, max: 500_000, step: 100, defaultAmount: 7_000, presets: [1_000, 7_000, 25_000, 100_000] },
  CAD: { min: 200, max: 500_000, step: 100, defaultAmount: 7_000, presets: [1_000, 7_000, 25_000, 100_000] },
  SGD: { min: 200, max: 500_000, step: 100, defaultAmount: 6_000, presets: [1_000, 6_000, 25_000, 80_000] },
};

export const RATE_LIMITS = { min: 0, max: 36, step: 0.1, default: 12 } as const;
export const TENURE_LIMITS = { min: 3, max: 60, step: 1, default: 12 } as const;
export const DOWN_LIMITS = { min: 0, max: 80, step: 5, default: 0 } as const;
export const TENURE_PRESETS = [6, 12, 24, 36] as const;

/** Platform promise: delivery fee is zero on every order. */
export const FREE_DELIVERY_FEE = 0;

export function loanRange(currency: string): LoanRange {
  return RANGES[currency] ?? RANGES.USD;
}

export interface LoanQuote {
  orderAmount: number;
  downPaymentPct: number;
  downPayment: number;
  principal: number;
  annualRatePct: number;
  months: number;
  emi: number;
  totalPayable: number;
  totalInterest: number;
  deliveryFee: 0;
  payToday: number;
}

function clamp(value: number, min: number, max: number): number {
  if (!Number.isFinite(value)) return min;
  return Math.min(max, Math.max(min, value));
}

function roundMoney(value: number): number {
  return Math.round((value + Number.EPSILON) * 100) / 100;
}

/** Reducing-balance installment for a principal the buyer asked to finance. */
export function monthlyInstallment(principal: number, annualRatePct: number, months: number): number {
  const safePrincipal = Number.isFinite(principal) ? Math.max(0, principal) : 0;
  const rate = clamp(annualRatePct, RATE_LIMITS.min, RATE_LIMITS.max);
  const term = Math.round(clamp(months, TENURE_LIMITS.min, TENURE_LIMITS.max));
  if (safePrincipal <= 0 || term <= 0) return 0;
  const monthlyRate = rate / 12 / 100;
  if (monthlyRate === 0) return roundMoney(safePrincipal / term);
  const growth = (1 + monthlyRate) ** term;
  return roundMoney((safePrincipal * monthlyRate * growth) / (growth - 1));
}

export function quoteOrderLoan(input: {
  orderAmount: number;
  downPaymentPct: number;
  annualRatePct: number;
  months: number;
  currency?: string;
}): LoanQuote {
  const range = loanRange(input.currency ?? 'INR');
  const orderAmount = clamp(input.orderAmount, range.min, range.max);
  const downPaymentPct = clamp(input.downPaymentPct, DOWN_LIMITS.min, DOWN_LIMITS.max);
  const annualRatePct = clamp(input.annualRatePct, RATE_LIMITS.min, RATE_LIMITS.max);
  const months = Math.round(clamp(input.months, TENURE_LIMITS.min, TENURE_LIMITS.max));

  const downPayment = roundMoney(orderAmount * (downPaymentPct / 100));
  const principal = roundMoney(Math.max(0, orderAmount - downPayment));
  const monthlyRate = annualRatePct / 12 / 100;

  let emi = 0;
  if (principal > 0 && months > 0) {
    if (monthlyRate === 0) {
      emi = principal / months;
    } else {
      const growth = (1 + monthlyRate) ** months;
      emi = (principal * monthlyRate * growth) / (growth - 1);
    }
  }

  emi = roundMoney(emi);
  const totalPayable = roundMoney(emi * months);
  const totalInterest = roundMoney(Math.max(0, totalPayable - principal));

  return {
    orderAmount,
    downPaymentPct,
    downPayment,
    principal,
    annualRatePct,
    months,
    emi,
    totalPayable,
    totalInterest,
    deliveryFee: FREE_DELIVERY_FEE,
    payToday: downPayment,
  };
}
