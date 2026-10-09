/**
 * realtimeExchangeRate.ts
 *
 * Real-time currency exchange rates service for the AI Import & Export Assistant.
 * Connects directly to the Supabase Edge Function `exchange-rate` (backed by ExchangeRate-API)
 * with robust local caching, instant cross-currency conversion, and commercial bank spread estimation.
 */

import { supabase } from '@/db/supabase';

export interface CurrencyConfig {
  code: string;
  name: string;
  symbol: string;
  flag: string;
  defaultSpread: number; // percentage buffer for commercial settlements
}

export const SUPPORTED_TRADE_CURRENCIES: Record<string, CurrencyConfig> = {
  USD: { code: 'USD', name: 'US Dollar', symbol: '$', flag: 'US', defaultSpread: 0.5 },
  INR: { code: 'INR', name: 'Indian Rupee', symbol: '₹', flag: 'IN', defaultSpread: 0.8 },
  EUR: { code: 'EUR', name: 'Euro', symbol: '€', flag: 'EU', defaultSpread: 0.6 },
  GBP: { code: 'GBP', name: 'British Pound', symbol: '£', flag: 'GB', defaultSpread: 0.6 },
  AED: { code: 'AED', name: 'UAE Dirham', symbol: 'AED', flag: 'AE', defaultSpread: 0.7 },
  CNY: { code: 'CNY', name: 'Chinese Yuan', symbol: '¥', flag: 'CN', defaultSpread: 0.9 },
  JPY: { code: 'JPY', name: 'Japanese Yen', symbol: '¥', flag: 'JP', defaultSpread: 0.8 },
  AUD: { code: 'AUD', name: 'Australian Dollar', symbol: 'A$', flag: 'AU', defaultSpread: 0.7 },
  CAD: { code: 'CAD', name: 'Canadian Dollar', symbol: 'C$', flag: 'CA', defaultSpread: 0.7 },
  SGD: { code: 'SGD', name: 'Singapore Dollar', symbol: 'S$', flag: 'SG', defaultSpread: 0.6 },
};

export const DEFAULT_FALLBACK_RATES: Record<string, number> = {
  USD: 1.0,
  INR: 83.54,
  EUR: 0.924,
  GBP: 0.789,
  AED: 3.673,
  CNY: 7.235,
  JPY: 151.35,
  AUD: 1.528,
  CAD: 1.359,
  SGD: 1.342,
};

export interface LiveRatesResult {
  base_code: string;
  rates: Record<string, number>;
  lastUpdated: string;
  lastUpdatedTimestamp: number;
  isLive: boolean;
  source: 'live_gateway' | 'cached' | 'resilient_rates';
}

const CACHE_KEY = 'bulkskart_live_fx_rates';
const CACHE_DURATION_MS = 60 * 60 * 1000; // 1 hour client cache

/**
 * Fetch real-time exchange rates against USD (or custom base)
 */
export async function getLiveExchangeRates(baseCurrency = 'USD', forceRefresh = false): Promise<LiveRatesResult> {
  const normalizedBase = baseCurrency.toUpperCase();

  // 1. Check local cache if not forcing refresh
  if (!forceRefresh) {
    try {
      const cached = localStorage.getItem(`${CACHE_KEY}_${normalizedBase}`);
      if (cached) {
        const parsed = JSON.parse(cached);
        const age = Date.now() - (parsed.lastUpdatedTimestamp || 0);
        if (age < CACHE_DURATION_MS && parsed.rates && Object.keys(parsed.rates).length > 0) {
          return {
            ...parsed,
            source: 'cached',
          };
        }
      }
    } catch {}
  }

  // 2. Fetch from Supabase Edge Function
  try {
    const timeoutPromise = new Promise<null>((resolve) => setTimeout(() => resolve(null), 4000));
    const invokePromise = supabase.functions.invoke('exchange-rate', {
      body: { base_currency: normalizedBase },
    });

    const res = await Promise.race([invokePromise, timeoutPromise]);

    if (res && 'data' in res && res.data?.conversion_rates) {
      const rates = res.data.conversion_rates;
      const result: LiveRatesResult = {
        base_code: normalizedBase,
        rates,
        lastUpdated: res.data.time_last_update_utc || new Date().toUTCString(),
        lastUpdatedTimestamp: Date.now(),
        isLive: res.data.source !== 'resilient_rates',
        source: res.data.source === 'resilient_rates' ? 'resilient_rates' : 'live_gateway',
      };

      try {
        localStorage.setItem(`${CACHE_KEY}_${normalizedBase}`, JSON.stringify(result));
      } catch {}

      return result;
    }
  } catch (err) {
    console.warn('[FX] Failed to fetch live rates, falling back to resilient rates', err);
  }

  // 3. Fallback normalization from DEFAULT_FALLBACK_RATES
  const baseInUsd = DEFAULT_FALLBACK_RATES[normalizedBase] || 1;
  const normalizedRates: Record<string, number> = {};
  for (const [k, v] of Object.entries(DEFAULT_FALLBACK_RATES)) {
    normalizedRates[k] = Number((v / baseInUsd).toFixed(4));
  }

  return {
    base_code: normalizedBase,
    rates: normalizedRates,
    lastUpdated: new Date().toUTCString(),
    lastUpdatedTimestamp: Date.now(),
    isLive: false,
    source: 'resilient_rates',
  };
}

/**
 * Convert any amount from one currency to another using the USD-base rate table
 */
export function convertCrossCurrency(
  amount: number,
  fromCurrency: string,
  toCurrency: string,
  usdRates: Record<string, number>
): {
  convertedAmount: number;
  rate: number;
  reverseRate: number;
} {
  const from = fromCurrency.toUpperCase();
  const to = toCurrency.toUpperCase();

  if (from === to || !amount) {
    return { convertedAmount: amount, rate: 1, reverseRate: 1 };
  }

  const fromRateInUsd = usdRates[from] ?? DEFAULT_FALLBACK_RATES[from] ?? 1;
  const toRateInUsd = usdRates[to] ?? DEFAULT_FALLBACK_RATES[to] ?? 1;

  // Direct conversion: (amount / fromRate) * toRate
  const rate = toRateInUsd / fromRateInUsd;
  const reverseRate = fromRateInUsd / toRateInUsd;
  const convertedAmount = amount * rate;

  return {
    convertedAmount: Number(convertedAmount.toFixed(2)),
    rate: Number(rate.toFixed(4)),
    reverseRate: Number(reverseRate.toFixed(4)),
  };
}

/**
 * Format currency with official symbol and locale standard
 */
export function formatCurrencyValue(amount: number, currencyCode: string): string {
  const config = SUPPORTED_TRADE_CURRENCIES[currencyCode.toUpperCase()] || {
    symbol: currencyCode,
    code: currencyCode,
  };

  const formattedNum = new Intl.NumberFormat('en-US', {
    minimumFractionDigits: amount < 10 && amount % 1 !== 0 ? 2 : 0,
    maximumFractionDigits: 2,
  }).format(amount);

  return `${config.symbol} ${formattedNum}`;
}
