/** Detect Vite/React lazy-chunk load failures after a redeploy. */
export function isChunkLoadError(error: unknown): boolean {
  const msg = error instanceof Error ? error.message : String(error ?? '');
  return (
    /Failed to fetch dynamically imported module/i.test(msg) ||
    /error loading dynamically imported module/i.test(msg) ||
    /Importing a module script failed/i.test(msg) ||
    /Loading chunk [\w-]+ failed/i.test(msg) ||
    /ChunkLoadError/i.test(msg)
  );
}

const RELOAD_KEY = 'bulkskart_chunk_reload';

/** Hard-reload once after a stale chunk; avoids infinite loops. */
export function reloadForStaleChunk(reason = 'chunk'): boolean {
  try {
    const last = sessionStorage.getItem(RELOAD_KEY);
    const now = Date.now();
    if (last && now - Number(last) < 15_000) {
      return false;
    }
    sessionStorage.setItem(RELOAD_KEY, String(now));
  } catch {
    // sessionStorage unavailable — still reload once via URL bust
  }

  console.warn(`[BulkSkart] Stale asset (${reason}); reloading…`);

  const url = new URL(window.location.href);
  url.searchParams.set('_v', String(Date.now()));
  window.location.replace(url.toString());
  return true;
}

/** Install global listeners for Vite preload / dynamic import failures. */
export function installChunkRecovery(): void {
  if (typeof window === 'undefined') return;

  window.addEventListener('vite:preloadError', (event) => {
    event.preventDefault();
    reloadForStaleChunk('vite:preloadError');
  });

  window.addEventListener('unhandledrejection', (event) => {
    if (isChunkLoadError(event.reason)) {
      event.preventDefault();
      reloadForStaleChunk('unhandledrejection');
    }
  });
}
