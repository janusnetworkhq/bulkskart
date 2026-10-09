# Requirements Document

## 1. Application Overview

**Application Name:** BulkSkart

**Canonical Domain:** https://www.bulkskart.com/

**Description:** BulkSkart is an enterprise B2B bulk marketplace connecting verified corporate buyers, wholesalers, global manufacturers, and suppliers. The platform provides authenticated requirement posting, contact privacy gating, dynamic supplier profiles, product catalog discovery, 24-hour fast-track selling listings, monthly supplier subscription plans, Razorpay payment processing for subscriptions and product promotions, role-based dashboards with strict user data isolation, a subscription paywall for product uploads, and a step-by-step business profile onboarding wizard.

**Official Brand Logo & Icon:** https://miaoda-conversation-file.s3cdn.medo.dev/user-c66crxlkwiyo/app-egd29h5g4zcx/20261001/file_00000000d23882108053eabe32a6195d.png

**Design & Aesthetic Style:**
- Visual Theme: Premium Global B2B Marketplace styling with deep black and navy background (#070B14 / #0B1120), glassmorphism cards, and metallic slate borders.
- Brand Accents: BulkSkart Orange (#F97316 / #EA580C) for primary CTAs, active badges, and highlights; Cyan and Electric Blue (#00D2FF / #3B82F6) for trade routes and maritime port nodes.
- Typography & Density: Compact B2B information density with uniform button heights, padding, and baseline alignment across all screen sizes.
- Desktop & Laptop Viewport Fitting: Proportional layout scaling optimized for standard laptop and PC resolutions (1280px to 1920px wide with standard and high-DPI scaling), eliminating excessive vertical gaps, clipped headers, and horizontal overflowing.
- Floating Widget Management: Intelligent z-index, offset, and non-overlapping positioning for bottom floating tools (Live RFQs widget and AI Trade Help chatbot) ensuring clear visibility and access to bottom buttons and footer content.

## 2. Users and Usage Scenarios

**Target User Roles:**
- Guest Visitor: Browses the homepage, categories, supplier directory, 24-hour selling items, and public RFQs. Promoted to register or log in when accessing protected features.
- Buyer: Authenticated buyer who completes the business profile onboarding wizard, posts RFQs, tracks quotation responses, and manages inquiries within an isolated Buyer Dashboard.
- Supplier / Manufacturer: Authenticated seller who completes the business profile onboarding wizard, subscribes to a paid monthly plan, promotes catalog listings via Razorpay, manages catalog listings and inventory, responds to buyer RFQs, and monitors leads within an isolated Supplier Dashboard.
- Administrator: Manages verification credentials, directory taxonomies, and subscription/promotion records.

**Core Usage Scenarios:**
- A buyer or supplier accesses the homepage on a laptop or desktop and immediately views the top categories, verified suppliers carousel, featured bulk products, and 24-hour fast-track selling items with fast loading speed, balanced spacing, and zero layout shifts.
- A visitor browses homepage sections (Explore Bulk Product Categories, Verified Suppliers Carousel, Featured Bulk Products Grid, Fast-Track Sourcing & Selling Workflows, Sell Products in 24 Hours, Transparent Monthly Supplier Plans, and India Premier B2B Buying & Wholesale Platform) with no clipped headers or content overlaps from bottom floating widgets.
- An authenticated supplier opens the Product Promotion flow from their dashboard, selects a promotion plan, completes Razorpay checkout without payment gateway errors, and sees their listing immediately promoted.
- A user browses the homepage 24-hour selling section and views real-time active fast-track lots with live countdown timers synchronized with the Auctions Hub.
- An authenticated supplier accesses their dashboard and views strictly their own isolated business details, products, inventory, RFQs, and metrics, seeing legitimate empty states when no products have been added.

## 3. Page Structure and Functional Description

### 3.1 Page Hierarchy

```
BulkSkart Platform (https://www.bulkskart.com/)
├── Homepage (/)
│   ├── Top Navigation Header & Global Search
│   ├── Hero & High-Level Category Quick Navigation
│   ├── Explore Bulk Product Categories
│   ├── Verified Suppliers Carousel
│   ├── Featured Bulk Products Grid
│   ├── Fast-Track Sourcing & Selling Workflows
│   ├── Sell Products in 24 Hours (Active Fast-Track & Liquidation Batches)
│   ├── Live Buying Requirements Feed
│   ├── Global Trade Routes Map
│   ├── Post Requirements Inline Form
│   ├── Transparent Monthly Supplier Plans
│   ├── India Premier B2B Buying & Wholesale Platform (Trust & Features)
│   ├── Testimonials & Reviews Carousel
│   └── Footer
├── Authentication
│   ├── User Registration (/register)
│   ├── User Login (/login)
│   └── Business Onboarding Wizard (/onboarding/business-profile)
├── Product & Supplier Discovery
│   ├── Bulk Products Catalog (/bulk-products)
│   ├── Categories Overview (/categories)
│   ├── Category Detail (/category/:slug)
│   ├── Product Detail (/products/:slug)
│   ├── Global Verified Suppliers Directory (/suppliers)
│   └── Dynamic Supplier Profile (/suppliers/:slug, /manufacturers/:slug, /company/:slug)
├── Sourcing & RFQ Engine
│   ├── Post Requirement (/post-requirement)
│   ├── Requirements Hub (/requirements)
│   └── Requirement Detail (/requirements/:id)
├── Fast-Track 24-Hour Selling & Auctions
│   ├── 24-Hour Selling Hub (/auctions)
│   ├── Create 24-Hour Listing (/auctions/create)
│   └── 24-Hour Item Detail (/auctions/:id)
├── Pricing & Subscription (/pricing)
├── Buyer Dashboard (/dashboard/buyer)
├── Supplier Dashboard (/dashboard/supplier)
│   ├── Supplier Overview (/dashboard/supplier)
│   ├── My Products (/dashboard/supplier/products)
│   │   ├── Promote Product Dialog (Razorpay Checkout Integration)
│   │   └── Product Promotions Panel (Active Promotion Tracking)
│   ├── Inventory & Stock (/dashboard/supplier/inventory)
│   ├── Matched Opportunities (/dashboard/supplier/rfqs)
│   └── My Submitted Quotes (/dashboard/supplier/quotes)
└── Floating Utility Widgets (Global)
    ├── Live RFQs Ticker Widget (Bottom Left / Bottom Float)
    └── AI Trade Help Chatbot Widget (Bottom Right Float)
```

### 3.2 Homepage Architecture & Section Responsiveness

- Top Navigation Header & Global Search: Brand logo, category dropdown, keyword search bar, country selector, and user account/login controls.
- Hero & High-Level Category Quick Navigation: Primary banner highlighting marketplace value proposition and direct category shortcuts.
- Explore Bulk Product Categories: Responsive grid layout presenting primary industrial categories with balanced card padding and unclipped category title headings.
- Verified Suppliers Carousel: Horizontal supplier cards positioned immediately above featured products, featuring verified badges, main supply categories, and direct profile shortcuts with left/right navigation controls.
- Featured Bulk Products Grid: Positioned after verified suppliers, displaying wholesale pricing, minimum order quantities (MOQ), and inquiry triggers.
- Fast-Track Sourcing & Selling Workflows: Responsive workflow step cards detailing the RFQ sourcing and 24-hour fast selling process with proportional vertical spacing.
- Sell Products in 24 Hours: Dynamic grid querying active fast-track listings and liquidation lots directly from the auction inventory dataset. Renders listing thumbnail, lot title, current bid or wholesale price, remaining lot stock, and live countdown timer. When active listings exist, displays the lot cards with an action button linking to the auction lot detail; falls back to the clean empty state only when active listing count is strictly zero.
- Live Buying Requirements: Dynamic demand feed showcasing active RFQs with direct quote actions.
- Global Trade Routes: Interactive world map showcasing major logistics hub ports and supply corridors.
- Post Requirements Inline Form: Direct RFQ submission form supporting file attachments.
- Transparent Monthly Supplier Plans: Clean 3-tier pricing layout (Starter, Professional, Enterprise) highlighting features, monthly fees, and direct Razorpay checkout triggers.
- India Premier B2B Buying & Wholesale Platform: Trust metrics, enterprise verification highlights, and platform advantages formatted for 1280px-1920px viewports without awkward text wraps or container overflows.
- Floating Widgets Layout: Live RFQs floating widget and AI Trade Help chatbot maintain calculated clearance from screen borders, footer controls, and CTA buttons, preventing UI obstruction.

### 3.3 Product Promotion Flow & Payment Integration

#### 3.3.1 Promote Product Dialog (`PromoteProductDialog`)
- Trigger: Accessible directly from product listings within the Supplier Dashboard (`/dashboard/supplier/products`).
- Promotion Tier Selection: Allows suppliers to select promotion durations and visibility levels (e.g., 7 Days Featured, 14 Days Category Top, 30 Days Global Spotlight).
- Order Creation & Checkout: Calls the backend payment initialization endpoint to generate a valid Razorpay Order ID and passes authorized credentials to the Razorpay checkout handler.
- Client-Side Payment Verification: Captures Razorpay payment response (payment ID, order ID, signature), triggers backend payment signature verification, and transitions the promotion status to Active upon successful confirmation.
- Error Handling: Catches gateway initialization failures, missing configuration parameters, or payment dismissal, providing informative retry prompts without breaking the modal state.

#### 3.3.2 Product Promotions Panel (`ProductPromotionsPanel`)
- Promotion Management: Displays currently active, scheduled, and past promotional campaigns associated with the authenticated supplier's products.
- Campaign Metrics: Tracks promotion start date, expiration date, active placement tier, impressions, and click-through inquiries.
- Renewal Action: Direct one-click renewal triggering the Promote Product Dialog.

### 3.4 Authentication & Business Onboarding Wizard

#### 3.4.1 User Registration & Login (/register, /login)
- Registration Flow: Collects email/phone and password, establishes an authenticated user session, and directs new accounts to the Business Profile Setup Wizard.
- Login Flow: Authenticates credentials, cleans stale local cache, and binds the session strictly to the authenticated user ID.

#### 3.4.2 Business Profile Setup Wizard (/onboarding/business-profile)
- Step 1: Account Type Selection: Selects role (Buyer, Manufacturer, Wholesaler, Distributor, Importer, Exporter).
- Step 2: Personal Details: Inputs for Full Name, Email, Mobile Number, WhatsApp Number, Country, State, and City.
- Step 3: Business Details: Inputs for Legal Business Name, Brand Name, Business Type, Registration Number, GSTIN, PAN, Import Export Code (IEC), Registered Address, Website URL, Year Established, and Business Description.
- Step 4: Business Operations: Multi-select categories, products supplied, MOQ range, production capacity, operational scope, countries served, payment terms, and delivery modes.
- Step 5: Verification & Completion: File upload for registration and tax certificates, verification status indicator, Save Draft action, and Complete Profile action.

### 3.5 Dashboards (Strict User Isolation & Subscription Gating)

#### 3.5.1 Buyer Dashboard (/dashboard/buyer)
- Profile Overview Card: Real user business name, role badge, contact details, profile completion percentage, and verification status.
- My Requirements: RFQs submitted by the logged-in buyer with status and quote count. Displays an empty state when count is zero.
- Received Quotations: Supplier quotations received for the user's RFQs.
- Direct Inquiries & Messages: Isolated message threads between the buyer and suppliers.

#### 3.5.2 Supplier Dashboard (/dashboard/supplier)
- Profile Overview Card: Real supplier business name, verification badge, active subscription tier badge, and edit profile action.
- My Products (/dashboard/supplier/products): Displays exclusively the products uploaded by the logged-in supplier's company. For suppliers with zero products, displays a dedicated empty state with an 「Add Product」 CTA. Includes the 「Promote」 action button on listed products opening the Promote Product Dialog.
- Inventory & Stock (/dashboard/supplier/inventory): Displays inventory levels strictly for the logged-in supplier's own products.
- Product Creation Flow & Subscription Paywall:
  + Subscribed Suppliers: Clicking 「+ Add Product」 opens the product upload form.
  + Unsubscribed Suppliers: Clicking 「+ Add Product」 triggers the subscription paywall modal or redirects to `/pricing`.
- My Submitted Quotes: Quotes sent by the supplier to buyer RFQs.
- Matched Opportunities Feed: Real-time buyer RFQs matched with supplier registered categories.

## 4. Business Rules and Core Logic

### 4.1 24-Hour Fast-Track Selling Feed Synchronization
1. Active Listing Query: The homepage 「Sell Products in 24 Hours」 section queries active listings from the central 24-hour selling lot dataset where status is active and expiration timestamp is greater than the current timestamp.
2. Dynamic Synchronization: Any lot created or updated via the 24-Hour Selling Hub (`/auctions`) automatically reflects in the homepage feed without requiring hardcoded updates.
3. Empty State Logic: The fallback state 「No live auctions currently」 is rendered only when the queried active listing count is zero.

### 4.2 Product Promotion Payment Processing
1. Order Generation: Every promotion checkout initiation creates a unique backend payment order through Razorpay with the specified promotion tier amount and currency.
2. Signature Verification: Upon completion of the Razorpay modal interaction, the client submits the transaction signature to the verification endpoint. The promotion tier is activated only after cryptographic validation succeeds.
3. Failed/Cancelled Transactions: If the transaction is declined or closed by the user, the promotion state remains unchanged and the user is provided a retry option.

### 4.3 Homepage Performance Optimization & Data Fetching
1. Request Deduplication: Homepage API queries for categories, suppliers, featured products, and 24-hour lots are consolidated and deduplicated on initial load.
2. Client-Side Caching: Non-critical catalog metadata is cached client-side to prevent redundant network round-trips on route re-entry.
3. Layout Stability: Image containers and dynamic card grids retain fixed aspect ratios and min-height constraints during loading to prevent visual layout shifts.

### 4.4 Desktop & Laptop Viewport Fitting Rules
1. Dynamic Width Constraints: Container max-width scales across 1280px, 1366px, 1440px, 1536px, and 1920px viewports without horizontal clipping or awkward margins.
2. Balanced Spacing: Section vertical padding scales proportionally to eliminate excessive blank areas between homepage sections.
3. Grid Auto-fit: Product, category, and supplier card grids adjust column counts dynamically to maintain proportional card dimensions across laptop and desktop screens.
4. Floating Widget Collision Avoidance: Bottom floating widgets (Live RFQs and AI Trade Help) maintain clearance offsets to ensure they never overlap interactive buttons, table pagination, or footer links.

### 4.5 Strict Supplier Catalog Isolation
1. Ownership Scoping: All catalog and inventory queries are strictly filtered by the authenticated supplier's company ID.
2. Zero Default Mock Products: Newly registered suppliers must never see platform-curated or demo products in their dashboard management views.

### 4.6 Subscription Paywall for Product Uploads
1. Subscription Status Check: Product creation is restricted to suppliers with an active paid plan.
2. Paywall Interception: Unsubscribed suppliers attempting product creation are redirected to the pricing comparison view or shown the subscription upgrade modal.

## 5. Exception and Boundary Conditions

| Scenario | System Handling |
|---|---|
| Supplier initiates product promotion but Razorpay modal fails to initialize | Displays an error notice 「Unable to connect to payment gateway. Please check your network or try again」 and retains modal state without charging |
| Supplier cancels or closes the Razorpay checkout window | Closes the payment overlay, returns to promotion dialog, and leaves listing status as unpromoted |
| Active 24-hour fast-track listings exist in database | Queries and renders active lot cards with live countdown timers on the homepage instead of empty state |
| All 24-hour fast-track listings have expired | Displays clean empty state: 「No live auctions currently. Check back soon for new flash inventory!」 |
| Homepage loaded on high-resolution laptop (e.g., 1080p at 125%/150% scaling) | Containers and grids adjust column counts proportionally without horizontal overflow or clipped section titles |
| Floating widgets render near footer or bottom CTA buttons | Floating containers maintain fixed offset and z-index separation so underlying buttons remain clickable |
| Unsubscribed supplier attempts to add product | Intercepts action and displays subscription upgrade modal linking to `/pricing` |
| Newly registered supplier visits My Products | Displays empty state 「No products added yet」 with 「Add Product」 CTA and zero mock listings |

## 6. Acceptance Criteria

1. The homepage renders the Verified Suppliers section immediately after the Explore Bulk Product Categories / Hero area, positioned directly above the Featured Bulk Products Grid.
2. Homepage sections render with balanced container widths, unclipped headings, and proportional vertical spacing on 1280px to 1920px desktop and laptop displays.
3. Floating widgets ('Live RFQs' and 'AI Trade Help') do not overlap or block interactive buttons, modals, or footer controls.
4. Homepage data fetching is optimized with deduplicated requests, client-side caching, and zero layout shifts during page render.
5. The homepage 'Sell Products in 24 Hours' section queries and displays live fast-track listings with real-time countdown timers synchronized with the Auctions Hub when active listings exist.
6. Opening the Promote Product Dialog and selecting a promotion tier successfully initializes Razorpay checkout, processes valid payment verification, and activates the promotion without payment gateway errors.
7. Navigating to 'My Products' or 'Inventory & Stock' as a newly registered supplier displays a clean empty state with zero pre-populated mock or curated products.
8. Unpaid suppliers clicking 'Add Product' are intercepted by the subscription paywall modal or redirected to the pricing page.
9. Logging in with any account displays strictly the authenticated user's own profile, business data, and catalog listings with strict user isolation.
10. The 5-step Business Profile Setup Wizard captures all required personal, business, operational, and verification details.

## 7. Out of Scope for This Release

- Third-party AI image generation tools in RFQ or product attachment forms
- Annual or multi-year subscription billing tiers
- In-browser peer-to-peer VoIP audio and video calling
- Direct customs tax calculation and clearing integration with port authorities
- Cryptocurrency or token-based settlement payments