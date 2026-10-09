// ─── Country-Wise Charges, Platform Fees, GST & Statutory Taxes Utilities ───────

export interface CountryTaxBreakdown {
  countryCode: string;
  countryName: string;
  flag: string;
  currency: string;
  currencySymbol: string;
  exchangeRateFromUSD: number;

  // Base
  baseAmount: number;

  // Platform & Processing Fees
  platformFeePercent: number; // e.g. 0.02 for 2%
  platformFeeAmount: number;
  fixedProcessingFee: number;
  totalPlatformFees: number;

  // Taxes (GST / VAT / Sales Tax)
  taxName: string;
  taxRatePercent: number; // e.g. 18 for 18%
  taxAmount: number;
  isGst: boolean;
  gstSplit?: {
    cgstPercent: number;
    cgstAmount: number;
    sgstPercent: number;
    sgstAmount: number;
    igstPercent?: number;
    igstAmount?: number;
  };

  // Cross-Border Customs & Port Fees (if applicable)
  customsDutyPercent: number;
  customsDutyAmount: number;
  portClearanceFee: number;

  // Summary
  totalChargesAndFees: number;
  totalPayable: number;

  // Tax note / legal clause
  statutoryNote: string;
}

export interface CountryDefinition {
  code: string;
  name: string;
  flag: string;
  currency: string;
  symbol: string;
  taxName: string;
  taxRate: number; // e.g. 0.18
  platformFeeRate: number; // e.g. 0.02
  fixedFee: number;
  customsRate: number;
  portFee: number;
  isGst?: boolean;
  notes: string;
}

export const COUNTRY_TAX_DEFINITIONS: Record<string, CountryDefinition> = {
  IN: {
    code: 'IN',
    name: 'India',
    flag: '🇮🇳',
    currency: 'INR',
    symbol: '₹',
    taxName: 'GST (Goods & Services Tax)',
    taxRate: 0.18, // 18% GST standard B2B
    platformFeeRate: 0.02, // 2% marketplace escrow
    fixedFee: 0,
    customsRate: 0,
    portFee: 0,
    isGst: true,
    notes: 'Includes 9% CGST + 9% SGST (or 18% IGST for interstate). TCS 1% compliant.',
  },
  US: {
    code: 'US',
    name: 'United States',
    flag: '🇺🇸',
    currency: 'USD',
    symbol: '$',
    taxName: 'State Sales & Digital Tax',
    taxRate: 0.075, // 7.5% average
    platformFeeRate: 0.029, // 2.9%
    fixedFee: 0.30,
    customsRate: 0.025, // 2.5% entry fee
    portFee: 15,
    notes: 'Automated state-level nexus calculation & US Customs Form 7501 support.',
  },
  AE: {
    code: 'AE',
    name: 'United Arab Emirates',
    flag: '🇦🇪',
    currency: 'AED',
    symbol: 'AED ',
    taxName: 'UAE VAT',
    taxRate: 0.05, // 5% VAT
    platformFeeRate: 0.025,
    fixedFee: 1.0,
    customsRate: 0.05, // 5% GCC tariff
    portFee: 50,
    notes: 'FTA VAT registration verified with Jebel Ali Free Zone handling fees.',
  },
  GB: {
    code: 'GB',
    name: 'United Kingdom',
    flag: '🇬🇧',
    currency: 'GBP',
    symbol: '£',
    taxName: 'HMRC Standard VAT',
    taxRate: 0.20, // 20% VAT
    platformFeeRate: 0.025,
    fixedFee: 0.20,
    customsRate: 0.02,
    portFee: 20,
    notes: 'HMRC EORI registered compliance with CDS import declaration.',
  },
  DE: {
    code: 'DE',
    name: 'Germany / European Union',
    flag: '🇩🇪',
    currency: 'EUR',
    symbol: '€',
    taxName: 'EU MwSt / Standard VAT',
    taxRate: 0.19, // 19% German VAT
    platformFeeRate: 0.025,
    fixedFee: 0.25,
    customsRate: 0.02,
    portFee: 25,
    notes: 'EU OSS & TARIC compliant with reverse charge mechanism for verified B2B EU-VAT IDs.',
  },
  SG: {
    code: 'SG',
    name: 'Singapore',
    flag: '🇸🇬',
    currency: 'SGD',
    symbol: 'S$',
    taxName: 'Singapore GST',
    taxRate: 0.09, // 9% SG GST
    platformFeeRate: 0.028,
    fixedFee: 0.50,
    customsRate: 0,
    portFee: 30,
    isGst: true,
    notes: 'IRAS Singapore 9% GST compliant with PSA maritime clearance protocols.',
  },
  AU: {
    code: 'AU',
    name: 'Australia',
    flag: '🇦🇺',
    currency: 'AUD',
    symbol: 'A$',
    taxName: 'Australian GST',
    taxRate: 0.10, // 10% AU GST
    platformFeeRate: 0.026,
    fixedFee: 0.30,
    customsRate: 0.05,
    portFee: 35,
    isGst: true,
    notes: 'ATO GST registered with Australian Border Force ICS compliance.',
  },
  CA: {
    code: 'CA',
    name: 'Canada',
    flag: '🇨🇦',
    currency: 'CAD',
    symbol: 'C$',
    taxName: 'HST / GST',
    taxRate: 0.13, // 13% average harmonized
    platformFeeRate: 0.029,
    fixedFee: 0.30,
    customsRate: 0.03,
    portFee: 25,
    isGst: true,
    notes: 'CRA registered with CARM (CBSA Assessment and Revenue Management).',
  },
  CN: {
    code: 'CN',
    name: 'China',
    flag: '🇨🇳',
    currency: 'CNY',
    symbol: '¥',
    taxName: 'China VAT',
    taxRate: 0.06, // 6% cross-border service VAT
    platformFeeRate: 0.018,
    fixedFee: 0,
    customsRate: 0,
    portFee: 40,
    notes: 'Special cross-border B2B trade zone clearance and export verification.',
  },
  JP: {
    code: 'JP',
    name: 'Japan',
    flag: '🇯🇵',
    currency: 'JPY',
    symbol: '¥',
    taxName: 'JCT (Japanese Consumption Tax)',
    taxRate: 0.10, // 10% JCT
    platformFeeRate: 0.032,
    fixedFee: 0,
    customsRate: 0.03,
    portFee: 3000,
    notes: 'National Tax Agency qualified invoice system (QIS) compliant.',
  },
};

