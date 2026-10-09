import React, { createContext, useContext, useEffect, useState } from 'react';
import type { User, Session } from '@supabase/supabase-js';
import { supabase } from '@/db/supabase';
import type { Profile, Company, BuyerProfile, Subscription } from '@/types/types';

interface AuthContextValue {
  user: User | null;
  session: Session | null;
  profile: Profile | null;
  company: Company | null;
  buyerProfile: BuyerProfile | null;
  subscription: Subscription | null;
  isPaidSubscriber: boolean;
  loading: boolean;
  signIn: (email: string, password: string) => Promise<{ error: string | null }>;
  signUp: (email: string, password: string, fullName: string, role: 'buyer' | 'supplier') => Promise<{ error: string | null; user?: User | null }>;
  signOut: () => Promise<void>;
  refreshProfile: () => Promise<void>;
  refreshSubscription: () => Promise<void>;
}

const AuthContext = createContext<AuthContextValue | undefined>(undefined);

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [session, setSession] = useState<Session | null>(null);
  const [profile, setProfile] = useState<Profile | null>(null);
  const [company, setCompany] = useState<Company | null>(null);
  const [buyerProfile, setBuyerProfile] = useState<BuyerProfile | null>(null);
  const [subscription, setSubscription] = useState<Subscription | null>(null);
  const [isPaidSubscriber, setIsPaidSubscriber] = useState(false);
  const [loading, setLoading] = useState(true);

  const fetchSubscription = async (companyId?: string | null, userRole?: string) => {
    if (userRole === 'admin') {
      setIsPaidSubscriber(true);
      return;
    }
    if (!companyId) {
      setSubscription(null);
      setIsPaidSubscriber(false);
      return;
    }
    try {
      const { data: subData } = await supabase
        .from('subscriptions')
        .select('*')
        .eq('company_id', companyId)
        .eq('status', 'active')
        .maybeSingle();

      if (subData) {
        setSubscription(subData as Subscription);
        setIsPaidSubscriber(true);
      } else {
        setSubscription(null);
        setIsPaidSubscriber(false);
      }
    } catch (e) {
      console.warn('Failed to fetch subscription:', e);
      setSubscription(null);
      setIsPaidSubscriber(false);
    }
  };

  const fetchProfile = async (userId: string) => {
    const { data: profileData } = await supabase
      .from('profiles')
      .select('*')
      .eq('id', userId)
      .maybeSingle();
    setProfile(profileData);

    let compData: Company | null = null;
    if (profileData?.role === 'supplier' || profileData?.role === 'admin') {
      const { data } = await supabase
        .from('companies')
        .select('*')
        .eq('owner_id', userId)
        .maybeSingle();
      compData = data;
      setCompany(compData);
      await fetchSubscription(compData?.id, profileData?.role);
    } else {
      setSubscription(null);
      setIsPaidSubscriber(false);
    }

    if (profileData?.role === 'buyer') {
      const { data: bp } = await supabase
        .from('buyer_profiles')
        .select('*')
        .eq('user_id', userId)
        .maybeSingle();
      setBuyerProfile(bp);
    }
  };

  const refreshSubscription = async () => {
    if (company?.id) {
      await fetchSubscription(company.id, profile?.role);
    } else if (profile?.role === 'admin') {
      setIsPaidSubscriber(true);
    }
  };

  const refreshProfile = async () => {
    if (user) await fetchProfile(user.id);
  };

  useEffect(() => {
    let isMounted = true;

    // Failsafe timeout: never allow the app to stay in loading state beyond 3 seconds
    // even if network requests to Supabase are stalled or offline
    const safetyTimer = setTimeout(() => {
      if (isMounted) {
        setLoading(false);
      }
    }, 3000);

    supabase.auth.getSession()
      .then(({ data: { session: s } }) => {
        if (!isMounted) return;
        setSession(s);
        setUser(s?.user ?? null);
        if (s?.user) {
          fetchProfile(s.user.id)
            .catch(() => {})
            .finally(() => {
              if (isMounted) {
                clearTimeout(safetyTimer);
                setLoading(false);
              }
            });
        } else {
          clearTimeout(safetyTimer);
          setLoading(false);
        }
      })
      .catch((err) => {
        console.warn('Auth session initialization failed:', err);
        if (isMounted) {
          clearTimeout(safetyTimer);
          setLoading(false);
        }
      });

    const { data: { subscription: authListener } } = supabase.auth.onAuthStateChange(async (_event, s) => {
      if (!isMounted) return;
      // Immediately reset previous account state to prevent cross-account leak
      setProfile(null);
      setCompany(null);
      setBuyerProfile(null);
      setSubscription(null);
      setIsPaidSubscriber(false);

      setSession(s);
      setUser(s?.user ?? null);
      if (s?.user) {
        await fetchProfile(s.user.id).catch(() => {});
      }
    });

    return () => {
      isMounted = false;
      clearTimeout(safetyTimer);
      authListener.unsubscribe();
    };
  }, []);

  const signIn = async (email: string, password: string): Promise<{ error: string | null }> => {
    try {
      const cleanEmail = email.trim().toLowerCase();
      if (!cleanEmail) {
        return { error: 'Please enter your email address.' };
      }
      if (!password) {
        return { error: 'Please enter your password.' };
      }

      const { data, error } = await supabase.auth.signInWithPassword({
        email: cleanEmail,
        password,
      });

      if (error) {
        if (
          error.message.includes('Invalid login credentials') ||
          error.message.includes('invalid_credentials')
        ) {
          return {
            error: 'Invalid email or password. Please verify your credentials or click "Forgot password?" to reset.',
          };
        }
        if (error.message.includes('Email not confirmed')) {
          return {
            error: 'Please verify your email address before signing in, or use password reset.',
          };
        }
        return { error: error.message };
      }

      if (data?.user) {
        setSession(data.session);
        setUser(data.user);
        await fetchProfile(data.user.id).catch(() => {});
      }

      return { error: null };
    } catch (e: any) {
      return { error: e?.message || 'Login failed. Please check your network connection.' };
    }
  };

  const signUp = async (
    email: string,
    password: string,
    fullName: string,
    role: 'buyer' | 'supplier'
  ): Promise<{ error: string | null; user?: User | null }> => {
    try {
      const cleanEmail = email.trim().toLowerCase();
      const cleanName = fullName.trim();

      if (!cleanEmail) {
        return { error: 'Email address is required.' };
      }
      if (!password || password.length < 8) {
        return { error: 'Password must be at least 8 characters long.' };
      }

      // 1. Force clear previous session before registering a new user to prevent cross-account leak
      await signOut();

      const { data, error } = await supabase.auth.signUp({
        email: cleanEmail,
        password,
        options: {
          data: {
            full_name: cleanName || cleanEmail.split('@')[0],
            role,
          },
        },
      });

      if (error) {
        if (
          error.message.includes('already registered') ||
          error.message.includes('User already registered')
        ) {
          return {
            error: 'An account with this email address already exists. Please sign in instead.',
          };
        }
        return { error: error.message };
      }

      // If email is already registered, Supabase returns user with empty identities array
      if (data.user && data.user.identities && data.user.identities.length === 0) {
        return {
          error: 'An account with this email address already exists. Please sign in instead.',
        };
      }

      if (data.user) {
        // Fallback upsert user profile (the DB trigger on_auth_user_created also handles this)
        try {
          await supabase.from('profiles').upsert({
            id: data.user.id,
            email: cleanEmail,
            full_name: cleanName || cleanEmail.split('@')[0],
            role,
            status: 'active',
          });
        } catch {
          // Trigger handles profile creation if client RLS restricts
        }

        // If auto-session was not established, immediately sign in with the new credentials
        if (!data.session) {
          const { data: sData } = await supabase.auth.signInWithPassword({
            email: cleanEmail,
            password,
          });
          if (sData?.session) {
            setSession(sData.session);
            setUser(sData.user);
          }
        } else {
          setSession(data.session);
          setUser(data.user);
        }

        // Fetch fresh profile state for the newly registered user
        await fetchProfile(data.user.id).catch(() => {});

        return { error: null, user: data.user };
      }

      return { error: null };
    } catch (e: any) {
      return { error: e?.message || 'Failed to complete registration' };
    }
  };

  const signOut = async () => {
    // 1. Clear session & account-scoped caches while preserving app theme
    try {
      const keysToRemove: string[] = [];
      for (let i = 0; i < localStorage.length; i++) {
        const k = localStorage.key(i);
        if (
          k &&
          k !== 'bulkskart-theme' &&
          (k.startsWith('bulkskart_') ||
            k.startsWith('sb-') ||
            k.includes('supabase') ||
            k.includes('onboarding') ||
            k.includes('inquiry'))
        ) {
          keysToRemove.push(k);
        }
      }
      keysToRemove.forEach((k) => {
        try {
          localStorage.removeItem(k);
        } catch {
          // ignore
        }
      });
    } catch (e) {
      console.warn('Error clearing localStorage during signOut:', e);
    }

    // 2. Invoke Supabase signOut safely
    try {
      await supabase.auth.signOut({ scope: 'local' });
    } catch (err) {
      console.warn('Supabase auth.signOut warning (proceeding with local cleanup):', err);
    } finally {
      // 3. ALWAYS clear local state so the UI and Header immediately update
      setProfile(null);
      setCompany(null);
      setBuyerProfile(null);
      setSubscription(null);
      setIsPaidSubscriber(false);
      setUser(null);
      setSession(null);
    }
  };

  return (
    <AuthContext.Provider
      value={{
        user,
        session,
        profile,
        company,
        buyerProfile,
        subscription,
        isPaidSubscriber,
        loading,
        signIn,
        signUp,
        signOut,
        refreshProfile,
        refreshSubscription,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error('useAuth must be used within AuthProvider');
  return ctx;
}
