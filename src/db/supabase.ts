import { createClient } from "@supabase/supabase-js";

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL as string;
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY as string;

// Guard: self-hosted BulkSkart must use the stack ANON_KEY (iss: supabase),
// not a hosted supabase.co project JWT — that returns plain "Unauthorized".
if (
  import.meta.env.PROD &&
  typeof supabaseUrl === 'string' &&
  supabaseUrl.includes('bulkskart.com') &&
  typeof supabaseAnonKey === 'string' &&
  supabaseAnonKey.includes('ewnftvshvsrhawluloty')
) {
  console.error(
    '[BulkSkart] Misconfigured VITE_SUPABASE_ANON_KEY: cloud project key cannot auth against www.bulkskart.com. Rebuild with .env.production.'
  );
}

/**
 * Avoid navigator.locks deadlocks that can hang getSession() forever
 * (all REST calls wait on _getAccessToken → getSession).
 */
const noOpLock = async <R>(_name: string, _acquireTimeout: number, fn: () => Promise<R>): Promise<R> => fn();

export const supabase = createClient(supabaseUrl, supabaseAnonKey, {
  auth: {
    persistSession: true,
    autoRefreshToken: true,
    detectSessionInUrl: true,
    lock: noOpLock,
  },
  global: {
    headers: {
      'X-Client-Info': 'bulkskart-web',
    },
  },
  realtime: {
    params: {
      eventsPerSecond: 2,
    },
  },
});

export { supabaseUrl, supabaseAnonKey };
 