export const GLOBAL_COUNTRIES = Object.values(COUNTRY_TAX_DEFINITIONS);

export function calculateCountryChargesAndTaxes(
  baseAmount: number,
  countryCode: string = 'IN',
  isIntraState: boolean = false
): CountryTaxBreakdown {
  const def = COUNTRY_TAX_DEFINITIONS[countryCode.toUpperCase()] || COUNTRY_TAX_DEFINITIONS.IN;

  const platformFee = Math.round(baseAmount * def.platformFeeRate * 100) / 100;
  const fixedFee = def.fixedFee;
  const totalPlatformFees = Math.round((platformFee + fixedFee) * 100) / 100;

  // Base + Platform Fees subject to statutory tax
  const taxableSubtotal = baseAmount + totalPlatformFees;
  const taxAmount = Math.round(taxableSubtotal * def.taxRate * 100) / 100;

  let gstSplit: CountryTaxBreakdown['gstSplit'] | undefined;
  if (def.isGst) {
    if (def.code === 'IN') {
      if (isIntraState) {
        const halfRate = (def.taxRate * 100) / 2;
        const halfTax = Math.round((taxAmount / 2) * 100) / 100;
        gstSplit = {
          cgstPercent: halfRate,
          cgstAmount: halfTax,
          sgstPercent: halfRate,
          sgstAmount: halfTax,
        };
      } else {
        gstSplit = {
          cgstPercent: 0,
          cgstAmount: 0,
          sgstPercent: 0,
          sgstAmount: 0,
          igstPercent: def.taxRate * 100,
          igstAmount: taxAmount,
        };
      }
    }
  }

  const customsDutyAmount = Math.round(baseAmount * def.customsRate * 100) / 100;
  const portClearanceFee = def.portFee;

  const totalChargesAndFees = Math.round(
    (totalPlatformFees + taxAmount + customsDutyAmount + portClearanceFee) * 100
  ) / 100;

  const totalPayable = Math.round((baseAmount + totalChargesAndFees) * 100) / 100;

  return {
    countryCode: def.code,
    countryName: def.name,
    flag: def.flag,
    currency: def.currency,
    currencySymbol: def.symbol,
    exchangeRateFromUSD: 1, // Normalized local
    baseAmount,
    platformFeePercent: def.platformFeeRate * 100,
    platformFeeAmount: platformFee,
    fixedProcessingFee: fixedFee,
    totalPlatformFees,
    taxName: def.taxName,
    taxRatePercent: def.taxRate * 100,
    taxAmount,
    isGst: !!def.isGst,
    gstSplit,
    customsDutyPercent: def.customsRate * 100,
    customsDutyAmount,
    portClearanceFee,
    totalChargesAndFees,
    totalPayable,
    statutoryNote: def.notes,
  };
}

export function formatCountryAmount(amount: number, symbol: string): string {
  return `${symbol}${amount.toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`;
}
