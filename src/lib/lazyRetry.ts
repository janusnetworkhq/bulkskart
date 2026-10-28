import { lazy, type ComponentType, type LazyExoticComponent } from 'react';
import { isChunkLoadError, reloadForStaleChunk } from '@/lib/chunkRecovery';

/** React.lazy with one retry, then hard reload on stale chunks. */
export function lazyRetry<T extends ComponentType<any>>(
  factory: () => Promise<{ default: T }>,
): LazyExoticComponent<T> {
  return lazy(async () => {
    try {
      return await factory();
    } catch (first) {
      if (!isChunkLoadError(first)) throw first;
      // Brief pause then retry (in case of transient network blip)
      await new Promise((r) => setTimeout(r, 400));
      try {
        return await factory();
      } catch (second) {
        if (isChunkLoadError(second)) {
          reloadForStaleChunk('lazyRetry');
        }
        throw second;
      }
    }
  });
}
