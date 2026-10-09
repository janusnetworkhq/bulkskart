import { useState, useEffect, useCallback } from 'react';
import { useAuth } from '@/contexts/AuthContext';

export interface NotificationPreferences {
  soundEnabled: boolean;
  toastEnabled: boolean;
  rfqAlerts: boolean;
  messageAlerts: boolean;
  quoteAlerts: boolean;
  subscriptionAlerts: boolean;
  orderAlerts: boolean;
}

const DEFAULT_PREFERENCES: NotificationPreferences = {
  soundEnabled: true,
  toastEnabled: true,
  rfqAlerts: true,
  messageAlerts: true,
  quoteAlerts: true,
  subscriptionAlerts: true,
  orderAlerts: true,
};

export function useNotificationPreferences() {
  const { user } = useAuth();
  const storageKey = user ? `bulkskart_notif_prefs_${user.id}` : 'bulkskart_notif_prefs_guest';

  const [prefs, setPrefs] = useState<NotificationPreferences>(() => {
    try {
      const stored = localStorage.getItem(storageKey);
      if (stored) {
        return { ...DEFAULT_PREFERENCES, ...JSON.parse(stored) };
      }
    } catch {
      // fallback
    }
    return DEFAULT_PREFERENCES;
  });

  useEffect(() => {
    try {
      const stored = localStorage.getItem(storageKey);
      if (stored) {
        setPrefs({ ...DEFAULT_PREFERENCES, ...JSON.parse(stored) });
      } else {
        setPrefs(DEFAULT_PREFERENCES);
      }
    } catch {
      setPrefs(DEFAULT_PREFERENCES);
    }
  }, [storageKey]);

  const updatePreferences = useCallback((newPrefs: Partial<NotificationPreferences>) => {
    setPrefs((prev) => {
      const updated = { ...prev, ...newPrefs };
      try {
        localStorage.setItem(storageKey, JSON.stringify(updated));
      } catch (e) {
        console.warn('Failed to save notification preferences:', e);
      }
      return updated;
    });
  }, [storageKey]);

  const isTypeAllowed = useCallback((type: string) => {
    if (type === 'rfq_matched' || type === 'rfq_match') return prefs.rfqAlerts;
    if (type === 'message') return prefs.messageAlerts;
    if (type === 'quote_received' || type === 'quotation') return prefs.quoteAlerts;
    if (type === 'subscription') return prefs.subscriptionAlerts;
    if (type === 'order_status' || type === 'deal_status') return prefs.orderAlerts;
    return true;
  }, [prefs]);

  return {
    prefs,
    updatePreferences,
    isTypeAllowed,
  };
}
