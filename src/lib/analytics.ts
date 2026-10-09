/**
 * Google Tag Manager (GTM-T4HWCGKD) — event tracking wrapper
 *
 * Pushes events to window.dataLayer for Google Tag Manager.
 * Strict production domain gating prevents staging or preview domains from polluting tracking.
 */

const GTM_ID = (import.meta.env.VITE_GTM_ID as string | undefined) || 'GTM-T4HWCGKD';

// Strict domain gating: only track on official production domains
function isAllowedDomain(): boolean {
  if (typeof window === 'undefined') return false;
  const host = window.location.hostname.toLowerCase();
  return host === 'bulkskart.com' || host === 'www.bulkskart.com';
}

// Extend the global Window type to include dataLayer
declare global {
  interface Window {
    dataLayer?: unknown[];
    gtag?: (...args: unknown[]) => void;
  }
}

/** Returns true only when running on the official production domain */
function isReady(): boolean {
  return typeof window !== 'undefined' && isAllowedDomain();
}

// ─── Page view ────────────────────────────────────────────────────────────────

/**
 * Track a virtual page view via GTM dataLayer.
 * Call this on every React Router navigation.
 */
export function trackPageView(path: string, title?: string): void {
  if (!isReady()) return;
  window.dataLayer = window.dataLayer || [];
  window.dataLayer.push({
    event: 'page_view',
    page_path: path,
    page_title: title ?? document.title,
    page_location: window.location.href,
  });
}

// ─── Custom events ────────────────────────────────────────────────────────────

/**
 * Generic event tracker pushing to GTM dataLayer.
 * @param eventName  Event name (snake_case recommended)
 * @param params     Any extra parameters to attach to the event
 */
export function trackEvent(
  eventName: string,
  params: Record<string, unknown> = {}
): void {
  if (!isReady()) return;
  window.dataLayer = window.dataLayer || [];
  window.dataLayer.push({
    event: eventName,
    ...params,
  });
}

// ─── Pre-built business events ────────────────────────────────────────────────

/** Buyer submitted a new bulk RFQ */
export function trackRFQPosted(params: {
  category?: string;
  destination?: string;
  quantity?: number;
  unit?: string;
}): void {
  trackEvent('rfq_posted', {
    event_category: 'engagement',
    category_name: params.category ?? 'uncategorized',
    destination_country: params.destination ?? 'unknown',
    quantity: params.quantity,
    quantity_unit: params.unit,
  });
}

/** User clicked "Contact" on a supplier / product */
export function trackSupplierContact(companySlug: string): void {
  trackEvent('supplier_contact', {
    event_category: 'lead',
    company_slug: companySlug,
  });
}

/** User signed up (buyer or supplier) */
export function trackSignUp(role: 'buyer' | 'supplier'): void {
  trackEvent('sign_up', {
    method: 'email',
    user_role: role,
  });
}

/** User started a subscription checkout */
export function trackSubscriptionStart(planTier: string, price: number): void {
  trackEvent('begin_checkout', {
    event_category: 'monetization',
    plan_tier: planTier,
    value: price,
    currency: 'INR',
  });
}

/** User viewed a product detail page */
export function trackProductView(productSlug: string, productName: string): void {
  trackEvent('view_item', {
    event_category: 'engagement',
    item_id: productSlug,
    item_name: productName,
  });
}

/** User viewed a company/manufacturer profile */
export function trackCompanyView(companySlug: string): void {
  trackEvent('view_company', {
    event_category: 'engagement',
    company_slug: companySlug,
  });
}
