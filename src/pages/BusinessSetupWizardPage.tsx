import React, { useState, useEffect } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { useAuth } from '@/contexts/AuthContext';
import { supabase } from '@/db/supabase';
import { toast } from 'sonner';
import {
  Building2, User, FileText, CheckCircle2, ArrowRight, ArrowLeft,
  Upload, Shield, ShieldCheck, AlertCircle, Save, Briefcase,
  Globe, Truck, Award, Sparkles, Check, Info, FileCheck, Layers
} from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Textarea } from '@/components/ui/textarea';
import { Badge } from '@/components/ui/badge';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import PageMeta from '@/components/common/PageMeta';

const ACCOUNT_TYPES = [
  { id: 'Manufacturer', label: 'Manufacturer / Factory', desc: 'Direct production facility with custom OEM/ODM bulk capabilities', role: 'supplier' },
  { id: 'Wholesaler', label: 'Wholesaler / Stockist', desc: 'Holds ready stock in bulk warehouses for fast regional dispatch', role: 'supplier' },
  { id: 'Distributor', label: 'Authorized Distributor', desc: 'Direct brand channel distributor with institutional pricing', role: 'supplier' },
  { id: 'Buyer', label: 'Bulk Buyer / Procurement', desc: 'Procures raw materials, industrial equipment, or wholesale batches', role: 'buyer' },
  { id: 'Importer', label: 'Importer', desc: 'Imports products in bulk containers for domestic distribution', role: 'supplier' },
  { id: 'Exporter', label: 'Exporter', desc: 'Exports certified goods and components to international markets', role: 'supplier' },
];

const PRODUCT_CATEGORIES = [
  'Machinery & Industrial Equipment',
  'Packaging & Printing',
  'Textiles & Apparel',
  'Chemicals & Raw Materials',
  'Construction & Building Materials',
  'Electronics & Electricals',
  'Auto Parts & Vehicles',
  'Pharmaceuticals & Healthcare',
  'Agriculture & Food Products',
  'Plastics & Rubber',
  'Furniture & Home Decor',
  'Gems & Jewellery',
  'Handicrafts & Gifts',
];

const PAYMENT_TERMS = ['L/C (Letter of Credit)', 'T/T (Telegraphic Transfer)', 'D/P (Documents Against Payment)', 'D/A (Documents Against Acceptance)', 'Escrow Trade Assurance', 'Cash Against Documents', 'Advance Payment'];
const SHIPPING_MODES = ['Road Freight / Full Truckload', 'Air Cargo (Express & General)', 'Sea Freight (FCL & LCL)', 'Courier / Parcel Express', 'Warehousing & Cross-Docking', 'Cold Chain Logistics'];
const COUNTRIES_LIST = ['India', 'United States', 'United Arab Emirates', 'United Kingdom', 'Germany', 'Australia', 'Canada', 'Saudi Arabia', 'Singapore', 'Japan', 'South Africa', 'Worldwide'];

