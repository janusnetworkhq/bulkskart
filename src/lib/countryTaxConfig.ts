export interface CountryTaxInfo {
  code: string;
  name: string;
  flag: string;
  currency: string;
  currencySymbol: string;
  baseFee: number; // Compulsory 60-min bidding subscription fee
  taxRate: number; // e.g. 0.18 for 18%
  taxName: string; // e.g. '18% GST (CGST 9% + SGST 9%)'
  taxDescription: string;
}

export const SUPPORTED_COUNTRIES: CountryTaxInfo[] = [
  {
    code: 'IN',
    name: 'India',
    flag: '🇮🇳',
    currency: 'INR',
    currencySymbol: '₹',
    baseFee: 5000,
    taxRate: 0.18,
    taxName: '18% GST (CGST 9% + SGST 9%)',
    taxDescription: 'Statutory Indian Goods & Services Tax for B2B Digital Marketplace Services'
  },
  {
    code: 'US',
    name: 'United States',
    flag: '🇺🇸',
    currency: 'USD',
    currencySymbol: '$',
    baseFee: 60,
    taxRate: 0.0825,
    taxName: '8.25% State & Municipal Sales Tax',
    taxDescription: 'Standard B2B Commercial Technology & Digital Platform Fee'
  },
  {
    code: 'AE',
    name: 'United Arab Emirates',
    flag: '🇦🇪',
    currency: 'AED',
    currencySymbol: 'AED ',
    baseFee: 220,
    taxRate: 0.05,
    taxName: '5% UAE Federal VAT',
    taxDescription: 'Federal Tax Authority (FTA) Standard B2B Commercial VAT'
  },
  {
    code: 'GB',
    name: 'United Kingdom',
    flag: '🇬🇧',
    currency: 'GBP',
    currencySymbol: '£',
    baseFee: 48,
    taxRate: 0.20,
    taxName: '20% UK Standard VAT',
    taxDescription: 'HMRC Standard Rate Value Added Tax for Commercial Platforms'
  },
  {
    code: 'EU',
    name: 'European Union (Germany / France / Italy)',
    flag: '🇪🇺',
    currency: 'EUR',
    currencySymbol: '€',
    baseFee: 55,
    taxRate: 0.19,
    taxName: '19% EU Standard VAT',
    taxDescription: 'European Union Reverse-Charge / Cross-Border Digital Services VAT'
  },
  {
    code: 'SG',
    name: 'Singapore',
    flag: '🇸🇬',
    currency: 'SGD',
    currencySymbol: 'S$',
    baseFee: 80,
    taxRate: 0.09,
    taxName: '9% Singapore GST',
    taxDescription: 'Inland Revenue Authority of Singapore (IRAS) Standard GST'
  },
  {
    code: 'AU',
    name: 'Australia',
    flag: '🇦🇺',
    currency: 'AUD',
    currencySymbol: 'A$',
    baseFee: 90,
    taxRate: 0.10,
    taxName: '10% Australian GST',
    taxDescription: 'Australian Taxation Office (ATO) Standard Business Services GST'
  },
  {
    code: 'CA',
    name: 'Canada',
    flag: '🇨🇦',
    currency: 'CAD',
    currencySymbol: 'C$',
    baseFee: 82,
    taxRate: 0.13,
    taxName: '13% Harmonized Sales Tax (HST)',
    taxDescription: 'CRA Federal & Provincial Standard Harmonized Tax'
  },
  {
    code: 'SA',
    name: 'Saudi Arabia',
    flag: '🇸🇦',
    currency: 'SAR',
    currencySymbol: 'SAR ',
    baseFee: 225,
    taxRate: 0.15,
    taxName: '15% ZATCA VAT',
    taxDescription: 'Zakat, Tax and Customs Authority Standard Commercial VAT'
  }
];

export function getCountryTaxConfig(code: string): CountryTaxInfo {
  return SUPPORTED_COUNTRIES.find(c => c.code === code) || SUPPORTED_COUNTRIES[0];
}

export function calculateSubscriptionBill(countryCode: string) {
  const country = getCountryTaxConfig(countryCode);
  const baseFee = country.baseFee;
  const taxAmount = Number((baseFee * country.taxRate).toFixed(2));
  const totalAmount = Number((baseFee + taxAmount).toFixed(2));

  return {
    country,
    baseFee,
    taxAmount,
    totalAmount,
    formattedBase: `${country.currencySymbol}${baseFee.toLocaleString()}`,
    formattedTax: `${country.currencySymbol}${taxAmount.toLocaleString()}`,
    formattedTotal: `${country.currencySymbol}${totalAmount.toLocaleString()}`
  };
}
