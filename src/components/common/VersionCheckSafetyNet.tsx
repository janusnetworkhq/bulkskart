import { useEffect, useRef } from 'react';

interface VersionPayload {
  version: string;
  buildTime: string;
  gitCommit?: string;
}

// Baked at build — must change on every deploy (also written to /version.json)
import bakedVersion from '@/version.json';

const CURRENT_APP_VERSION = `${bakedVersion.version}|${bakedVersion.buildTime}`;

export default function VersionCheckSafetyNet() {
  const currentVersionRef = useRef<string | null>(CURRENT_APP_VERSION);
  const isCheckingRef = useRef(false);

  const checkVersion = async () => {
    if (isCheckingRef.current) return;
    isCheckingRef.current = true;

    try {
      // Use timestamp query param and cache: 'no-store' to guarantee fresh origin response
      const response = await fetch(`/version.json?_t=${Date.now()}`, {
        cache: 'no-store',
        headers: {
          'Cache-Control': 'no-cache, no-store, must-revalidate',
          Pragma: 'no-cache',
        },
      });

      if (!response.ok) {
        isCheckingRef.current = false;
        return;
      }

      const data: VersionPayload = await response.json();
      const serverVersion = `${data.version || ''}|${data.buildTime || ''}`;

      if (!currentVersionRef.current) {
        currentVersionRef.current = serverVersion;
      } else if (serverVersion && serverVersion !== '|' && serverVersion !== currentVersionRef.current) {
        console.warn(`[BulkSkart VersionCheck] New version detected: ${serverVersion} (current: ${currentVersionRef.current}). Reloading page...`);
        // Clean up service workers and caches before hard reloading
        if ('serviceWorker' in navigator) {
          try {
            const registrations = await navigator.serviceWorker.getRegistrations();
            await Promise.all(registrations.map(r => r.unregister()));
          } catch {}
        }
        if ('caches' in window) {
          try {
            const keys = await caches.keys();
            await Promise.all(keys.map(k => caches.delete(k)));
          } catch {}
        }
        window.location.reload();
      }
    } catch {
      // Offline or network error; safely ignore
    } finally {
      isCheckingRef.current = false;
    }
  };

  useEffect(() => {
    // Initial check after 5 seconds
    const initialTimer = setTimeout(() => {
      checkVersion();
    }, 5000);

    // Periodic check every 60 seconds
    const interval = setInterval(() => {
      checkVersion();
    }, 60000);

    // Tab focus / visibility change check
    const handleVisibilityChange = () => {
      if (document.visibilityState === 'visible') {
        checkVersion();
      }
    };

    window.addEventListener('focus', checkVersion);
    document.addEventListener('visibilitychange', handleVisibilityChange);

    return () => {
      clearTimeout(initialTimer);
      clearInterval(interval);
      window.removeEventListener('focus', checkVersion);
      document.removeEventListener('visibilitychange', handleVisibilityChange);
    };
  }, []);

  return null;
}
