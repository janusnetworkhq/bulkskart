INSERT INTO companies (
  id, owner_id, company_name, slug, tagline, description, business_type,
  city, state, country, website, is_verified, verification_status, is_featured,
  total_products, years_in_business, year_established, employee_count_range,
  annual_turnover_range, production_capacity, export_destinations,
  payment_terms, key_products, rating_avg, review_count,
  cover_url, logo_url
) VALUES
-- 1. Germany - Bavaria Precision Hydraulics GmbH
(
  'e1000001-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', 'Bavaria Precision Hydraulics GmbH', 'bavaria-precision-hydraulics',
  'German High-Precision Hydraulic Valves, Cylinders & Heavy Industrial Actuators',
  'Established in Munich in 1988, Bavaria Precision Hydraulics is a leading European OEM manufacturer of high-pressure proportional valves, telescopic hydraulic cylinders, and bespoke electro-hydraulic systems. Serving construction, aerospace, and energy industries with DIN/ISO certified precision.',
  'Manufacturer / OEM', 'Munich', 'Bavaria', 'Germany', 'https://www.bavariaprecision-hydraulics.de',
  true, 'verified', true, 2, 36, 1988, '250-500 employees', 'USD 50M - 100M', '45,000 units/month',
  ARRAY['United States', 'Japan', 'United Kingdom', 'India', 'Brazil', 'South Korea'],
  ARRAY['T/T (Telegraphic Transfer)', 'L/C (Letter of Credit)', 'Net 60'],
  ARRAY['Proportional Hydraulic Valves', 'Telescopic Cylinders', 'Rotary Actuators'],
  4.9, 42,
  'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_206d733c-1a07-4864-831d-8d0b40e8d664.jpg',
  'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_788afc34-8703-44d6-840e-cd5895904a4f.jpg'
),
-- 2. Germany - Rheinland Bio-Polymer Werk AG
(
  'e1000001-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000001', 'Rheinland Bio-Polymer Werk AG', 'rheinland-bio-polymer',
  'Industrial Grade Biodegradable Resins, PLA Pellets & Bio-Engineering Plastics',
  'Headquartered in Düsseldorf, Rheinland Bio-Polymer pioneers sustainable industrial resins, certified compostable PLA granules, and heat-resistant bio-polymers engineered for high-throughput injection molding and packaging extruders across 40+ countries.',
  'Chemical Manufacturer', 'Düsseldorf', 'North Rhine-Westphalia', 'Germany', 'https://www.rheinland-biopolymer.de',
  true, 'verified', true, 1, 22, 2002, '100-250 employees', 'USD 25M - 50M', '12,000 metric tons/year',
  ARRAY['United States', 'United Kingdom', 'France', 'Japan', 'UAE', 'Australia'],
  ARRAY['T/T', 'L/C', 'CAD (Cash Against Documents)'],
  ARRAY['Industrial PLA Granules', 'Bio-PBS Resins', 'Compostable Film Pellets'],
  4.85, 31,
  'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_3dd25eca-4769-4842-bd0b-792905f3b2f3.jpg',
  'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_fd32cf11-5976-4705-b523-1eac69a5514f.jpg'
),
-- 3. USA - Apex Micro-Power Dynamics Inc.
(
  'e1000001-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000001', 'Apex Micro-Power Dynamics Inc.', 'apex-micropower-dynamics',
  'Next-Gen GaN Fast-Charging Power Modules & Industrial Power Converters',
  'Based in Austin, Texas, Apex Micro-Power Dynamics designs and manufactures industrial-grade Gallium Nitride (GaN) power supplies, bidirectional DC-DC converters for electric vehicle charging infrastructure, and high-density server power modules.',
  'Technology Manufacturer', 'Austin', 'Texas', 'USA', 'https://www.apexmicropower.com',
  true, 'verified', true, 1, 14, 2010, '100-250 employees', 'USD 30M - 60M', '250,000 units/month',
  ARRAY['Germany', 'Japan', 'United Kingdom', 'South Korea', 'India', 'Canada'],
  ARRAY['Credit Card / Escrow', 'Wire Transfer T/T', 'L/C'],
  ARRAY['GaN Power Modules', 'Bidirectional DC-DC Converters', 'Server Power Supplies'],
  4.92, 38,
  'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_d6f9b3ff-984e-42e1-a38f-ba8c1a2c5776.jpg',
  'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_4762d137-8b97-4d44-97fd-87d59b2a85f4.jpg'
),
-- 4. USA - Pacific Northwest Timber Corp.
(
  'e1000001-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000001', 'Pacific Northwest Timber Corp.', 'pacific-timber-composite',
  'FSC Certified Structural Glulam Beams & Acoustic Architectural Wall Panels',
  'Pacific Northwest Timber provides commercial builders, architects, and wholesale distributors worldwide with sustainable Douglas Fir glulam structural timbers, acoustic architectural slat wood panels, and exterior thermally modified decking.',
  'Manufacturer & Mill', 'Portland', 'Oregon', 'USA', 'https://www.pnwtimbercomposite.com',
  true, 'verified', true, 1, 29, 1995, '250-500 employees', 'USD 75M - 120M', '350,000 board feet/month',
  ARRAY['Japan', 'United Kingdom', 'Germany', 'Australia', 'UAE'],
  ARRAY['L/C', 'T/T 30/70', 'Wire Transfer'],
  ARRAY['Structural Glulam Beams', 'Acoustic Slat Wood Panels', 'Thermally Modified Decking'],
  4.88, 27,
  'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_7610e66a-3949-479c-8b48-643cc7d2b63f.jpg',
  'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_ba175bf8-9522-42e1-8d07-eb1a54b79101.jpg'
),
-- 5. Japan - Kyoto Advanced Opto-Electronics Co.
(
  'e1000001-0000-0000-0000-000000000005', '00000000-0000-0000-0000-000000000001', 'Kyoto Advanced Opto-Electronics Co.', 'kyoto-advanced-opto',
  'Sub-Micron Laser Sensors, Telecentric Machine Vision Lenses & Optical Filters',
  'Kyoto Advanced Opto-Electronics specializes in extreme precision laser displacement sensors, robotic telecentric lenses, and optical quartz filters used in semiconductor fabrication, medical robotics, and automated aerospace inspection.',
  'Precision Optics Manufacturer', 'Kyoto', 'Kansai', 'Japan', 'https://www.kyoto-opto.co.jp',
  true, 'verified', true, 1, 41, 1983, '500+ employees', 'USD 100M+', '60,000 optical units/month',
  ARRAY['United States', 'Germany', 'South Korea', 'Taiwan', 'United Kingdom', 'India'],
  ARRAY['L/C at Sight', 'T/T', 'Irrevocable Confirmed L/C'],
  ARRAY['Sub-Micron Laser Sensors', 'Telecentric Machine Lenses', 'Optical Waveguide Filters'],
  4.96, 54,
  'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_d6f9b3ff-984e-42e1-a38f-ba8c1a2c5776.jpg',
  'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_206d733c-1a07-4864-831d-8d0b40e8d664.jpg'
),
-- 6. Japan - Nippon High-Purity Alloys K.K.
(
  'e1000001-0000-0000-0000-000000000006', '00000000-0000-0000-0000-000000000001', 'Nippon High-Purity Alloys K.K.', 'nippon-alloys-ceramics',
  'Thermal Conductive Silicon Nitride Substrates & Tungsten Carbide Tooling',
  'Operating advanced sintering furnaces in Nagoya, Nippon High-Purity Alloys produces ultra-high thermal conductivity silicon nitride ceramic substrates for EV traction inverters and CNC tungsten carbide endmills.',
  'Materials Manufacturer', 'Nagoya', 'Aichi', 'Japan', 'https://www.nippon-alloys.co.jp',
  true, 'verified', true, 1, 35, 1989, '250-500 employees', 'USD 50M - 100M', '800,000 ceramic plates/month',
  ARRAY['Germany', 'United States', 'South Korea', 'Italy', 'Vietnam'],
  ARRAY['T/T', 'L/C', 'Net 45'],
  ARRAY['Silicon Nitride Substrates', 'Solid Carbide Endmills', 'Titanium Grade 5 Billets'],
  4.91, 33,
  'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_206d733c-1a07-4864-831d-8d0b40e8d664.jpg',
  'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_788afc34-8703-44d6-840e-cd5895904a4f.jpg'
),
-- 7. South Korea - Hana Smart Energy & Battery Corp.
(
  'e1000001-0000-0000-0000-000000000007', '00000000-0000-0000-0000-000000000001', 'Hana Smart Energy & Battery Corp.', 'hana-energy-battery',
  'Tier-1 Commercial LiFePO4 Energy Storage Racks & EV Battery Modules',
  'Daejeon-based battery technology conglomerate providing commercial & industrial energy storage systems (ESS), modular 48V/100Ah LiFePO4 battery packs, and smart IoT Battery Management System (BMS) controllers.',
  'Clean Energy Manufacturer', 'Daejeon', 'Chungcheong', 'South Korea', 'https://www.hana-energytech.kr',
  true, 'verified', true, 1, 16, 2008, '500+ employees', 'USD 150M+', '500 MWh annually',
  ARRAY['United States', 'Germany', 'Australia', 'United Kingdom', 'UAE', 'India'],
  ARRAY['Irrevocable L/C', 'T/T', 'Escrow'],
  ARRAY['Commercial ESS Battery Racks', '48V LiFePO4 Battery Packs', 'High-Voltage Smart BMS'],
  4.94, 49,
  'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_0fd5c97f-69b3-43ce-af7f-a4fa1212e785.jpg',
  'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_f6b7c576-892d-4de4-ae52-8bd0d196aa32.jpg'
),
-- 8. South Korea - Seoul Eco-Tech Polymers & Technical Textiles
(
  'e1000001-0000-0000-0000-000000000008', '00000000-0000-0000-0000-000000000001', 'Seoul Eco-Tech Polymers & Textiles', 'seoul-ecotech-polymers',
  'High-Tenacity Cordura Fabric, Waterproof Breathable TPU Membranes & Aramid Yarn',
  'Located in Daegu textile innovation cluster, Seoul Eco-Tech manufactures technical industrial fabrics, high-tenacity ballistic nylon, seam-sealing waterproof membranes, and fire-resistant aramid spun fibers for international outdoor and defense brands.',
  'Technical Textile Mill', 'Daegu', 'Gyeongbuk', 'South Korea', 'https://www.seoul-ecotech.co.kr',
  true, 'verified', true, 1, 24, 2000, '250-500 employees', 'USD 40M - 80M', '2,500,000 meters/month',
  ARRAY['United States', 'Germany', 'United Kingdom', 'Vietnam', 'Italy', 'Japan'],
  ARRAY['T/T 30% deposit', 'L/C at sight'],
  ARRAY['High-Tenacity Tactical Nylon', 'Breathable TPU 3-Layer Laminate', 'Flame Retardant Aramid Yarn'],
  4.89, 36,
  'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_19173084-f8d1-4d6c-a8e1-71aad2b17bb7.jpg',
  'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_4762d137-8b97-4d44-97fd-87d59b2a85f4.jpg'
),
-- 9. United Kingdom - Sterling Aerospace & Thermal Systems Ltd.
(
  'e1000001-0000-0000-0000-000000000009', '00000000-0000-0000-0000-000000000001', 'Sterling Aerospace & Thermal Systems', 'sterling-aerospace-thermal',
  'AS9100D Certified Aircraft Titanium Fasteners & Inconel Thermal Heat Exchangers',
  'Headquartered in Birmingham manufacturing core, Sterling Aerospace engineers critical flight-hardware fasteners, multi-pass compact heat exchangers, and cryogenic stainless steel flexible bellows for aerospace, motorsport, and defense applications.',
  'Aerospace Manufacturer', 'Birmingham', 'West Midlands', 'UK', 'https://www.sterling-aerothermal.co.uk',
  true, 'verified', true, 1, 42, 1982, '250-500 employees', 'USD 60M - 110M', '1,200,000 components/month',
  ARRAY['United States', 'France', 'Germany', 'Japan', 'South Korea', 'UAE'],
  ARRAY['Wire Transfer T/T', 'L/C', 'Net 30'],
  ARRAY['Titanium Aircraft Bolts', 'Compact Inconel Heat Exchangers', 'Stainless Cryogenic Bellows'],
  4.93, 39,
  'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_206d733c-1a07-4864-831d-8d0b40e8d664.jpg',
  'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_fd32cf11-5976-4705-b523-1eac69a5514f.jpg'
),
-- 10. United Kingdom - Cotswold Botanical Extracts Ltd
(
  'e1000001-0000-0000-0000-000000000010', '00000000-0000-0000-0000-000000000001', 'Cotswold Botanical Extracts Ltd', 'cotswold-botanical-extracts',
  'MHRA GMP-Certified Standardized Botanical Extracts & Pharmaceutical Softgels',
  'Operating cleanrooms in Oxford, Cotswold Botanical Extracts is an approved wholesale supplier of standardized medicinal botanical extracts, clinical grade marine collagen peptides, and custom nutraceutical softgel capsules shipped globally.',
  'Pharma & Nutraceutical OEM', 'Oxford', 'Oxfordshire', 'UK', 'https://www.cotswoldextracts.co.uk',
  true, 'verified', true, 1, 27, 1997, '100-250 employees', 'USD 35M - 70M', '50 million softgels/month',
  ARRAY['United States', 'Germany', 'Australia', 'Canada', 'UAE', 'Singapore'],
  ARRAY['T/T in Advance', 'L/C at Sight'],
  ARRAY['Standardized Ashwagandha Extract 10%', 'Hydrolyzed Marine Collagen Type I', 'Omega-3 Pharmaceutical Softgels'],
  4.87, 28,
  'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_22110305-fbda-41c4-a0cc-f053d4a509c6.jpg',
  'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_fd32cf11-5976-4705-b523-1eac69a5514f.jpg'
),
-- 11. Vietnam - Mekong Delta Precision Woodcraft
(
  'e1000001-0000-0000-0000-000000000011', '00000000-0000-0000-0000-000000000001', 'Mekong Delta Precision Woodcraft', 'mekong-woodcraft-furniture',
  'FSC Acacia & Teak Outdoor Commercial Dining Furniture & Architectural Millwork',
  'Situated in Binh Duong industrial belt, Mekong Delta Precision Woodcraft operates over 80,000 sqm of modern kiln-drying, 5-axis CNC machining, and automated finishing lines supplying top hotel chains and wholesale furniture importers across North America and Europe.',
  'Wholesale Furniture Manufacturer', 'Binh Duong', 'Binh Duong', 'Vietnam', 'https://www.mekongwoodcraft.vn',
  true, 'verified', true, 1, 18, 2006, '500+ employees', 'USD 45M - 90M', '120 standard 40ft containers/month',
  ARRAY['United States', 'United Kingdom', 'Germany', 'Australia', 'Japan', 'Canada'],
  ARRAY['L/C at Sight', 'T/T 30% Deposit 70% against B/L'],
  ARRAY['Solid Acacia Outdoor Dining Set', 'Commercial Hospitality Lounge Chairs', 'FSC Teak Slatted Sun Lounger'],
  4.88, 32,
  'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_7610e66a-3949-479c-8b48-643cc7d2b63f.jpg',
  'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_ba175bf8-9522-42e1-8d07-eb1a54b79101.jpg'
),
-- 12. Vietnam - Red River Technical Garments
(
  'e1000001-0000-0000-0000-000000000012', '00000000-0000-0000-0000-000000000001', 'Red River Technical Garments', 'red-river-garments',
  'ISO Certified Flame-Retardant Industrial Coveralls & High-Visibility Parkas',
  'Red River Technical Garments in Nam Dinh produces premium industrial protective apparel, EN ISO 20471 certified high-visibility waterproof workwear, and anti-static petrochemical work suits with laser-cutting and seam-welding technology.',
  'Apparel OEM / ODM', 'Nam Dinh', 'Nam Dinh', 'Vietnam', 'https://www.redrivergarments.vn',
  true, 'verified', true, 1, 21, 2003, '500+ employees', 'USD 35M - 70M', '350,000 garments/month',
  ARRAY['Germany', 'United States', 'Japan', 'South Korea', 'United Kingdom', 'UAE'],
  ARRAY['T/T', 'L/C at Sight', 'FOB Haiphong Port'],
  ARRAY['Hi-Vis Waterproof Industrial Parka', 'Flame-Retardant Nomex Coveralls', 'Anti-Static Cleanroom Jumpsuits'],
  4.86, 29,
  'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_19173084-f8d1-4d6c-a8e1-71aad2b17bb7.jpg',
  'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_4762d137-8b97-4d44-97fd-87d59b2a85f4.jpg'
),
-- 13. UAE - Emirates Petrochem & Polymers
(
  'e1000001-0000-0000-0000-000000000013', '00000000-0000-0000-0000-000000000001', 'Emirates Petrochem & Polymers', 'emirates-petrochem-polymer',
  'Prime Virgin HDPE Blow-Molding Granules, LLDPE Film Grade & Color Masterbatches',
  'Located in Jebel Ali Free Zone (JAFZA), Dubai, Emirates Petrochem supplies prime virgin plastic polymers, high-density polyethylene (HDPE 5502BN), UV-stabilized masterbatches, and linear low-density polyethylene with direct vessel loading access.',
  'Polymer Producer & Exporter', 'Dubai', 'Dubai', 'UAE', 'https://www.emiratespetrochem.ae',
  true, 'verified', true, 1, 19, 2005, '250-500 employees', 'USD 120M+', '25,000 metric tons/month',
  ARRAY['India', 'Turkey', 'Egypt', 'United Kingdom', 'Vietnam', 'South Africa'],
  ARRAY['Confirmed Irrevocable L/C', 'T/T', 'CAD'],
  ARRAY['Virgin HDPE Blow Molding Pellets', 'Linear Low Density PE (LLDPE)', 'UV-Grade Black Masterbatch'],
  4.91, 44,
  'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_3dd25eca-4769-4842-bd0b-792905f3b2f3.jpg',
  'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_ba175bf8-9522-42e1-8d07-eb1a54b79101.jpg'
),
-- 14. UAE - Gulf Solar Technologies & Aluminium
(
  'e1000001-0000-0000-0000-000000000014', '00000000-0000-0000-0000-000000000001', 'Gulf Solar Technologies & Aluminium', 'gulf-solar-technologies',
  'Anodized Structural Aluminium Solar Mounting Rails & Architectural Extrusions',
  'Industrial City of Abu Dhabi (ICAD). Gulf Solar Technologies operates high-tonnage automated aluminium extrusion presses, anodizing baths, and fabrication facilities delivering engineered ground-mount and rooftop solar mounting structural profiles.',
  'Extrusion & Solar Manufacturer', 'Abu Dhabi', 'Abu Dhabi', 'UAE', 'https://www.gulfsolar-alu.ae',
  true, 'verified', true, 1, 15, 2009, '250-500 employees', 'USD 70M - 140M', '3,500 metric tons/month',
  ARRAY['United States', 'Germany', 'India', 'Saudi Arabia', 'Australia', 'Egypt'],
  ARRAY['L/C', 'T/T 30/70', 'DP (Documents Against Payment)'],
  ARRAY['Anodized Solar Rail 40x40', 'Aluminium Architectural Curtain Profiles', 'Universal Mid & End Clamps'],
  4.89, 35,
  'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_0fd5c97f-69b3-43ce-af7f-a4fa1212e785.jpg',
  'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_788afc34-8703-44d6-840e-cd5895904a4f.jpg'
),
-- 15. Turkey - Anatolia Premium Terry & Textiles
(
  'e1000001-0000-0000-0000-000000000015', '00000000-0000-0000-0000-000000000001', 'Anatolia Premium Terry & Textiles', 'anatolia-premium-textiles',
  '100% Aegean Long-Staple Combed Cotton Hotel Bath Linens & Jacquard Terry Robes',
  'Centred in Denizli, the world capital of luxury terry toweling, Anatolia Premium Textiles crafts 650 GSM zero-twist Aegean cotton bath sheets, ring-spun hotel towels, and custom-embroidered plush velour bathrobes for 5-star international hospitality brands.',
  'Luxury Textile Mill', 'Denizli', 'Denizli', 'Turkey', 'https://www.anatoliaterry.com.tr',
  true, 'verified', true, 1, 31, 1993, '250-500 employees', 'USD 40M - 75M', '450,000 towels/month',
  ARRAY['United States', 'United Kingdom', 'Germany', 'UAE', 'France', 'Italy'],
  ARRAY['T/T', 'L/C at Sight', 'Cash Against Documents'],
  ARRAY['650 GSM Aegean Cotton Bath Sheet', 'Double-Sided Velour Hotel Bathrobe', 'Zero-Twist Ribbed Hand Towel Set'],
  4.94, 48,
  'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_19173084-f8d1-4d6c-a8e1-71aad2b17bb7.jpg',
  'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_4762d137-8b97-4d44-97fd-87d59b2a85f4.jpg'
),
-- 16. Turkey - Bosphorus Heavy Forgings & Steel
(
  'e1000001-0000-0000-0000-000000000016', '00000000-0000-0000-0000-000000000001', 'Bosphorus Heavy Forgings & Steel', 'bosphorus-heavy-forgings',
  'Hot Die Heavy Forged Crane Hooks, High-Pressure Pipeline Flanges & Axles',
  'Located in Bursa heavy machinery zone, Bosphorus Heavy Forgings manufactures DIN 15401 crane hooks up to 100 tons, ANSI/ASME high-pressure weld neck flanges, and precision railway rolling stock axles forged on 8,000-ton hydraulic presses.',
  'Heavy Forging Plant', 'Bursa', 'Marmara', 'Turkey', 'https://www.bosphorus-forging.com.tr',
  true, 'verified', true, 1, 38, 1986, '250-500 employees', 'USD 65M - 120M', '4,000 metric tons/month',
  ARRAY['Germany', 'United States', 'United Kingdom', 'Italy', 'UAE', 'Poland'],
  ARRAY['L/C', 'T/T', 'Bank Guarantee'],
  ARRAY['Forged Crane Hook DIN 15401', 'ANSI B16.5 Weld Neck Flanges', 'Forged Railway Wheel Axle Set'],
  4.9, 37,
  'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_206d733c-1a07-4864-831d-8d0b40e8d664.jpg',
  'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_788afc34-8703-44d6-840e-cd5895904a4f.jpg'
),
-- 17. Italy - Milano Automazione Industriale S.r.l.
(
  'e1000001-0000-0000-0000-000000000017', '00000000-0000-0000-0000-000000000001', 'Milano Automazione Industriale', 'milano-automazione-industriale',
  'High-Speed Rotary Form-Fill-Seal Packaging Machines & Delta Robotic Pickers',
  'Milan technological corridor. Milano Automazione is a premier Italian engineering house building high-speed sterile rotary blister packing machines, servo-driven cartoners, and high-cadence spider delta pick-and-place robots for food & pharmaceutical plants worldwide.',
  'Automation Machinery OEM', 'Milan', 'Lombardy', 'Italy', 'https://www.milanoautomazione.it',
  true, 'verified', true, 1, 33, 1991, '250-500 employees', 'USD 80M - 150M', '45 complete automated lines/year',
  ARRAY['United States', 'Germany', 'United Kingdom', 'Japan', 'France', 'India'],
  ARRAY['L/C Confirmed Irrevocable', 'T/T 30/60/10', 'ECA Financing'],
  ARRAY['High-Speed Rotary Blister Packing Line', 'Delta Robot High-Speed Cartoning Cell', 'Servo Multi-Axis Form-Fill-Seal Machine'],
  4.95, 46,
  'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_206d733c-1a07-4864-831d-8d0b40e8d664.jpg',
  'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_fd32cf11-5976-4705-b523-1eac69a5514f.jpg'
),
-- 18. Italy - Tuscany Heritage Leather & Tannery Group S.p.A.
(
  'e1000001-0000-0000-0000-000000000018', '00000000-0000-0000-0000-000000000001', 'Tuscany Heritage Leather Group', 'tuscany-heritage-leather',
  'Pelle al Vegetale Certified Vegetable-Tanned Italian Full Grain Bovine Hides',
  'Santa Croce sull''Arno (Pisa/Florence). Tuscany Heritage Tannery preserves centuries-old Tuscan vegetable tanning traditions using natural chestnut and mimosa tannins, delivering drum-dyed full grain leather for high-end luxury goods, footwear, and upholstery.',
  'Artisanal Tannery & Leatherworks', 'Florence', 'Tuscany', 'Italy', 'https://www.tuscanyheritageleather.it',
  true, 'verified', true, 1, 56, 1968, '100-250 employees', 'USD 30M - 60M', '150,000 square meters/month',
  ARRAY['United States', 'Japan', 'United Kingdom', 'France', 'South Korea', 'Germany'],
  ARRAY['T/T', 'L/C', 'Credit Card Escrow'],
  ARRAY['Vachetta Natural Full-Grain Leather', 'Aniline Pull-Up Upholstery Hide', 'Hand-Polished Vegetable Bridle Leather'],
  4.96, 52,
  'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_19173084-f8d1-4d6c-a8e1-71aad2b17bb7.jpg',
  'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_4762d137-8b97-4d44-97fd-87d59b2a85f4.jpg'
);
