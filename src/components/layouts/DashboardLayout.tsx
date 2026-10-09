import React, { useState } from 'react';
import { useAuth } from '@/contexts/AuthContext';
import { Link, useLocation, useNavigate } from 'react-router-dom';
import { Sheet, SheetContent, SheetTrigger } from '@/components/ui/sheet';
import { Button } from '@/components/ui/button';
import { toast } from 'sonner';
import BrandLogo from '@/components/common/BrandLogo';
import PageMeta from '@/components/common/PageMeta';
import {
  LayoutDashboard, Package, FileText, MessageSquare, Bell,
  Settings, LogOut, Menu, Globe, BarChart3, TrendingUp,
  Shield, Flag, CreditCard, Building2, UserCircle,
  Warehouse, Zap, Truck, Sparkles, Lock, AlertTriangle,
} from 'lucide-react';
import { cn } from '@/lib/utils';

interface NavItem {
  label: string;
  href: string;
  icon: React.ElementType;
}

const buyerNavItems: NavItem[] = [
  { label: 'Overview', href: '/dashboard/buyer', icon: LayoutDashboard },
  { label: 'My Requirements', href: '/dashboard/buyer/requirements', icon: FileText },
  { label: 'Received Quotes', href: '/dashboard/buyer/quotes', icon: Package },
  { label: 'Orders', href: '/dashboard/buyer/orders', icon: Package },
  { label: 'Messages', href: '/dashboard/buyer/messages', icon: MessageSquare },
  { label: 'Notifications', href: '/dashboard/buyer/notifications', icon: Bell },
  { label: 'Saved Manufacturers', href: '/dashboard/buyer/saved-manufacturers', icon: Building2 },
  { label: 'Shipping Calculator', href: '/shipping-calculator', icon: Truck },
  { label: 'KYC Verification', href: '/dashboard/buyer/verification', icon: Shield },
  { label: 'Disputes', href: '/dashboard/buyer/disputes', icon: Flag },
  { label: 'Profile', href: '/dashboard/buyer/profile', icon: Settings },
];

const supplierNavItems: NavItem[] = [
  { label: 'Overview', href: '/dashboard/supplier', icon: LayoutDashboard },
  { label: 'AI Sales Assistant', href: '/dashboard/supplier/ai-assistant', icon: Sparkles },
  { label: 'Business Overview', href: '/dashboard/supplier/overview', icon: BarChart3 },
  { label: 'My Products', href: '/dashboard/supplier/products', icon: Package },
  { label: 'Inventory & Stock', href: '/dashboard/supplier/inventory', icon: Warehouse },
  { label: 'RFQ Leads', href: '/dashboard/supplier/rfqs', icon: FileText },
  { label: 'Quotations', href: '/dashboard/supplier/quotations', icon: TrendingUp },
  { label: 'Orders', href: '/dashboard/supplier/orders', icon: Building2 },
  { label: 'Messages', href: '/dashboard/supplier/messages', icon: MessageSquare },
  { label: 'Lead Credits', href: '/dashboard/supplier/lead-credits', icon: Zap },
  { label: 'Notifications', href: '/dashboard/supplier/notifications', icon: Bell },
  { label: 'Verification', href: '/dashboard/supplier/verification', icon: Shield },
  { label: 'Disputes', href: '/dashboard/supplier/disputes', icon: Flag },
  { label: 'Analytics', href: '/dashboard/supplier/analytics', icon: BarChart3 },
  { label: 'Subscription', href: '/dashboard/supplier/subscription', icon: CreditCard },
  { label: 'Business Profile', href: '/dashboard/supplier/profile', icon: UserCircle },
];

const adminNavItems: NavItem[] = [
  { label: 'Control Panel', href: '/dashboard/admin', icon: LayoutDashboard },
  { label: 'AI Match Analytics', href: '/dashboard/admin/ai-match-analytics', icon: Zap },
];

interface DashboardLayoutProps {
  children: React.ReactNode;
}

