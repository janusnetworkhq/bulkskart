/**
 * LiveBuyerOrderAlert.tsx
 *
 * Real-time floating social proof & buyer activity popup:
 * "Wanted bulk order from India posted by [Name of the person]"
 *
 * Compact Dark Glassmorphism Corner Widget (Non-blocking, Non-fullscreen):
 * - Small footprint: ~380px width docked at bottom-left corner
 * - Glowing multi-color neon border (orange to violet to blue)
 * - Header with LIVE RFQ status, posted time, auto-refresh 1m counter, minimize & close buttons
 * - Segmented 5-step progress indicator and circular prev/next navigation
 * - Compact layout: Product thumbnail on left, verified buyer info on right
 * - Highlighted RFQ description in a compact quote card
 * - 6 organized micro information boxes (Qty, Type, Req By, Price, Specs, Location)
 * - Category, Bulk Order, and Subscriber Eligibility badges
 * - Bottom CTA buttons: View RFQ and Send Quote with working subscription gating
 */

import React, { useState, useEffect, useRef, useCallback } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  X, Zap, Lock, ArrowRight, CheckCircle2, Building2, MapPin,
  ChevronLeft, ChevronRight, Volume2, VolumeX,
  Minimize2, Clock, RefreshCw, Eye, MessageSquareQuote,
  Box, ListFilter, CalendarDays, IndianRupee, FileText, Truck,
  EyeOff
} from 'lucide-react';
import { Button } from '@/components/ui/button';
import { useAuth } from '@/contexts/AuthContext';
import { checkDirectMessageQuota, checkSupplierPaidSubscription } from '@/lib/api';
import SubscribeToContactDialog, { type SubscriptionReason } from '@/components/common/SubscribeToContactDialog';
import {
  getIndianBulkOrder,
  getRandomIndianBulkOrder,
  TOTAL_INDIAN_BULK_ORDERS,
  type IndianBulkOrderAlert
} from '@/lib/bulkOrdersIndiaDataset';
import SupplierRespondDialog from '@/components/common/SupplierRespondDialog';
import type { Requirement } from '@/types/types';
import { toast } from 'sonner';

export type AlertAppearance = 'modal' | 'pill';
export type AlertFrequency = '1m' | '2m' | '30s' | '15s';

const FREQUENCY_DURATIONS: Record<AlertFrequency, number> = {
  '1m': 60000,
  '2m': 120000,
  '30s': 30000,
  '15s': 15000,
};

// Curated high-res Indian professional buyer avatars
const INDIAN_BUYER_AVATARS = [
  'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=120&auto=format&fit=crop&q=80',
  'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=120&auto=format&fit=crop&q=80',
  'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=120&auto=format&fit=crop&q=80',
  'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=120&auto=format&fit=crop&q=80',
  'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=120&auto=format&fit=crop&q=80',
  'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=120&auto=format&fit=crop&q=80',
  'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=120&auto=format&fit=crop&q=80',
  'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=120&auto=format&fit=crop&q=80',
];

// Helper to extract clean product type
function extractProductType(order: IndianBulkOrderAlert): string {
  const msg = (order.message + ' ' + order.title).toLowerCase();
  if (msg.includes('forklift')) return 'Electric Forklift';
  if (msg.includes('grinder') || msg.includes('cnc')) return 'CNC Grinder';
  if (msg.includes('truck') || msg.includes('trailer')) return 'Food Truck';
  if (msg.includes('steel') || msg.includes('rebar') || msg.includes('coil')) return 'Structural Steel';
  if (msg.includes('carton') || msg.includes('box') || msg.includes('jute')) return 'Corrugated Boxes';
  if (msg.includes('pipe') || msg.includes('valve')) return 'Valves & Pipes';
  if (msg.includes('solar') || msg.includes('panel')) return 'Solar Modules';
  if (msg.includes('fabric') || msg.includes('cotton') || msg.includes('silk')) return 'Textile Fabrics';
  if (msg.includes('spice') || msg.includes('grain') || msg.includes('rice')) return 'Agro Grains';
  if (msg.includes('chemical') || msg.includes('polymer')) return 'Polymers';

  return order.category.split('&')[0].trim() || 'Machinery';
}

