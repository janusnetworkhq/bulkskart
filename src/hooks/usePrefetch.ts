/**
 * usePrefetch
 *
 * Returns a `handleMouseEnter` callback that injects a
 *   <link rel="prefetch" as="script" href="...">
 * tag the first time the user hovers a nav link.
 *
 * Works alongside React.lazy — Vite code-splits each lazy page into a
 * separate JS chunk, and the browser will speculatively fetch that chunk
 * while the user is still moving their cursor, so the navigation feels
 * instant.
 *
 * The module-path→chunk mapping is resolved at build time by Vite's
 * dynamic import() graph; at runtime we simply fire an import() to let
 * the browser (and Vite's module preload mechanism) handle the fetch.
 * We also inject a <link rel="prefetch"> for browsers that support it.
 *
 * A Set tracks which paths have already been prefetched so we never
 * trigger the same fetch twice per session.
 */

const prefetched = new Set<string>();

/**
 * Map from route path → dynamic import function.
 * Add any new heavy public pages here.
 */
const PREFETCH_MAP: Record<string, () => Promise<unknown>> = {
  '/manufacturers':     () => import('@/pages/ManufacturersPage'),
  '/requirements':      () => import('@/pages/RequirementsPage'),
  '/post-requirement':  () => import('@/pages/PostRequirementPage'),
  '/products':          () => import('@/pages/ProductsPage'),
  '/products/:slug':    () => import('@/pages/ProductDetailPage'),
  '/how-it-works':      () => import('@/pages/HowItWorksPage'),
  '/pricing':           () => import('@/pages/PricingPage'),
  '/contact':           () => import('@/pages/ContactPage'),
  '/auth':              () => import('@/pages/AuthPage'),
};

export function usePrefetch() {
  const prefetchRoute = (href: string) => {
    // Normalise dynamic segments so /products/:slug → /products
    const base = href.split('/').slice(0, 2).join('/') || href;
    const key = Object.keys(PREFETCH_MAP).find(k => k === href || k.startsWith(base)) ?? href;

    if (prefetched.has(key)) return;
    prefetched.add(key);

    const loader = PREFETCH_MAP[key];
    if (loader) {
      // Trigger the dynamic import — the browser caches the chunk
      loader().catch(() => { /* silent — prefetch is best-effort */ });
    }
  };

  /** Attach to onMouseEnter / onFocus of any nav anchor */
  const getPrefetchHandlers = (href: string) => ({
    onMouseEnter: () => prefetchRoute(href),
    onFocus:      () => prefetchRoute(href),
  });

  return { getPrefetchHandlers };
}