export default function BusinessSetupWizardPage() {
  const { user, profile, company, buyerProfile, refreshProfile } = useAuth();
  const navigate = useNavigate();
  const [searchParams] = useSearchParams();

  const [currentStep, setCurrentStep] = useState<number>(1);
  const [loading, setLoading] = useState<boolean>(true);
  const [saving, setSaving] = useState<boolean>(false);
  const [completing, setCompleting] = useState<boolean>(false);

  // Form state
  const [accountType, setAccountType] = useState<string>('Manufacturer');

  // Step 2: Personal Details
  const [personal, setPersonal] = useState({
    fullName: '',
    email: '',
    phone: '',
    whatsappNumber: '',
    country: 'India',
    state: '',
    city: '',
  });

  // Step 3: Business Details
  const [business, setBusiness] = useState({
    legalName: '',
    brandName: '',
    businessType: 'Manufacturer',
    registrationNumber: '',
    gstNumber: '',
    panNumber: '',
    iecNumber: '',
    address: '',
    pincode: '',
    website: '',
    yearEstablished: '',
    description: '',
  });

  // Step 4: Operations
  const [selectedCategories, setSelectedCategories] = useState<string[]>([]);
  const [productsSupplied, setProductsSupplied] = useState<string[]>([]);
  const [productInput, setProductInput] = useState<string>('');
  const [moq, setMoq] = useState<string>('');
  const [capacity, setCapacity] = useState<string>('');
  const [tradeType, setTradeType] = useState<string>('domestic'); // 'domestic' | 'import' | 'export' | 'both'
  const [countriesServed, setCountriesServed] = useState<string[]>(['India']);
  const [paymentTerms, setPaymentTerms] = useState<string[]>(['T/T (Telegraphic Transfer)']);
  const [shippingCapabilities, setShippingCapabilities] = useState<string[]>(['Road Freight / Full Truckload']);

  // Step 5: Verification docs
  const [docs, setDocs] = useState<{
    gstDocUrl?: string;
    iecDocUrl?: string;
    panDocUrl?: string;
    regDocUrl?: string;
  }>({});
  const [uploadingDoc, setUploadingDoc] = useState<string | null>(null);
  const [verificationStatus, setVerificationStatus] = useState<'unverified' | 'pending' | 'verified' | 'rejected'>('unverified');

  // Load existing data for user
  useEffect(() => {
    if (!user) {
      setLoading(false);
      return;
    }

    const loadData = async () => {
      setLoading(true);
      try {
        // Prefill personal details from user & profile
        setPersonal(prev => ({
          ...prev,
          fullName: profile?.full_name || '',
          email: user.email || '',
          phone: profile?.phone || '',
          whatsappNumber: (profile as any)?.whatsapp_number || '',
          country: (profile as any)?.country || 'India',
          state: (profile as any)?.state || '',
          city: (profile as any)?.city || '',
        }));

        if (profile?.role === 'buyer') {
          setAccountType('Buyer');
        }

        // Check if company exists
        if (company) {
          setAccountType(company.business_type || 'Manufacturer');
          setBusiness({
            legalName: company.company_name || '',
            brandName: (company as any).brand_name || '',
            businessType: company.business_type || 'Manufacturer',
            registrationNumber: (company as any).registration_number || '',
            gstNumber: company.gst_number || '',
            panNumber: (company as any).pan_number || '',
            iecNumber: company.iec_number || '',
            address: company.address || '',
            pincode: company.pincode || '',
            website: company.website || '',
            yearEstablished: company.year_established ? String(company.year_established) : '',
            description: company.description || '',
          });
          setSelectedCategories((company as any).product_categories || []);
          setProductsSupplied(company.key_products || []);
          setMoq(company.moq_policy || '');
          setCapacity(company.production_capacity || '');
          setTradeType((company as any).trade_type || 'both');
          setCountriesServed(company.export_destinations || ['India']);
          setPaymentTerms(company.payment_terms || ['T/T (Telegraphic Transfer)']);
          if ((company as any).shipping_capabilities) {
            setShippingCapabilities([(company as any).shipping_capabilities]);
          }
          setDocs({
            gstDocUrl: company.gst_doc_url || undefined,
            iecDocUrl: company.iec_doc_url || undefined,
            panDocUrl: (company as any).pan_doc_url || undefined,
            regDocUrl: company.reg_doc_url || undefined,
          });
          setVerificationStatus(company.verification_status as any || 'unverified');
          if ((company as any).onboarding_step && (company as any).onboarding_step <= 5) {
            setCurrentStep((company as any).onboarding_step);
          }
        } else if (buyerProfile) {
          setAccountType('Buyer');
          setBusiness(prev => ({
            ...prev,
            legalName: buyerProfile.company_name || '',
            brandName: (buyerProfile as any).brand_name || '',
            businessType: buyerProfile.business_type || 'Wholesaler / Distributor',
            registrationNumber: (buyerProfile as any).registration_number || '',
            gstNumber: buyerProfile.gst_number || '',
            panNumber: (buyerProfile as any).pan_number || '',
            address: buyerProfile.address || '',
            pincode: buyerProfile.pincode || '',
            description: (buyerProfile as any).description || '',
          }));
          setSelectedCategories((buyerProfile as any).product_categories || []);
          setProductsSupplied((buyerProfile as any).target_products || []);
          setDocs({
            gstDocUrl: (buyerProfile as any).gst_doc_url || undefined,
            panDocUrl: (buyerProfile as any).pan_doc_url || undefined,
            regDocUrl: (buyerProfile as any).reg_doc_url || undefined,
          });
          setVerificationStatus((buyerProfile as any).verification_status as any || 'unverified');
          if ((buyerProfile as any).onboarding_step && (buyerProfile as any).onboarding_step <= 5) {
            setCurrentStep((buyerProfile as any).onboarding_step);
          }
        }
      } catch (err) {
        console.error('Error loading onboarding data:', err);
      } finally {
        setLoading(false);
      }
    };

    loadData();
  }, [user, profile, company, buyerProfile]);

  // Handle document uploads
  const handleUploadDoc = async (file: File, type: 'gst' | 'iec' | 'pan' | 'reg') => {
    if (!user) return;
    setUploadingDoc(type);
    try {
      const ext = file.name.split('.').pop();
      const path = `${user.id}/docs/${type}-${Date.now()}.${ext}`;
      const { data, error } = await supabase.storage.from('business-docs').upload(path, file, { upsert: true });
      if (error) throw error;
      const { data: urlData } = supabase.storage.from('business-docs').getPublicUrl(data.path);
      const docUrl = urlData.publicUrl;

      setDocs(prev => ({
        ...prev,
        [`${type}DocUrl`]: docUrl,
      }));
      setVerificationStatus('pending');
      toast.success(`${type.toUpperCase()} document uploaded successfully!`);
    } catch (err: any) {
      toast.error(err?.message || 'Failed to upload document');
    } finally {
      setUploadingDoc(null);
    }
  };

  // Add product tag
  const handleAddProduct = () => {
    const val = productInput.trim();
    if (val && !productsSupplied.includes(val)) {
      setProductsSupplied(p => [...p, val]);
      setProductInput('');
    }
  };

  const handleRemoveProduct = (p: string) => {
    setProductsSupplied(prev => prev.filter(x => x !== p));
  };

  // Calculate completion percentage
  const calculateCompletionScore = (): number => {
    let score = 20; // Step 1 complete
    if (personal.fullName && personal.phone && personal.city && personal.state) score += 20;
    if (business.legalName && business.description && (business.gstNumber || business.registrationNumber)) score += 25;
    if (selectedCategories.length > 0 && productsSupplied.length > 0) score += 20;
    if (docs.gstDocUrl || docs.panDocUrl || docs.regDocUrl || docs.iecDocUrl) score += 15;
    return Math.min(100, score);
  };

  // Save draft to database
  const handleSaveDraft = async () => {
    if (!user) {
      toast.error('You must be logged in to save progress');
      return;
    }
    setSaving(true);
    try {
      const completionScore = calculateCompletionScore();
      const isBuyer = accountType === 'Buyer';

      // 1. Update profiles table
      await supabase.from('profiles').update({
        full_name: personal.fullName || profile?.full_name,
        phone: personal.phone || profile?.phone,
        whatsapp_number: personal.whatsappNumber || null,
        country: personal.country,
        state: personal.state,
        city: personal.city,
        role: isBuyer ? 'buyer' : 'supplier',
        updated_at: new Date().toISOString(),
      }).eq('id', user.id);

      if (isBuyer) {
        // Upsert buyer_profiles
        const buyerPayload = {
          user_id: user.id,
          company_name: business.legalName || 'My Procurement Business',
          brand_name: business.brandName || null,
          business_type: business.businessType || 'Buyer',
          registration_number: business.registrationNumber || null,
          gst_number: business.gstNumber || null,
          pan_number: business.panNumber || null,
          website: business.website || null,
          address: business.address || null,
          city: personal.city || null,
          state: personal.state || null,
          country: personal.country || 'India',
          pincode: business.pincode || null,
          description: business.description || null,
          product_categories: selectedCategories,
          target_products: productsSupplied,
          trade_type: tradeType,
          countries_served: countriesServed,
          payment_terms: paymentTerms,
          gst_doc_url: docs.gstDocUrl || null,
          pan_doc_url: docs.panDocUrl || null,
          reg_doc_url: docs.regDocUrl || null,
          onboarding_step: currentStep,
          onboarding_completed: false,
          profile_completion: completionScore,
          verification_status: verificationStatus,
          updated_at: new Date().toISOString(),
        };

        const { data: existingBuyer } = await supabase.from('buyer_profiles').select('id').eq('user_id', user.id).maybeSingle();
        if (existingBuyer?.id) {
          await supabase.from('buyer_profiles').update(buyerPayload).eq('user_id', user.id);
        } else {
          await supabase.from('buyer_profiles').insert(buyerPayload);
        }
      } else {
        // Upsert companies table
        const slug = (business.legalName || 'supplier').toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/(^-|-$)/g, '') + '-' + user.id.slice(0, 6);
        const companyPayload = {
          owner_id: user.id,
          company_name: business.legalName || 'My Industrial Company',
          brand_name: business.brandName || null,
          business_type: business.businessType || accountType,
          registration_number: business.registrationNumber || null,
          gst_number: business.gstNumber || null,
          pan_number: business.panNumber || null,
          iec_number: business.iecNumber || null,
          address: business.address || null,
          city: personal.city || null,
          state: personal.state || null,
          country: personal.country || 'India',
          pincode: business.pincode || null,
          website: business.website || null,
          year_established: business.yearEstablished ? parseInt(business.yearEstablished, 10) : null,
          description: business.description || null,
          product_categories: selectedCategories,
          key_products: productsSupplied,
          moq_policy: moq || null,
          production_capacity: capacity || null,
          trade_type: tradeType,
          export_destinations: countriesServed,
          payment_terms: paymentTerms,
          shipping_capabilities: shippingCapabilities.join(', '),
          gst_doc_url: docs.gstDocUrl || null,
          iec_doc_url: docs.iecDocUrl || null,
          pan_doc_url: docs.panDocUrl || null,
          reg_doc_url: docs.regDocUrl || null,
          onboarding_step: currentStep,
          onboarding_completed: false,
          profile_completion: completionScore,
          verification_status: verificationStatus,
          updated_at: new Date().toISOString(),
        };

        const { data: existingCo } = await supabase.from('companies').select('id').eq('owner_id', user.id).maybeSingle();
        if (existingCo?.id) {
          await supabase.from('companies').update(companyPayload).eq('owner_id', user.id);
        } else {
          await supabase.from('companies').insert({
            ...companyPayload,
            slug,
            verification_status: 'unverified',
            is_verified: false,
            is_featured: false,
            total_products: 0,
            total_quotes_sent: 0,
          });
        }
      }

      await refreshProfile();
      toast.success('Draft saved successfully! You can resume anytime.');
    } catch (err: any) {
      console.error('Save draft error:', err);
      toast.error(err?.message || 'Failed to save draft');
    } finally {
      setSaving(false);
    }
  };

  // Complete profile & finalize
  const handleCompleteProfile = async () => {
    if (!user) return;

    // Validation
    if (!personal.fullName.trim()) {
      toast.error('Please enter your full name in Personal Details');
      setCurrentStep(2);
      return;
    }
    if (!personal.phone.trim()) {
      toast.error('Please enter a valid mobile contact number');
      setCurrentStep(2);
      return;
    }
    if (!business.legalName.trim()) {
      toast.error('Please enter your legal business name');
      setCurrentStep(3);
      return;
    }

    setCompleting(true);
    try {
      const isBuyer = accountType === 'Buyer';
      const completionScore = calculateCompletionScore();
      const hasUploadedDoc = Boolean(docs.gstDocUrl || docs.panDocUrl || docs.regDocUrl || docs.iecDocUrl);
      const finalStatus = hasUploadedDoc ? 'pending' : 'unverified';

      // 1. Update profiles table
      await supabase.from('profiles').update({
        full_name: personal.fullName.trim(),
        phone: personal.phone.trim(),
        whatsapp_number: personal.whatsappNumber.trim() || null,
        country: personal.country,
        state: personal.state,
        city: personal.city,
        role: isBuyer ? 'buyer' : 'supplier',
        onboarding_completed: true,
        updated_at: new Date().toISOString(),
      }).eq('id', user.id);

      if (isBuyer) {
        const buyerPayload = {
          user_id: user.id,
          company_name: business.legalName.trim(),
          brand_name: business.brandName.trim() || null,
          business_type: business.businessType || 'Buyer',
          registration_number: business.registrationNumber.trim() || null,
          gst_number: business.gstNumber.trim() || null,
          pan_number: business.panNumber.trim() || null,
          website: business.website.trim() || null,
          address: business.address.trim() || null,
          city: personal.city.trim() || null,
          state: personal.state.trim() || null,
          country: personal.country || 'India',
          pincode: business.pincode.trim() || null,
          description: business.description.trim() || null,
          product_categories: selectedCategories,
          target_products: productsSupplied,
          trade_type: tradeType,
          countries_served: countriesServed,
          payment_terms: paymentTerms,
          gst_doc_url: docs.gstDocUrl || null,
          pan_doc_url: docs.panDocUrl || null,
          reg_doc_url: docs.regDocUrl || null,
          onboarding_step: 5,
          onboarding_completed: true,
          profile_completion: Math.max(75, completionScore),
          verification_status: finalStatus,
          updated_at: new Date().toISOString(),
        };

        const { data: existingBuyer } = await supabase.from('buyer_profiles').select('id').eq('user_id', user.id).maybeSingle();
        if (existingBuyer?.id) {
          await supabase.from('buyer_profiles').update(buyerPayload).eq('user_id', user.id);
        } else {
          await supabase.from('buyer_profiles').insert(buyerPayload);
        }
      } else {
        const slug = business.legalName.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/(^-|-$)/g, '') + '-' + user.id.slice(0, 6);
        const companyPayload = {
          owner_id: user.id,
          company_name: business.legalName.trim(),
          brand_name: business.brandName.trim() || null,
          business_type: business.businessType || accountType,
          registration_number: business.registrationNumber.trim() || null,
          gst_number: business.gstNumber.trim() || null,
          pan_number: business.panNumber.trim() || null,
          iec_number: business.iecNumber.trim() || null,
          address: business.address.trim() || null,
          city: personal.city.trim() || null,
          state: personal.state.trim() || null,
          country: personal.country || 'India',
          pincode: business.pincode.trim() || null,
          website: business.website.trim() || null,
          year_established: business.yearEstablished ? parseInt(business.yearEstablished, 10) : null,
          description: business.description.trim() || null,
          product_categories: selectedCategories,
          key_products: productsSupplied,
          moq_policy: moq.trim() || null,
          production_capacity: capacity.trim() || null,
          trade_type: tradeType,
          export_destinations: countriesServed,
          payment_terms: paymentTerms,
          shipping_capabilities: shippingCapabilities.join(', '),
          gst_doc_url: docs.gstDocUrl || null,
          iec_doc_url: docs.iecDocUrl || null,
          pan_doc_url: docs.panDocUrl || null,
          reg_doc_url: docs.regDocUrl || null,
          onboarding_step: 5,
          onboarding_completed: true,
          profile_completion: Math.max(75, completionScore),
          verification_status: finalStatus,
          updated_at: new Date().toISOString(),
        };

        const { data: existingCo } = await supabase.from('companies').select('id').eq('owner_id', user.id).maybeSingle();
        if (existingCo?.id) {
          await supabase.from('companies').update(companyPayload).eq('owner_id', user.id);
        } else {
          await supabase.from('companies').insert({
            ...companyPayload,
            slug,
            verification_status: finalStatus,
            is_verified: false,
            is_featured: false,
            total_products: 0,
            total_quotes_sent: 0,
          });
        }
      }

      await refreshProfile();
      toast.success('Business profile setup completed successfully!');
      if (isBuyer) {
        navigate('/dashboard/buyer');
      } else {
        navigate('/dashboard/supplier');
      }
    } catch (err: any) {
      console.error('Complete profile error:', err);
      toast.error(err?.message || 'Failed to complete profile');
    } finally {
      setCompleting(false);
    }
  };

  const steps = [
    { num: 1, title: 'Account Type', icon: Briefcase },
    { num: 2, title: 'Personal Details', icon: User },
    { num: 3, title: 'Business Details', icon: Building2 },
    { num: 4, title: 'Operations', icon: Layers },
    { num: 5, title: 'Verification', icon: ShieldCheck },
  ];

  if (loading) {
    return (
      <div className="min-h-screen bg-background flex items-center justify-center">
        <div className="flex flex-col items-center gap-3">
          <div className="w-10 h-10 border-4 border-primary border-t-transparent rounded-full animate-spin" />
          <p className="text-sm text-muted-foreground font-medium">Loading profile setup...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-background text-foreground flex flex-col">
      <PageMeta title="Business Profile Setup Wizard | BulkSkart" description="Complete your official BulkSkart business registration and trade profile." />

      {/* Top Header */}
      <header className="sticky top-0 z-30 border-b border-border bg-card/90 backdrop-blur-md px-4 sm:px-8 py-3.5 flex items-center justify-between">
        <div className="flex items-center gap-3 min-w-0">
          <div className="w-8 h-8 rounded-lg bg-primary/10 border border-primary/30 flex items-center justify-center shrink-0">
            <Building2 className="w-4 h-4 text-primary" />
          </div>
          <div className="min-w-0">
            <h1 className="text-sm sm:text-base font-bold text-foreground truncate">Business Profile Setup Wizard</h1>
            <p className="text-[11px] text-muted-foreground truncate">Official verification & marketplace onboarding</p>
          </div>
        </div>

        <div className="flex items-center gap-2 shrink-0">
          <Button
            variant="outline"
            size="sm"
            onClick={handleSaveDraft}
            disabled={saving || completing}
            className="text-xs h-8 gap-1.5"
          >
            <Save className="w-3.5 h-3.5" />
            <span className="hidden sm:inline">Save Draft</span>
          </Button>
          <Button
            size="sm"
            onClick={() => navigate(accountType === 'Buyer' ? '/dashboard/buyer' : '/dashboard/supplier')}
            variant="ghost"
            className="text-xs h-8 text-muted-foreground hover:text-foreground"
          >
            Exit to Dashboard
          </Button>
        </div>
      </header>

      {/* Main Container */}
      <main className="flex-1 max-w-4xl w-full mx-auto p-4 sm:p-6 md:p-8 space-y-6">
        {/* Progress Bar & Steps Indicator */}
        <div className="bg-card border border-border rounded-xl p-4 sm:p-5 shadow-sm space-y-4">
          <div className="flex items-center justify-between text-xs font-semibold text-muted-foreground">
            <span>Step {currentStep} of 5: {steps[currentStep - 1]?.title}</span>
            <span className="text-primary">{calculateCompletionScore()}% Completed</span>
          </div>

          <div className="w-full bg-muted rounded-full h-2 overflow-hidden">
            <div
              className="bg-primary h-full transition-all duration-300 rounded-full"
              style={{ width: `${(currentStep / 5) * 100}%` }}
            />
          </div>

          <div className="grid grid-cols-5 gap-1 sm:gap-2 pt-1">
            {steps.map(s => {
              const Icon = s.icon;
              const isActive = s.num === currentStep;
              const isPast = s.num < currentStep;
              return (
                <button
                  key={s.num}
                  type="button"
                  onClick={() => setCurrentStep(s.num)}
                  className={`flex flex-col items-center text-center p-1.5 rounded-lg transition-colors ${
                    isActive
                      ? 'bg-primary/10 text-primary font-bold'
                      : isPast
                      ? 'text-foreground hover:bg-muted/50'
                      : 'text-muted-foreground/60 hover:text-muted-foreground'
                  }`}
                >
                  <div className={`w-7 h-7 rounded-full flex items-center justify-center text-xs mb-1 ${
                    isActive
                      ? 'bg-primary text-white shadow-sm'
                      : isPast
                      ? 'bg-emerald-500/20 text-emerald-500'
                      : 'bg-muted text-muted-foreground'
                  }`}>
                    {isPast ? <Check className="w-3.5 h-3.5 stroke-[3]" /> : <Icon className="w-3.5 h-3.5" />}
                  </div>
                  <span className="text-[10px] sm:text-xs leading-tight line-clamp-1">{s.title}</span>
                </button>
              );
            })}
          </div>
        </div>

        {/* Wizard Step Content */}
        <Card className="border-border bg-card shadow-sm">
          {/* STEP 1: ACCOUNT TYPE */}
          {currentStep === 1 && (
            <div>
              <CardHeader className="pb-4">
                <CardTitle className="text-lg sm:text-xl font-bold flex items-center gap-2">
                  <Briefcase className="w-5 h-5 text-primary" />
                  Select Your Account & Trading Role
                </CardTitle>
                <CardDescription>
                  Choose how your enterprise operates on BulkSkart. This tailors your RFQs, catalog tools, and verification requirements.
                </CardDescription>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                  {ACCOUNT_TYPES.map(type => (
                    <div
                      key={type.id}
                      onClick={() => setAccountType(type.id)}
                      className={`cursor-pointer border rounded-xl p-4 transition-all ${
                        accountType === type.id
                          ? 'border-primary bg-primary/5 ring-1 ring-primary shadow-sm'
                          : 'border-border bg-card hover:border-primary/40 hover:bg-muted/30'
                      }`}
                    >
                      <div className="flex items-start justify-between gap-2">
                        <div>
                          <p className="font-semibold text-sm sm:text-base text-foreground">{type.label}</p>
                          <p className="text-xs text-muted-foreground mt-1 leading-relaxed">{type.desc}</p>
                        </div>
                        <div className={`w-5 h-5 rounded-full border flex items-center justify-center shrink-0 ${
                          accountType === type.id ? 'border-primary bg-primary text-white' : 'border-border'
                        }`}>
                          {accountType === type.id && <Check className="w-3 h-3 stroke-[3]" />}
                        </div>
                      </div>
                      <Badge variant="outline" className="mt-3 text-[10px] uppercase font-semibold">
                        Role: {type.role}
                      </Badge>
                    </div>
                  ))}
                </div>
              </CardContent>
            </div>
          )}

          {/* STEP 2: PERSONAL DETAILS */}
          {currentStep === 2 && (
            <div>
              <CardHeader className="pb-4">
                <CardTitle className="text-lg sm:text-xl font-bold flex items-center gap-2">
                  <User className="w-5 h-5 text-primary" />
                  Authorized Representative Details
                </CardTitle>
                <CardDescription>
                  Provide the contact information of the primary account holder or procurement director.
                </CardDescription>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                  <div className="space-y-1.5">
                    <Label className="text-xs font-semibold">Full Name <span className="text-destructive">*</span></Label>
                    <Input
                      placeholder="e.g. Rajesh Sharma"
                      value={personal.fullName}
                      onChange={e => setPersonal(p => ({ ...p, fullName: e.target.value }))}
                      className="bg-background text-sm"
                    />
                  </div>

                  <div className="space-y-1.5">
                    <Label className="text-xs font-semibold">Official Email Address <span className="text-destructive">*</span></Label>
                    <Input
                      type="email"
                      placeholder="name@company.com"
                      value={personal.email}
                      disabled
                      className="bg-muted text-muted-foreground text-sm cursor-not-allowed"
                    />
                    <p className="text-[10px] text-muted-foreground">Linked to your authenticated login credentials</p>
                  </div>

                  <div className="space-y-1.5">
                    <Label className="text-xs font-semibold">Mobile Phone Number <span className="text-destructive">*</span></Label>
                    <Input
                      placeholder="e.g. +91 98765 43210"
                      value={personal.phone}
                      onChange={e => setPersonal(p => ({ ...p, phone: e.target.value }))}
                      className="bg-background text-sm"
                    />
                  </div>

                  <div className="space-y-1.5">
                    <Label className="text-xs font-semibold">WhatsApp Number (For Direct RFQ Alerts)</Label>
                    <Input
                      placeholder="e.g. +91 98765 43210"
                      value={personal.whatsappNumber}
                      onChange={e => setPersonal(p => ({ ...p, whatsappNumber: e.target.value }))}
                      className="bg-background text-sm"
                    />
                  </div>

                  <div className="space-y-1.5">
                    <Label className="text-xs font-semibold">Country <span className="text-destructive">*</span></Label>
                    <select
                      value={personal.country}
                      onChange={e => setPersonal(p => ({ ...p, country: e.target.value }))}
                      className="w-full h-9 rounded-md border border-input bg-background px-3 text-sm focus:outline-none focus:ring-1 focus:ring-primary"
                    >
                      {COUNTRIES_LIST.map(c => <option key={c} value={c}>{c}</option>)}
                    </select>
                  </div>

                  <div className="space-y-1.5">
                    <Label className="text-xs font-semibold">State / Province <span className="text-destructive">*</span></Label>
                    <Input
                      placeholder="e.g. Maharashtra, Gujarat, Delhi"
                      value={personal.state}
                      onChange={e => setPersonal(p => ({ ...p, state: e.target.value }))}
                      className="bg-background text-sm"
                    />
                  </div>

                  <div className="space-y-1.5 sm:col-span-2">
                    <Label className="text-xs font-semibold">City <span className="text-destructive">*</span></Label>
                    <Input
                      placeholder="e.g. Mumbai, Ahmedabad, Surat, New Delhi"
                      value={personal.city}
                      onChange={e => setPersonal(p => ({ ...p, city: e.target.value }))}
                      className="bg-background text-sm"
                    />
                  </div>
                </div>
              </CardContent>
            </div>
          )}

          {/* STEP 3: BUSINESS DETAILS */}
          {currentStep === 3 && (
            <div>
              <CardHeader className="pb-4">
                <CardTitle className="text-lg sm:text-xl font-bold flex items-center gap-2">
                  <Building2 className="w-5 h-5 text-primary" />
                  Legal Enterprise & Registration Details
                </CardTitle>
                <CardDescription>
                  Enter your authentic legal company information. This is validated against your business certificates.
                </CardDescription>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                  <div className="space-y-1.5">
                    <Label className="text-xs font-semibold">Legal Business Name <span className="text-destructive">*</span></Label>
                    <Input
                      placeholder="e.g. Apex Precision Forgings Pvt Ltd"
                      value={business.legalName}
                      onChange={e => setBusiness(b => ({ ...b, legalName: e.target.value }))}
                      className="bg-background text-sm"
                    />
                  </div>

                  <div className="space-y-1.5">
                    <Label className="text-xs font-semibold">Brand / Trade Name</Label>
                    <Input
                      placeholder="e.g. Apex Tools (if different)"
                      value={business.brandName}
                      onChange={e => setBusiness(b => ({ ...b, brandName: e.target.value }))}
                      className="bg-background text-sm"
                    />
                  </div>

                  <div className="space-y-1.5">
                    <Label className="text-xs font-semibold">Business Registration / CIN / Udyam</Label>
                    <Input
                      placeholder="e.g. UDYAM-MH-01-0012345"
                      value={business.registrationNumber}
                      onChange={e => setBusiness(b => ({ ...b, registrationNumber: e.target.value }))}
                      className="bg-background text-sm"
                    />
                  </div>

                  <div className="space-y-1.5">
                    <Label className="text-xs font-semibold">GSTIN (India) / Tax ID</Label>
                    <Input
                      placeholder="e.g. 27ABCDE1234F1Z5"
                      value={business.gstNumber}
                      onChange={e => setBusiness(b => ({ ...b, gstNumber: e.target.value.toUpperCase() }))}
                      className="bg-background text-sm font-mono"
                    />
                  </div>

                  <div className="space-y-1.5">
                    <Label className="text-xs font-semibold">PAN Number</Label>
                    <Input
                      placeholder="e.g. ABCDE1234F"
                      value={business.panNumber}
                      onChange={e => setBusiness(b => ({ ...b, panNumber: e.target.value.toUpperCase() }))}
                      className="bg-background text-sm font-mono"
                    />
                  </div>

                  <div className="space-y-1.5">
                    <Label className="text-xs font-semibold">IEC Code (For Import / Export)</Label>
                    <Input
                      placeholder="e.g. 0308994411 (10 Digits)"
                      value={business.iecNumber}
                      onChange={e => setBusiness(b => ({ ...b, iecNumber: e.target.value }))}
                      className="bg-background text-sm font-mono"
                    />
                  </div>

                  <div className="space-y-1.5">
                    <Label className="text-xs font-semibold">Year of Establishment</Label>
                    <Input
                      type="number"
                      placeholder="e.g. 2012"
                      value={business.yearEstablished}
                      onChange={e => setBusiness(b => ({ ...b, yearEstablished: e.target.value }))}
                      className="bg-background text-sm"
                    />
                  </div>

                  <div className="space-y-1.5">
                    <Label className="text-xs font-semibold">Company Website (Optional)</Label>
                    <Input
                      placeholder="https://www.yourcompany.com"
                      value={business.website}
                      onChange={e => setBusiness(b => ({ ...b, website: e.target.value }))}
                      className="bg-background text-sm"
                    />
                  </div>

                  <div className="space-y-1.5 sm:col-span-2">
                    <Label className="text-xs font-semibold">Registered Factory / Office Address</Label>
                    <Input
                      placeholder="Plot No., Industrial Area, Phase II"
                      value={business.address}
                      onChange={e => setBusiness(b => ({ ...b, address: e.target.value }))}
                      className="bg-background text-sm"
                    />
                  </div>

                  <div className="space-y-1.5 sm:col-span-2">
                    <Label className="text-xs font-semibold">Business Overview & Capabilities</Label>
                    <Textarea
                      rows={3}
                      placeholder="Describe your manufacturing facilities, quality control standards, machinery, and wholesale specialties..."
                      value={business.description}
                      onChange={e => setBusiness(b => ({ ...b, description: e.target.value }))}
                      className="bg-background text-sm"
                    />
                  </div>
                </div>
              </CardContent>
            </div>
          )}

          {/* STEP 4: OPERATIONS */}
          {currentStep === 4 && (
            <div>
              <CardHeader className="pb-4">
                <CardTitle className="text-lg sm:text-xl font-bold flex items-center gap-2">
                  <Layers className="w-5 h-5 text-primary" />
                  Product Categories & Supply Operations
                </CardTitle>
                <CardDescription>
                  Configure your primary wholesale categories, minimum order quantities, and delivery capabilities.
                </CardDescription>
              </CardHeader>
              <CardContent className="space-y-5">
                {/* Product Categories */}
                <div className="space-y-2">
                  <Label className="text-xs font-semibold">Primary Product Categories (Select applicable)</Label>
                  <div className="flex flex-wrap gap-2">
                    {PRODUCT_CATEGORIES.map(cat => {
                      const isSelected = selectedCategories.includes(cat);
                      return (
                        <button
                          key={cat}
                          type="button"
                          onClick={() => {
                            if (isSelected) {
                              setSelectedCategories(p => p.filter(c => c !== cat));
                            } else {
                              setSelectedCategories(p => [...p, cat]);
                            }
                          }}
                          className={`text-xs px-3 py-1.5 rounded-full border transition-colors ${
                            isSelected
                              ? 'bg-primary text-white border-primary shadow-sm'
                              : 'bg-background border-border text-foreground hover:bg-muted'
                          }`}
                        >
                          {cat} {isSelected && '✓'}
                        </button>
                      );
                    })}
                  </div>
                </div>

                {/* Specific Products Supplied Tag Input */}
                <div className="space-y-2">
                  <Label className="text-xs font-semibold">Products Manufactured or Procured (Press Enter to add)</Label>
                  <div className="flex gap-2">
                    <Input
                      placeholder="e.g. Stainless Steel Valves, Hydraulic Pumps, Cotton Yarn"
                      value={productInput}
                      onChange={e => setProductInput(e.target.value)}
                      onKeyDown={e => {
                        if (e.key === 'Enter') {
                          e.preventDefault();
                          handleAddProduct();
                        }
                      }}
                      className="bg-background text-sm"
                    />
                    <Button type="button" size="sm" onClick={handleAddProduct} variant="secondary">
                      Add
                    </Button>
                  </div>
                  <div className="flex flex-wrap gap-1.5 mt-2">
                    {productsSupplied.map(p => (
                      <Badge key={p} variant="outline" className="text-xs py-1 px-2.5 border-primary/30 text-foreground gap-1.5">
                        {p}
                        <button type="button" onClick={() => handleRemoveProduct(p)} className="hover:text-destructive text-muted-foreground ml-1">
                          ×
                        </button>
                      </Badge>
                    ))}
                    {productsSupplied.length === 0 && (
                      <p className="text-xs text-muted-foreground italic">No products added yet. Add at least 1-2 product types.</p>
                    )}
                  </div>
                </div>

                {/* MOQ & Capacity */}
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                  <div className="space-y-1.5">
                    <Label className="text-xs font-semibold">Minimum Order Quantity (MOQ)</Label>
                    <Input
                      placeholder="e.g. 50 Units, 500 Kilograms, 1 Container"
                      value={moq}
                      onChange={e => setMoq(e.target.value)}
                      className="bg-background text-sm"
                    />
                  </div>

                  <div className="space-y-1.5">
                    <Label className="text-xs font-semibold">Monthly Production / Supply Capacity</Label>
                    <Input
                      placeholder="e.g. 25,000 Units / Month"
                      value={capacity}
                      onChange={e => setCapacity(e.target.value)}
                      className="bg-background text-sm"
                    />
                  </div>

                  <div className="space-y-1.5">
                    <Label className="text-xs font-semibold">Trade Scope</Label>
                    <select
                      value={tradeType}
                      onChange={e => setTradeType(e.target.value)}
                      className="w-full h-9 rounded-md border border-input bg-background px-3 text-sm focus:outline-none focus:ring-1 focus:ring-primary"
                    >
                      <option value="domestic">Domestic Trade Only (India)</option>
                      <option value="export">International Export Focus</option>
                      <option value="import">Import for Distribution</option>
                      <option value="both">Both Domestic & Global Export</option>
                    </select>
                  </div>

                  <div className="space-y-1.5">
                    <Label className="text-xs font-semibold">Key Countries / Regions Served</Label>
                    <Input
                      placeholder="e.g. India, UAE, USA, Germany, Africa"
                      value={countriesServed.join(', ')}
                      onChange={e => setCountriesServed(e.target.value.split(',').map(s => s.trim()).filter(Boolean))}
                      className="bg-background text-sm"
                    />
                  </div>
                </div>

                {/* Payment Terms & Shipping */}
                <div className="space-y-2">
                  <Label className="text-xs font-semibold">Preferred Payment Terms</Label>
                  <div className="flex flex-wrap gap-2">
                    {PAYMENT_TERMS.map(term => {
                      const isSel = paymentTerms.includes(term);
                      return (
                        <button
                          key={term}
                          type="button"
                          onClick={() => {
                            if (isSel) setPaymentTerms(p => p.filter(t => t !== term));
                            else setPaymentTerms(p => [...p, term]);
                          }}
                          className={`text-xs px-2.5 py-1 rounded-md border transition-colors ${
                            isSel ? 'bg-primary/10 border-primary text-primary font-semibold' : 'bg-background border-border text-foreground hover:bg-muted'
                          }`}
                        >
                          {term}
                        </button>
                      );
                    })}
                  </div>
                </div>

                <div className="space-y-2">
                  <Label className="text-xs font-semibold">Shipping & Dispatch Capabilities</Label>
                  <div className="flex flex-wrap gap-2">
                    {SHIPPING_MODES.map(mode => {
                      const isSel = shippingCapabilities.includes(mode);
                      return (
                        <button
                          key={mode}
                          type="button"
                          onClick={() => {
                            if (isSel) setShippingCapabilities(p => p.filter(m => m !== mode));
                            else setShippingCapabilities(p => [...p, mode]);
                          }}
                          className={`text-xs px-2.5 py-1 rounded-md border transition-colors ${
                            isSel ? 'bg-primary/10 border-primary text-primary font-semibold' : 'bg-background border-border text-foreground hover:bg-muted'
                          }`}
                        >
                          {mode}
                        </button>
                      );
                    })}
                  </div>
                </div>
              </CardContent>
            </div>
          )}

          {/* STEP 5: VERIFICATION & COMPLETION */}
          {currentStep === 5 && (
            <div>
              <CardHeader className="pb-4">
                <CardTitle className="text-lg sm:text-xl font-bold flex items-center gap-2">
                  <ShieldCheck className="w-5 h-5 text-primary" />
                  Business Verification & Document Upload
                </CardTitle>
                <CardDescription>
                  Upload your legitimate business registration documents to earn the BulkSkart Verified badge and unlock high-value RFQ matching.
                </CardDescription>
              </CardHeader>
              <CardContent className="space-y-6">
                {/* Status Indicator Banner */}
                <div className={`p-4 rounded-xl border flex items-center justify-between gap-3 ${
                  verificationStatus === 'verified'
                    ? 'bg-emerald-500/10 border-emerald-500/30 text-emerald-600 dark:text-emerald-400'
                    : verificationStatus === 'pending'
                    ? 'bg-amber-500/10 border-amber-500/30 text-amber-600 dark:text-amber-400'
                    : verificationStatus === 'rejected'
                    ? 'bg-destructive/10 border-destructive/30 text-destructive'
                    : 'bg-muted/50 border-border text-muted-foreground'
                }`}>
                  <div className="flex items-center gap-3">
                    <Shield className="w-5 h-5 shrink-0" />
                    <div>
                      <p className="font-semibold text-sm">
                        Verification Status: {verificationStatus === 'verified' ? 'Verified Enterprise' : verificationStatus === 'pending' ? 'Documents Pending Review' : verificationStatus === 'rejected' ? 'Verification Rejected' : 'Not Submitted (Unverified)'}
                      </p>
                      <p className="text-xs opacity-90">
                        {verificationStatus === 'verified'
                          ? 'Your enterprise has passed KYC and is authorized for high-volume transactions.'
                          : verificationStatus === 'pending'
                          ? 'Our compliance team reviews documents within 1-2 business days.'
                          : 'Upload certificates below to request official verification.'}
                      </p>
                    </div>
                  </div>
                  <Badge variant="outline" className="shrink-0 text-xs uppercase font-bold">
                    {verificationStatus}
                  </Badge>
                </div>

                {/* Upload Cards Grid */}
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                  {/* GST Document */}
                  <div className="p-4 rounded-xl border border-border bg-background space-y-3">
                    <div className="flex items-start justify-between">
                      <div>
                        <p className="text-sm font-semibold text-foreground">GST Registration Certificate</p>
                        <p className="text-xs text-muted-foreground">PDF or JPG/PNG image of Form REG-06</p>
                      </div>
                      {docs.gstDocUrl ? (
                        <Badge className="bg-emerald-500 text-white text-[10px] gap-1">
                          <Check className="w-3 h-3" /> Uploaded
                        </Badge>
                      ) : (
                        <Badge variant="secondary" className="text-[10px]">Pending</Badge>
                      )}
                    </div>
                    <div>
                      <label className="cursor-pointer">
                        <input
                          type="file"
                          accept=".pdf,image/*"
                          className="hidden"
                          onChange={e => {
                            const file = e.target.files?.[0];
                            if (file) handleUploadDoc(file, 'gst');
                          }}
                        />
                        <div className="h-9 w-full rounded-md border border-dashed border-primary/40 hover:bg-primary/5 flex items-center justify-center gap-2 text-xs text-primary font-medium transition-colors">
                          <Upload className="w-3.5 h-3.5" />
                          {uploadingDoc === 'gst' ? 'Uploading...' : docs.gstDocUrl ? 'Replace GST Document' : 'Upload GST Certificate'}
                        </div>
                      </label>
                    </div>
                  </div>

                  {/* PAN Card */}
                  <div className="p-4 rounded-xl border border-border bg-background space-y-3">
                    <div className="flex items-start justify-between">
                      <div>
                        <p className="text-sm font-semibold text-foreground">Company / Proprietor PAN Card</p>
                        <p className="text-xs text-muted-foreground">Official Income Tax Department PAN</p>
                      </div>
                      {docs.panDocUrl ? (
                        <Badge className="bg-emerald-500 text-white text-[10px] gap-1">
                          <Check className="w-3 h-3" /> Uploaded
                        </Badge>
                      ) : (
                        <Badge variant="secondary" className="text-[10px]">Pending</Badge>
                      )}
                    </div>
                    <div>
                      <label className="cursor-pointer">
                        <input
                          type="file"
                          accept=".pdf,image/*"
                          className="hidden"
                          onChange={e => {
                            const file = e.target.files?.[0];
                            if (file) handleUploadDoc(file, 'pan');
                          }}
                        />
                        <div className="h-9 w-full rounded-md border border-dashed border-primary/40 hover:bg-primary/5 flex items-center justify-center gap-2 text-xs text-primary font-medium transition-colors">
                          <Upload className="w-3.5 h-3.5" />
                          {uploadingDoc === 'pan' ? 'Uploading...' : docs.panDocUrl ? 'Replace PAN Card' : 'Upload PAN Card'}
                        </div>
                      </label>
                    </div>
                  </div>

                  {/* IEC Certificate */}
                  <div className="p-4 rounded-xl border border-border bg-background space-y-3">
                    <div className="flex items-start justify-between">
                      <div>
                        <p className="text-sm font-semibold text-foreground">Import Export Code (IEC)</p>
                        <p className="text-xs text-muted-foreground">DGFT issued Certificate for foreign trade</p>
                      </div>
                      {docs.iecDocUrl ? (
                        <Badge className="bg-emerald-500 text-white text-[10px] gap-1">
                          <Check className="w-3 h-3" /> Uploaded
                        </Badge>
                      ) : (
                        <Badge variant="secondary" className="text-[10px]">Optional</Badge>
                      )}
                    </div>
                    <div>
                      <label className="cursor-pointer">
                        <input
                          type="file"
                          accept=".pdf,image/*"
                          className="hidden"
                          onChange={e => {
                            const file = e.target.files?.[0];
                            if (file) handleUploadDoc(file, 'iec');
                          }}
                        />
                        <div className="h-9 w-full rounded-md border border-dashed border-primary/40 hover:bg-primary/5 flex items-center justify-center gap-2 text-xs text-primary font-medium transition-colors">
                          <Upload className="w-3.5 h-3.5" />
                          {uploadingDoc === 'iec' ? 'Uploading...' : docs.iecDocUrl ? 'Replace IEC Document' : 'Upload IEC Certificate'}
                        </div>
                      </label>
                    </div>
                  </div>

                  {/* Company Registration / Udyam */}
                  <div className="p-4 rounded-xl border border-border bg-background space-y-3">
                    <div className="flex items-start justify-between">
                      <div>
                        <p className="text-sm font-semibold text-foreground">Udyam / MSME / Incorporation</p>
                        <p className="text-xs text-muted-foreground">Ministry of MSME / MCA Incorporation</p>
                      </div>
                      {docs.regDocUrl ? (
                        <Badge className="bg-emerald-500 text-white text-[10px] gap-1">
                          <Check className="w-3 h-3" /> Uploaded
                        </Badge>
                      ) : (
                        <Badge variant="secondary" className="text-[10px]">Optional</Badge>
                      )}
                    </div>
                    <div>
                      <label className="cursor-pointer">
                        <input
                          type="file"
                          accept=".pdf,image/*"
                          className="hidden"
                          onChange={e => {
                            const file = e.target.files?.[0];
                            if (file) handleUploadDoc(file, 'reg');
                          }}
                        />
                        <div className="h-9 w-full rounded-md border border-dashed border-primary/40 hover:bg-primary/5 flex items-center justify-center gap-2 text-xs text-primary font-medium transition-colors">
                          <Upload className="w-3.5 h-3.5" />
                          {uploadingDoc === 'reg' ? 'Uploading...' : docs.regDocUrl ? 'Replace Certificate' : 'Upload Registration Document'}
                        </div>
                      </label>
                    </div>
                  </div>
                </div>

                {/* Completion summary */}
                <div className="p-4 rounded-xl bg-card border border-border text-xs space-y-2 text-muted-foreground">
                  <div className="flex items-center gap-2 text-foreground font-semibold">
                    <Info className="w-4 h-4 text-primary shrink-0" />
                    <span>Next steps after profile completion</span>
                  </div>
                  <ul className="list-disc list-inside space-y-1 pl-1">
                    <li>Your profile details are stored securely under your authenticated account ID.</li>
                    <li>If documents are uploaded, verification status switches to Pending Review.</li>
                    <li>You can update products, capacity, and credentials anytime from your Profile Settings.</li>
                  </ul>
                </div>
              </CardContent>
            </div>
          )}

          {/* Navigation Controls Footer */}
          <div className="border-t border-border p-4 sm:p-5 flex flex-col-reverse sm:flex-row items-center justify-between gap-3 bg-card/50">
            <div>
              {currentStep > 1 && (
                <Button
                  type="button"
                  variant="outline"
                  onClick={() => setCurrentStep(p => p - 1)}
                  disabled={saving || completing}
                  className="w-full sm:w-auto text-xs gap-1.5"
                >
                  <ArrowLeft className="w-3.5 h-3.5" /> Back: {steps[currentStep - 2]?.title}
                </Button>
              )}
            </div>

            <div className="flex items-center gap-2 w-full sm:w-auto">
              <Button
                type="button"
                variant="outline"
                onClick={handleSaveDraft}
                disabled={saving || completing}
                className="flex-1 sm:flex-initial text-xs gap-1.5"
              >
                <Save className="w-3.5 h-3.5" />
                {saving ? 'Saving...' : 'Save Draft'}
              </Button>

              {currentStep < 5 ? (
                <Button
                  type="button"
                  onClick={() => setCurrentStep(p => p + 1)}
                  disabled={saving || completing}
                  className="flex-1 sm:flex-initial bg-primary text-white hover:bg-primary/90 text-xs gap-1.5"
                >
                  Next Step <ArrowRight className="w-3.5 h-3.5" />
                </Button>
              ) : (
                <Button
                  type="button"
                  onClick={handleCompleteProfile}
                  disabled={completing || saving}
                  className="flex-1 sm:flex-initial bg-emerald-600 hover:bg-emerald-700 text-white text-xs gap-1.5 font-bold shadow-md"
                >
                  {completing ? 'Completing Profile...' : 'Complete Profile & Launch'}
                  <CheckCircle2 className="w-4 h-4" />
                </Button>
              )}
            </div>
          </div>
        </Card>
      </main>
    </div>
  );
}