export default function LiveBuyerOrderAlert() {
  const { user, profile, company } = useAuth();
  const navigate = useNavigate();

  // Mode: 'modal' (compact card) or 'pill' (tiny bar)
  const [appearance, setAppearance] = useState<AlertAppearance>(() => {
    try {
      const saved = localStorage.getItem('trade_buyer_alert_appearance');
      if (saved === 'modal' || saved === 'pill') return saved as AlertAppearance;
    } catch {}
    return 'modal';
  });

  const [frequency] = useState<AlertFrequency>('1m');
  const [soundEnabled, setSoundEnabled] = useState<boolean>(false);

  // Alert State
  const [currentIndex, setCurrentIndex] = useState(() => Math.floor(Math.random() * TOTAL_INDIAN_BULK_ORDERS));
  const [currentOrder, setCurrentOrder] = useState<IndianBulkOrderAlert>(() => getRandomIndianBulkOrder('All Categories'));
  const [isVisible, setIsVisible] = useState(true);
  const [isDismissed, setIsDismissed] = useState<boolean>(() => {
    try {
      return (
        sessionStorage.getItem('trade_hide_buyer_alerts_session') === 'true' ||
        localStorage.getItem('trade_hide_buyer_alerts_forever') === 'true'
      );
    } catch {
      return false;
    }
  });

  const [showCloseMenu, setShowCloseMenu] = useState(false);
  const [isHovered, setIsHovered] = useState(false);
  const [refreshCountdown, setRefreshCountdown] = useState(60);

  // Dialog states for quoting
  const [subDialogOpen, setSubDialogOpen] = useState(false);
  const [subDialogReason, setSubDialogReason] = useState<SubscriptionReason>('no_subscription');
  const [quoteDialogOpen, setQuoteDialogOpen] = useState(false);
  const [activeReqForQuote, setActiveReqForQuote] = useState<Requirement | null>(null);

  // Audio Chime Synthesizer via Web Audio API
  const playChime = useCallback(() => {
    if (!soundEnabled) return;
    try {
      const AudioCtx = window.AudioContext || (window as unknown as { webkitAudioContext: typeof AudioContext }).webkitAudioContext;
      if (!AudioCtx) return;
      const ctx = new AudioCtx();
      const osc = ctx.createOscillator();
      const gain = ctx.createGain();

      osc.type = 'sine';
      osc.frequency.setValueAtTime(880, ctx.currentTime);
      osc.frequency.exponentialRampToValueAtTime(1108.73, ctx.currentTime + 0.15);

      gain.gain.setValueAtTime(0.04, ctx.currentTime);
      gain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + 0.35);

      osc.connect(gain);
      gain.connect(ctx.destination);

      osc.start();
      osc.stop(ctx.currentTime + 0.35);
    } catch {}
  }, [soundEnabled]);

  // Navigate to specific index
  const goToOrder = useCallback((newIdx: number) => {
    setIsVisible(false);
    setTimeout(() => {
      const normalizedIdx = (newIdx + TOTAL_INDIAN_BULK_ORDERS) % TOTAL_INDIAN_BULK_ORDERS;
      setCurrentIndex(normalizedIdx);
      const nextOrder = getIndianBulkOrder(normalizedIdx);
      setCurrentOrder(nextOrder);
      setIsVisible(true);
      setRefreshCountdown(60);
      playChime();
    }, 120);
  }, [playChime]);

  // Auto-cycling timer (1 minute rotation)
  useEffect(() => {
    if (isDismissed || isHovered || showCloseMenu) return;

    const intervalTime = FREQUENCY_DURATIONS[frequency] || 60000;
    const intervalTimer = setInterval(() => {
      if (typeof document !== 'undefined' && !document.hidden) {
        goToOrder(currentIndex + 1);
      }
    }, intervalTime);

    // Countdown second ticker
    const countdownTimer = setInterval(() => {
      setRefreshCountdown(prev => (prev <= 1 ? 60 : prev - 1));
    }, 1000);

    return () => {
      clearInterval(intervalTimer);
      clearInterval(countdownTimer);
    };
  }, [isDismissed, isHovered, showCloseMenu, frequency, currentIndex, goToOrder]);

  // Close for this session
  const handleCloseSession = () => {
    try {
      sessionStorage.setItem('trade_hide_buyer_alerts_session', 'true');
    } catch {}
    setIsVisible(false);
    setIsDismissed(true);
    setShowCloseMenu(false);
    toast.info('Live RFQ alert closed for this session. Restore anytime via bottom-left button.', {
      duration: 4000,
    });
  };

  // Close permanently
  const handleClosePermanent = () => {
    try {
      localStorage.setItem('trade_hide_buyer_alerts_forever', 'true');
      sessionStorage.setItem('trade_hide_buyer_alerts_session', 'true');
    } catch {}
    setIsVisible(false);
    setIsDismissed(true);
    setShowCloseMenu(false);
    toast.success('Live RFQ alerts disabled. You can restore them anytime from the bottom-left button.', {
      duration: 4000,
    });
  };

  // Minimize to corner pill
  const handleMinimize = () => {
    setAppearance('pill');
    try {
      localStorage.setItem('trade_buyer_alert_appearance', 'pill');
    } catch {}
    toast.info('Popup minimized to corner pill.', { duration: 2500 });
  };

  // Restore popups
  const handleRestore = () => {
    try {
      sessionStorage.removeItem('trade_hide_buyer_alerts_session');
      localStorage.removeItem('trade_hide_buyer_alerts_forever');
    } catch {}
    setIsDismissed(false);
    setAppearance('modal');
    setIsVisible(true);
    setShowCloseMenu(false);
    goToOrder(currentIndex + 1);
  };

  // Handle Send Quote click with subscription validation
  const handleActionClick = async () => {
    if (!user || !profile) {
      setSubDialogReason('not_logged_in');
      setSubDialogOpen(true);
      return;
    }

    if (!company) {
      setSubDialogReason('not_registered_business');
      setSubDialogOpen(true);
      return;
    }

    const subCheck = await checkSupplierPaidSubscription(company.id, company);
    if (!subCheck.allowed) {
      setSubDialogReason(subCheck.reason);
      setSubDialogOpen(true);
      return;
    }

    const quota = await checkDirectMessageQuota(company.id, company);
    if (quota !== 'ok') {
      setSubDialogReason(quota);
      setSubDialogOpen(true);
      return;
    }

    const reqObj: Requirement = {
      id: currentOrder.id,
      buyer_id: 'verified-buyer-india',
      category_id: null,
      title: currentOrder.title,
      description: currentOrder.message,
      specifications: `${currentOrder.attribute} • Urgent procurement from verified buyer ${currentOrder.buyerName} (${currentOrder.companyName}, ${currentOrder.city})`,
      quantity: parseInt(currentOrder.quantity.replace(/\D/g, '') || '1000', 10),
      quantity_unit: currentOrder.quantity.replace(/[\d,]/g, '').trim() || 'Units',
      budget_min: null,
      budget_max: null,
      currency: 'INR',
      destination_city: currentOrder.city.split(',')[0].trim(),
      destination_country: 'India',
      status: 'active',
      quote_count: 0,
      view_count: 18,
      deadline: null,
      attachment_url: null,
      expires_at: null,
      is_verified_buyer: true,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    };

    setActiveReqForQuote(reqObj);
    setQuoteDialogOpen(true);
  };

  const avatarUrl = INDIAN_BUYER_AVATARS[currentIndex % INDIAN_BUYER_AVATARS.length];
  const productType = extractProductType(currentOrder);
  const activeStep = (currentIndex % 5) + 1;

  // Never render floating live order alerts on full-page forms or authentication
  const isExcludedPage =
    location.pathname.includes('/business-setup') ||
    location.pathname.includes('/onboarding') ||
    location.pathname.includes('/post-requirement') ||
    location.pathname.includes('/negotiation') ||
    location.pathname.includes('/auth') ||
    location.pathname.includes('/settings');

  if (isExcludedPage) {
    return null;
  }

  // Render dismissed restore button docked cleanly at bottom-left
  if (isDismissed) {
    return (
      <div className="fixed bottom-24 sm:bottom-28 left-2 sm:left-3 z-30 animate-fade-in pointer-events-auto flex items-center gap-1">
        <button
          onClick={handleRestore}
          className="flex items-center gap-1.5 bg-[#0c121e]/95 hover:bg-[#121927] border border-slate-700/80 backdrop-blur-md rounded-full px-2.5 py-1 shadow-[0_4px_16px_rgba(0,0,0,0.5)] text-white text-[11px] font-bold transition-all hover:scale-105 active:scale-95 shrink-0"
        >
          <span className="flex items-center gap-1 text-white font-bold">
            <Zap className="w-3 h-3 text-amber-400 fill-amber-400 shrink-0" />
            <span className="whitespace-nowrap">Live RFQs</span>
          </span>
          <span className="text-slate-600 font-light">|</span>
          <span className="inline-flex items-center gap-0.5 text-[10px] font-bold text-white bg-gradient-to-r from-[#FF5A00] to-[#FF4500] px-2 py-0.5 rounded-full shadow-sm">
            <span>Show</span>
            <ChevronRight className="w-2.5 h-2.5" />
          </span>
        </button>
        <button
          onClick={() => {
            try {
              sessionStorage.setItem('hide_live_buyer_alert_session', 'true');
            } catch {}
            setIsDismissed(true);
          }}
          className="w-5 h-5 rounded-full bg-slate-900/90 hover:bg-slate-800 border border-slate-700 text-slate-400 hover:text-white flex items-center justify-center text-[10px] transition-colors"
          title="Hide RFQs badge"
        >
          <X className="w-2.5 h-2.5" />
        </button>
      </div>
    );
  }

  // Render Minimized Pill Mode - docked cleanly at bottom-left
  if (appearance === 'pill') {
    return (
      <div className="fixed bottom-24 sm:bottom-28 left-2 sm:left-3 z-30 animate-fade-in pointer-events-auto">
        <div className="flex items-center gap-2 bg-[#0c121e]/95 border border-slate-700/80 backdrop-blur-md rounded-full px-2.5 py-1 shadow-[0_4px_16px_rgba(0,0,0,0.5)] text-white">
          <span className="flex items-center gap-1 text-white font-bold text-[11px]">
            <Zap className="w-3 h-3 text-amber-400 fill-amber-400 shrink-0" />
            <span className="whitespace-nowrap">Live RFQs</span>
          </span>
          <span className="text-slate-600 font-light">|</span>
          <button
            onClick={() => {
              setAppearance('modal');
              try {
                localStorage.setItem('trade_buyer_alert_appearance', 'modal');
              } catch {}
            }}
            className="inline-flex items-center gap-0.5 text-[10px] font-bold text-white bg-gradient-to-r from-[#FF5A00] to-[#FF4500] hover:from-[#ff6b1a] hover:to-[#e04500] px-2 py-0.5 rounded-full transition-all shadow-sm active:scale-95"
            title="Expand Live RFQ popup"
          >
            <span>Show</span>
            <ChevronRight className="w-2.5 h-2.5" />
          </button>
          <button
            onClick={handleCloseSession}
            className="w-4 h-4 rounded-full hover:bg-slate-800 flex items-center justify-center text-slate-400 hover:text-white shrink-0 ml-0.5 transition-colors"
            title="Dismiss alert"
            aria-label="Dismiss alert"
          >
            <X className="w-3 h-3" />
          </button>
        </div>
      </div>
    );
  }

  // Render Compact Dark Glassmorphism Corner Widget (Non-blocking, elevated on mobile)
  return (
    <>
      <div className="fixed bottom-20 sm:bottom-4 left-3 sm:left-4 z-30 w-[calc(100vw-1.5rem)] sm:w-[380px] md:w-[395px] pointer-events-auto animate-fade-in">
        {/* Glowing Multi-Color Neon Border Container */}
        <div
          onMouseEnter={() => setIsHovered(true)}
          onMouseLeave={() => setIsHovered(false)}
          className={`relative w-full rounded-[20px] p-[1.5px] bg-gradient-to-b from-[#FF5A00] via-[#8B5CF6]/50 to-[#3B82F6]/60 shadow-[0_0_25px_rgba(255,90,0,0.32),0_0_50px_rgba(59,130,246,0.2),0_15px_40px_rgba(0,0,0,0.85)] transition-all duration-300 ${
            isVisible ? 'opacity-100 scale-100' : 'opacity-0 scale-95 pointer-events-none'
          }`}
        >
          {/* Inner Dark Glass Container */}
          <div className="relative rounded-[18.5px] bg-[#070B13] p-3 sm:p-3.5 text-white overflow-hidden shadow-2xl border border-white/5 max-h-[85vh] overflow-y-auto">
            {/* Subtle background ambient glow */}
            <div className="absolute -top-24 -left-24 w-48 h-48 rounded-full bg-[#FF5A00]/10 blur-2xl pointer-events-none" />
            <div className="absolute -bottom-24 -right-24 w-48 h-48 rounded-full bg-[#3B82F6]/10 blur-2xl pointer-events-none" />

            {/* ── Header Row ────────────────────────────────────────────── */}
            <div className="flex items-center justify-between gap-1.5 pb-2 border-b border-slate-800/80">
              {/* Left: LIVE RFQ Status & Time */}
              <div className="flex items-center gap-1.5">
                <span className="relative flex h-2 w-2">
                  <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-emerald-400 opacity-75" />
                  <span className="relative inline-flex rounded-full h-2 w-2 bg-emerald-500 shadow-[0_0_6px_#10B981]" />
                </span>
                <span className="text-xs sm:text-sm font-black tracking-wide text-white">LIVE RFQ</span>
                <span className="text-slate-600 font-light mx-0.5">|</span>
                <span className="text-[11px] font-medium text-slate-300">Just Now</span>
              </div>

              {/* Right: Auto-Refresh Indicator & Action Controls */}
              <div className="flex items-center gap-1.5">
                <div
                  className="flex items-center gap-1 text-[10px] font-semibold text-[#FF6B00] bg-[#FF5A00]/10 px-2 py-0.5 rounded-full border border-[#FF5A00]/20"
                  title={`Refreshing in ${refreshCountdown}s`}
                >
                  <RefreshCw className="w-2.5 h-2.5 animate-spin text-[#FF6B00]" style={{ animationDuration: '4s' }} />
                  <span className="font-mono">1m</span>
                </div>

                {/* Sound Chime Toggle */}
                <button
                  type="button"
                  onClick={() => setSoundEnabled(!soundEnabled)}
                  className={`w-6 h-6 rounded-full border flex items-center justify-center transition-colors ${
                    soundEnabled
                      ? 'bg-amber-500/20 border-amber-500/40 text-amber-400'
                      : 'bg-slate-800/80 border-slate-700/80 text-slate-400 hover:text-white'
                  }`}
                  title={soundEnabled ? 'Mute alert chime' : 'Enable audio alert chime'}
                  aria-label={soundEnabled ? 'Mute chime' : 'Enable chime'}
                >
                  {soundEnabled ? <Volume2 className="w-3 h-3" /> : <VolumeX className="w-3 h-3" />}
                </button>

                {/* Minimize to Corner Pill */}
                <button
                  type="button"
                  onClick={handleMinimize}
                  className="w-6 h-6 rounded-full bg-slate-800/80 border border-slate-700/80 hover:bg-slate-700 flex items-center justify-center text-slate-300 hover:text-white transition-colors"
                  title="Minimize to corner pill"
                  aria-label="Minimize popup"
                >
                  <Minimize2 className="w-3 h-3" />
                </button>

                {/* Close Button */}
                <button
                  type="button"
                  onClick={() => setShowCloseMenu(true)}
                  className="w-6 h-6 rounded-full bg-slate-800/80 border border-slate-700/80 hover:bg-slate-700 flex items-center justify-center text-slate-300 hover:text-white transition-colors"
                  title="Close popup"
                  aria-label="Close popup"
                >
                  <X className="w-3 h-3" />
                </button>
              </div>
            </div>

            {/* Close Options Overlay */}
            {showCloseMenu && (
              <div className="absolute inset-0 z-40 bg-[#070B13]/98 rounded-[18px] p-3.5 flex flex-col justify-between backdrop-blur-xl border border-slate-700/80 animate-fade-in text-left">
                <div>
                  <div className="flex items-center justify-between mb-2">
                    <div className="flex items-center gap-1.5 text-xs font-bold text-white">
                      <EyeOff className="w-3.5 h-3.5 text-[#FF5A00]" />
                      <span>Alert Preferences</span>
                    </div>
                    <button
                      onClick={() => setShowCloseMenu(false)}
                      aria-label="Back to RFQ"
                      className="w-6 h-6 rounded-full bg-slate-800 hover:bg-slate-700 flex items-center justify-center text-slate-300 hover:text-white"
                    >
                      <X className="w-3 h-3" />
                    </button>
                  </div>
                  <p className="text-[11px] text-slate-300 leading-snug mb-2">
                    How would you like to handle Live RFQ popups?
                  </p>
                </div>

                <div className="space-y-1.5">
                  <Button
                    onClick={handleMinimize}
                    size="sm"
                    className="w-full text-[11px] font-bold justify-start gap-2 h-8 bg-slate-800 hover:bg-slate-700 text-white border border-slate-700"
                  >
                    <Minimize2 className="w-3.5 h-3.5 text-amber-400 shrink-0" />
                    <span>Minimize to corner pill (Recommended)</span>
                  </Button>

                  <Button
                    onClick={handleCloseSession}
                    size="sm"
                    variant="outline"
                    className="w-full text-[11px] font-semibold justify-start gap-2 h-8 border-slate-700 bg-transparent text-slate-200 hover:bg-slate-800 hover:text-white"
                  >
                    <Clock className="w-3.5 h-3.5 text-sky-400 shrink-0" />
                    <span>Close for this session</span>
                  </Button>

                  <Button
                    onClick={handleClosePermanent}
                    size="sm"
                    variant="outline"
                    className="w-full bg-rose-500/10 hover:bg-rose-500/20 text-rose-300 text-[11px] font-semibold justify-start gap-2 h-8 border-rose-500/30"
                  >
                    <EyeOff className="w-3.5 h-3.5 text-rose-400 shrink-0" />
                    <span>Don't show again</span>
                  </Button>

                  <div className="pt-1 flex justify-end">
                    <button
                      onClick={() => setShowCloseMenu(false)}
                      className="text-[10px] text-slate-400 hover:text-white font-medium"
                    >
                      Cancel
                    </button>
                  </div>
                </div>
              </div>
            )}

            {/* ── RFQ Navigation & Progress Row ──────────────────────────── */}
            <div className="flex items-center justify-between gap-2 py-2">
              {/* Segmented Progress Indicator (5 segments) */}
              <div className="flex items-center gap-1 flex-1 max-w-[180px]">
                {[1, 2, 3, 4, 5].map((step) => {
                  const isActive = activeStep === step;
                  return (
                    <div
                      key={step}
                      className={`h-1 rounded-full flex-1 transition-all duration-300 ${
                        isActive
                          ? 'bg-gradient-to-r from-[#FF5A00] to-[#FF8A00] shadow-[0_0_8px_#FF5A00]'
                          : 'bg-slate-800/90'
                      }`}
                    />
                  );
                })}
              </div>

              {/* Step counter and circular navigation */}
              <div className="flex items-center gap-1.5 shrink-0 ml-auto">
                <span className="text-[10px] font-bold text-slate-300 tracking-wider font-mono">
                  {activeStep} / 5
                </span>
                <div className="flex items-center gap-1">
                  <button
                    onClick={() => goToOrder(currentIndex - 1)}
                    aria-label="Previous RFQ"
                    className="w-5 h-5 rounded-full bg-slate-800/90 border border-slate-700/80 hover:bg-slate-700 text-slate-300 hover:text-white flex items-center justify-center transition-colors"
                  >
                    <ChevronLeft className="w-3 h-3" />
                  </button>
                  <button
                    onClick={() => goToOrder(currentIndex + 1)}
                    aria-label="Next RFQ"
                    className="w-5 h-5 rounded-full bg-slate-800/90 border border-slate-700/80 hover:bg-slate-700 text-slate-300 hover:text-white flex items-center justify-center transition-colors"
                  >
                    <ChevronRight className="w-3 h-3" />
                  </button>
                </div>
              </div>
            </div>

            {/* ── Main Content: Compact Thumbnail & Buyer Info ───────────── */}
            <div className="flex gap-2.5 items-center pt-0.5">
              {/* Left: Product Thumbnail */}
              <div
                onClick={() => navigate('/requirements')}
                className="relative w-16 h-16 sm:w-20 sm:h-20 rounded-xl overflow-hidden bg-slate-900 border border-slate-800/90 group cursor-pointer shrink-0 shadow-md"
                title="View requirement"
              >
                <img
                  src={currentOrder.imageUrl}
                  alt={currentOrder.title}
                  className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
                  loading="lazy"
                />
                <div className="absolute inset-0 bg-gradient-to-t from-black/60 via-transparent to-transparent pointer-events-none" />
                <div className="absolute bottom-1 left-1 bg-black/75 backdrop-blur-xs px-1.5 py-0.2 rounded text-[9px] font-bold text-white">
                  100K+
                </div>
              </div>

              {/* Right: Buyer Profile Details */}
              <div className="flex-1 min-w-0">
                <div className="flex items-center gap-2">
                  <div className="relative shrink-0">
                    <img
                      src={avatarUrl}
                      alt={currentOrder.buyerName}
                      className="w-7 h-7 rounded-full object-cover border border-slate-700/80 shadow-xs"
                    />
                    <div className="absolute -bottom-0.5 -right-0.5 w-3 h-3 bg-emerald-500 rounded-full flex items-center justify-center text-slate-950 border border-[#070B13]">
                      <CheckCircle2 className="w-2 h-2 text-slate-950 fill-emerald-500" />
                    </div>
                  </div>

                  <div className="min-w-0 flex-1">
                    <div className="flex items-center justify-between gap-1">
                      <span className="text-xs font-bold text-white truncate">
                        {currentOrder.buyerName}
                      </span>
                      <span className="text-[10px] font-semibold text-slate-200 bg-slate-800/60 border border-slate-700/60 px-1.5 py-0.2 rounded shrink-0">
                        🇮🇳 India
                      </span>
                    </div>
                    <div className="flex items-center gap-1 text-[10px] text-slate-400 truncate">
                      <Building2 className="w-3 h-3 text-slate-500 shrink-0" />
                      <span className="truncate">{currentOrder.companyName}</span>
                    </div>
                  </div>
                </div>

                <div className="flex items-center gap-1 text-[10px] text-slate-400 truncate mt-1">
                  <MapPin className="w-3 h-3 text-[#FF5A00] shrink-0" />
                  <span className="truncate">{currentOrder.city}, India</span>
                </div>
              </div>
            </div>

            {/* Highlight RFQ Description in Compact Quote Card */}
            <div
              onClick={() => navigate('/requirements')}
              className="mt-2 relative rounded-lg bg-[#0c1322]/95 border border-slate-800/90 p-2 cursor-pointer hover:border-slate-700 transition-colors group shadow-inner"
            >
              <span className="text-sm font-serif text-[#FF5A00] leading-none select-none mr-1">“</span>
              <span className="text-[11px] font-bold text-slate-100 leading-tight group-hover:text-white line-clamp-2">
                {currentOrder.message}
              </span>
              <span className="text-sm font-serif text-[#FF5A00] leading-none select-none ml-1">”</span>
            </div>

            {/* ── 6 Micro Information Boxes ──────────────────────────────── */}
            <div className="grid grid-cols-3 gap-1.5 pt-2">
              {/* Box 1: Quantity */}
              <div className="rounded-lg bg-[#0c1322]/90 border border-slate-800/90 p-1.5 flex items-center gap-1.5">
                <Box className="w-3 h-3 text-orange-400 shrink-0" />
                <div className="min-w-0 flex-1">
                  <div className="text-[8px] text-slate-400 uppercase font-medium">Qty</div>
                  <div className="text-[10px] font-bold text-white truncate">{currentOrder.quantity}</div>
                </div>
              </div>

              {/* Box 2: Product Type */}
              <div className="rounded-lg bg-[#0c1322]/90 border border-slate-800/90 p-1.5 flex items-center gap-1.5">
                <ListFilter className="w-3 h-3 text-orange-400 shrink-0" />
                <div className="min-w-0 flex-1">
                  <div className="text-[8px] text-slate-400 uppercase font-medium">Type</div>
                  <div className="text-[10px] font-bold text-white truncate">{productType}</div>
                </div>
              </div>

              {/* Box 3: Required By */}
              <div className="rounded-lg bg-[#0c1322]/90 border border-slate-800/90 p-1.5 flex items-center gap-1.5">
                <CalendarDays className="w-3 h-3 text-orange-400 shrink-0" />
                <div className="min-w-0 flex-1">
                  <div className="text-[8px] text-slate-400 uppercase font-medium">Required</div>
                  <div className="text-[10px] font-bold text-white truncate">Dec 2026</div>
                </div>
              </div>

              {/* Box 4: Target Price */}
              <div className="rounded-lg bg-[#0c1322]/90 border border-slate-800/90 p-1.5 flex items-center gap-1.5">
                <IndianRupee className="w-3 h-3 text-orange-400 shrink-0" />
                <div className="min-w-0 flex-1">
                  <div className="text-[8px] text-slate-400 uppercase font-medium">Target</div>
                  <div className="text-[10px] font-bold text-white truncate">On Request</div>
                </div>
              </div>

              {/* Box 5: Specifications */}
              <div className="rounded-lg bg-[#0c1322]/90 border border-slate-800/90 p-1.5 flex items-center gap-1.5">
                <FileText className="w-3 h-3 text-orange-400 shrink-0" />
                <div className="min-w-0 flex-1">
                  <div className="text-[8px] text-slate-400 uppercase font-medium">Specs</div>
                  <div className="text-[10px] font-bold text-white truncate" title={currentOrder.attribute}>
                    {currentOrder.attribute}
                  </div>
                </div>
              </div>

              {/* Box 6: Delivery Location */}
              <div className="rounded-lg bg-[#0c1322]/90 border border-slate-800/90 p-1.5 flex items-center gap-1.5">
                <Truck className="w-3 h-3 text-orange-400 shrink-0" />
                <div className="min-w-0 flex-1">
                  <div className="text-[8px] text-slate-400 uppercase font-medium">Delivery</div>
                  <div className="text-[10px] font-bold text-white truncate" title={currentOrder.city}>
                    {currentOrder.city}
                  </div>
                </div>
              </div>
            </div>

            {/* ── Badges Row ─────────────────────────────────────────────── */}
            <div className="flex items-center gap-1.5 flex-wrap pt-2">
              <div className="bg-[#FF5A00]/10 border border-[#FF5A00]/30 text-[#FF8A3D] text-[10px] font-semibold px-2 py-0.5 rounded flex items-center gap-1">
                <Zap className="w-2.5 h-2.5 fill-current text-[#FF5A00]" />
                <span className="truncate max-w-[110px]">{currentOrder.category}</span>
              </div>

              <div className="bg-sky-500/10 border border-sky-500/30 text-sky-300 text-[10px] font-semibold px-2 py-0.5 rounded flex items-center gap-1">
                <Truck className="w-2.5 h-2.5 text-sky-400" />
                <span>Bulk</span>
              </div>

              <div className="bg-emerald-500/10 border border-emerald-500/30 text-emerald-400 text-[10px] font-semibold px-2 py-0.5 rounded flex items-center gap-1">
                <Lock className="w-2.5 h-2.5 text-emerald-400" />
                <span>Subscribers Only</span>
              </div>
            </div>

            {/* ── Bottom CTA Buttons ─────────────────────────────────────── */}
            <div className="grid grid-cols-2 gap-2 pt-2.5">
              <button
                type="button"
                onClick={() => navigate('/requirements')}
                className="h-8 rounded-lg bg-[#0f172a]/95 hover:bg-[#1e293b] border border-slate-700/80 text-white font-bold text-xs flex items-center justify-center gap-1.5 transition-all hover:scale-[1.01] active:scale-[0.99] shadow-xs cursor-pointer"
              >
                <Eye className="w-3.5 h-3.5 text-slate-300" />
                <span>View RFQ</span>
              </button>

              <button
                type="button"
                onClick={handleActionClick}
                className="h-8 rounded-lg bg-gradient-to-r from-[#FF5A00] via-[#FF6600] to-[#FF3D00] hover:brightness-110 text-white font-black text-xs shadow-[0_2px_15px_rgba(255,90,0,0.4)] flex items-center justify-center gap-1.5 transition-all hover:scale-[1.01] active:scale-[0.99] cursor-pointer"
              >
                <MessageSquareQuote className="w-3.5 h-3.5 text-white" />
                <span>Send Quote</span>
                <ArrowRight className="w-3 h-3 text-white stroke-[2.5]" />
              </button>
            </div>
          </div>
        </div>
      </div>

      {/* Subscription Requirement Gating Modal */}
      <SubscribeToContactDialog
        open={subDialogOpen}
        onClose={() => setSubDialogOpen(false)}
        reason={subDialogReason}
      />

      {/* Supplier Respond Modal for Paid Subscribers */}
      {quoteDialogOpen && activeReqForQuote && user && company && (
        <SupplierRespondDialog
          open={quoteDialogOpen}
          onClose={() => setQuoteDialogOpen(false)}
          requirement={activeReqForQuote}
          supplierId={user.id}
          supplierCompanyId={company.id}
          onResponded={() => {
            setQuoteDialogOpen(false);
            toast.success('Your quotation has been dispatched to the buyer!');
          }}
        />
      )}
    </>
  );
}