export default function DashboardLayout({ children }: DashboardLayoutProps) {
  const { profile, isPaidSubscriber, signOut } = useAuth();
  const location = useLocation();
  const navigate = useNavigate();
  const [mobileOpen, setMobileOpen] = useState(false);

  const isUnpaidManufacturer = profile?.role === 'supplier' && !isPaidSubscriber;

  const navItems = profile?.role === 'admin'
    ? adminNavItems
    : profile?.role === 'supplier'
    ? supplierNavItems
    : buyerNavItems;

  const handleSignOut = async () => {
    try {
      await signOut();
      toast.success('Signed out successfully');
      navigate('/');
    } catch (err) {
      console.error('Sign out error:', err);
      toast.error('Failed to sign out. Please try again.');
    }
  };

  const isActive = (href: string) => {
    if (href === '/dashboard/buyer' || href === '/dashboard/supplier' || href === '/dashboard/admin') {
      return location.pathname === href;
    }
    return location.pathname.startsWith(href);
  };

  const SidebarContent = () => (
    <div className="flex flex-col h-full">
      <div className="p-4 border-b border-sidebar-border">
        <BrandLogo size="md" variant="auto" linkTo="/" />
      </div>

      {/* User info */}
      <div className="p-4 border-b border-sidebar-border">
        <div className="flex items-center gap-3">
          <div className="w-9 h-9 rounded-full bg-primary/20 flex items-center justify-center text-primary font-bold text-sm shrink-0">
            {profile?.full_name?.[0]?.toUpperCase() ?? 'U'}
          </div>
          <div className="flex-1 min-w-0">
            <div className="text-sm font-medium text-sidebar-foreground truncate">{profile?.full_name ?? 'User'}</div>
            <div className="text-xs text-muted-foreground capitalize">{profile?.role}</div>
          </div>
        </div>
      </div>

      <nav className="flex-1 p-3 space-y-0.5 overflow-y-auto">
        {navItems.map(item => {
          const Icon = item.icon;
          const active = isActive(item.href);
          return (
            <Link
              key={item.href}
              to={item.href}
              onClick={() => setMobileOpen(false)}
              className={cn(
                'flex items-center gap-3 px-3 py-2.5 rounded-md text-sm transition-colors min-h-10',
                active
                  ? 'bg-sidebar-primary/20 text-primary font-medium'
                  : 'text-sidebar-foreground hover:bg-sidebar-accent hover:text-sidebar-foreground'
              )}
            >
              <Icon className={cn('w-4 h-4 shrink-0', active ? 'text-primary' : 'text-muted-foreground')} />
              <span className="truncate">{item.label}</span>
              {item.href === '/dashboard/supplier/subscription' && isUnpaidManufacturer && (
                <span className="ml-auto text-[9px] font-bold px-1.5 py-0.5 rounded bg-amber-500/20 text-amber-500 border border-amber-500/30 uppercase tracking-wider">
                  Unpaid
                </span>
              )}
            </Link>
          );
        })}
      </nav>

      <div className="p-3 border-t border-sidebar-border space-y-0.5">
        <Link to="/" className="flex items-center gap-3 px-3 py-2.5 rounded-md text-sm text-sidebar-foreground hover:bg-sidebar-accent transition-colors">
          <Globe className="w-4 h-4 text-muted-foreground" /> Marketplace
        </Link>
        <button
          onClick={handleSignOut}
          className="flex items-center gap-3 px-3 py-2.5 rounded-md text-sm text-destructive hover:bg-destructive/10 transition-colors w-full text-left"
        >
          <LogOut className="w-4 h-4" /> Sign Out
        </button>
      </div>
    </div>
  );

  return (
    <div className="flex min-h-screen w-full bg-background">
      <PageMeta
        title="Dashboard — BulkSkart B2B Marketplace"
        description="BulkSkart secure account management and trade negotiation dashboard."
        robots="noindex, nofollow"
      />
      {/* Desktop Sidebar */}
      <aside className="hidden md:flex flex-col w-60 shrink-0 bg-sidebar border-r border-sidebar-border">
        <SidebarContent />
      </aside>

        {/* Main */}
        <div className="flex-1 min-w-0 overflow-x-hidden flex flex-col w-full">
          {/* Mobile top bar */}
          <div className="md:hidden flex items-center gap-3 px-3 sm:px-4 h-14 border-b border-border bg-background shrink-0 w-full">
            <Sheet open={mobileOpen} onOpenChange={setMobileOpen}>
              <SheetTrigger asChild>
                <Button variant="ghost" size="icon" className="text-foreground shrink-0" aria-label="Open sidebar menu">
                  <Menu className="w-5 h-5" />
                </Button>
              </SheetTrigger>
              <SheetContent side="left" className="w-[min(280px,85vw)] p-0 bg-sidebar border-sidebar-border">
                <SidebarContent />
              </SheetContent>
            </Sheet>
            <BrandLogo size="sm" variant="auto" linkTo="/" />
          </div>

          {/* ── UNPAID MANUFACTURER SUBSCRIPTION NOTIFICATION BANNER ── */}
          {isUnpaidManufacturer && (
            <div className="w-full bg-gradient-to-r from-amber-500/15 via-orange-500/15 to-amber-500/10 border-b-2 border-amber-500/30 px-3 md:px-6 py-2.5 sm:py-3 shrink-0 flex items-center justify-between gap-3 flex-wrap">
              <div className="flex items-center gap-2.5 min-w-0">
                <div className="w-8 h-8 rounded-lg bg-amber-500/20 text-amber-500 flex items-center justify-center shrink-0">
                  <Lock className="w-4 h-4" />
                </div>
                <div className="min-w-0">
                  <div className="flex items-center gap-2 flex-wrap">
                    <span className="text-xs sm:text-sm font-extrabold text-foreground">
                      Action Required: Unpaid Manufacturer Account
                    </span>
                    <span className="text-[10px] font-bold px-2 py-0.5 rounded-full bg-amber-500/20 text-amber-500 border border-amber-500/30 uppercase tracking-wider">
                      Buyer Contacts Locked
                    </span>
                  </div>
                  <p className="text-[11px] sm:text-xs text-muted-foreground mt-0.5 truncate sm:whitespace-normal">
                    Buyer phone numbers, direct WhatsApp dialers, RFQ contact details, and bidding participant numbers are hidden. Subscribe to an active manufacturer plan to unlock direct buyer contacts.
                  </p>
                </div>
              </div>
              <div className="flex items-center gap-2 shrink-0 ml-auto sm:ml-0">
                <Link to="/pricing">
                  <Button variant="outline" size="sm" className="h-8 text-xs border-amber-500/30 hover:bg-amber-500/10">
                    Compare Plans
                  </Button>
                </Link>
                <Link to="/dashboard/supplier/subscription">
                  <Button size="sm" className="h-8 bg-gradient-to-r from-amber-500 to-orange-500 hover:from-amber-600 hover:to-orange-600 text-white font-bold text-xs shadow-md gap-1.5">
                    <Sparkles className="w-3.5 h-3.5" />
                    <span>Subscribe Now</span>
                  </Button>
                </Link>
              </div>
            </div>
          )}

          <main className="flex-1 w-full min-w-0 overflow-x-hidden">
            {children}
          </main>
        </div>
    </div>
  );
}
