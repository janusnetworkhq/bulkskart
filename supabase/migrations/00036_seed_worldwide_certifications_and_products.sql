-- Insert Worldwide Company Certifications
INSERT INTO company_certifications (company_id, cert_type, cert_name, cert_number, is_verified, verified_at, pending_review)
VALUES
  ('e1000001-0000-0000-0000-000000000001', 'iso', 'ISO 9001:2015 & ISO 14001:2015', 'TUV-SUD-DE-883921', true, now(), false),
  ('e1000001-0000-0000-0000-000000000001', 'other', 'CE Machinery Directive 2006/42/EC', 'CE-DE-449102-M', true, now(), false),
  ('e1000001-0000-0000-0000-000000000002', 'other', 'EN 13432 Compostability & DIN CERTCO', 'DIN-CERTCO-7P0912', true, now(), false),
  ('e1000001-0000-0000-0000-000000000003', 'other', 'UL Listed & FCC Class B Compliance', 'UL-E519823-A1', true, now(), false),
  ('e1000001-0000-0000-0000-000000000003', 'other', 'RoHS 3 & REACH Compliant', 'ROHS3-US-992182', true, now(), false),
  ('e1000001-0000-0000-0000-000000000004', 'other', 'FSC Chain of Custody (FSC-C012389)', 'FSC-COC-US-4821', true, now(), false),
  ('e1000001-0000-0000-0000-000000000005', 'iso', 'JIS Q 9001 & ISO 13485:2016 Medical', 'JQA-MD-JP-00382', true, now(), false),
  ('e1000001-0000-0000-0000-000000000006', 'iso', 'IATF 16949:2016 Automotive Quality', 'IATF-JP-7782190', true, now(), false),
  ('e1000001-0000-0000-0000-000000000007', 'other', 'IEC 62619, UL 1973 & UN 38.3 Transport', 'KTL-KR-ESS-49120', true, now(), false),
  ('e1000001-0000-0000-0000-000000000008', 'other', 'OEKO-TEX Standard 100 Class I', 'OEKO-KR-2024-918', true, now(), false),
  ('e1000001-0000-0000-0000-000000000009', 'iso', 'AS9100D & ISO 9001 Aerospace Certified', 'BSI-UK-AS9100-33', true, now(), false),
  ('e1000001-0000-0000-0000-000000000010', 'other', 'MHRA GMP Certified Manufacturing Facility', 'MHRA-UK-GMP-88219', true, now(), false),
  ('e1000001-0000-0000-0000-000000000011', 'other', 'FSC-STD-40-004 & SMETA Sedex Audited', 'FSC-VN-994821', true, now(), false),
  ('e1000001-0000-0000-0000-000000000012', 'other', 'EN ISO 20471 & EN 11612 Protective Standards', 'BTTG-VN-EN20471', true, now(), false),
  ('e1000001-0000-0000-0000-000000000013', 'iso', 'ISO 9001:2015 & REACH EU Registered', 'DNV-GL-UAE-33910', true, now(), false),
  ('e1000001-0000-0000-0000-000000000014', 'other', 'Qualicoat & Qualanod Architectural Grade', 'QUAL-UAE-EXT-7712', true, now(), false),
  ('e1000001-0000-0000-0000-000000000015', 'other', 'OEKO-TEX Standard 100 & GOTS Organic Cotton', 'GOTS-TR-TEXT-5591', true, now(), false),
  ('e1000001-0000-0000-0000-000000000016', 'other', 'Bureau Veritas (BV) & Lloyd Register Marine', 'BV-TR-FORG-88129', true, now(), false),
  ('e1000001-0000-0000-0000-000000000017', 'other', 'CE Mark & Industry 4.0 Ready Architecture', 'CE-IT-IND40-9938', true, now(), false),
  ('e1000001-0000-0000-0000-000000000018', 'other', 'Consorzio Vera Pelle Italiana Conciata al Vegetale', 'PELLE-VEG-IT-1968', true, now(), false);

-- Insert Full Products for Worldwide Companies
INSERT INTO products (
  company_id, category_id, name, slug, description, specifications,
  moq, moq_unit, price_min, price_max, price_currency,
  images, tags, export_destinations, is_active, is_featured, is_promoted,
  promotion_type, view_count
) VALUES
-- 1. Germany - Bavaria Precision Hydraulics
(
  'e1000001-0000-0000-0000-000000000001', '1c2f47fd-f313-4d74-932f-c845879987b5',
  'Proportional High-Pressure Hydraulic Servo Control Valve 350 Bar',
  'proportional-hydraulic-servo-valve-350-bar',
  'Engineered in Munich, this 350-bar high-pressure proportional servo valve delivers ultra-rapid response times (<12ms) with zero internal leakage, designed for CNC press brakes, injection molding machines, and automated heavy test rigs.',
  'Operating Pressure: 350 bar (5076 psi) | Nominal Flow Rate: 120 L/min | Response Time: <12 ms | Spool Design: 4-Way 3-Position Linear Overlap | Seal Material: Viton FKM High-Temp | Control Signal: 4-20mA / ±10V | Ambient Temp: -25°C to +85°C | Port Size: Subplate Mount ISO 4401-05 | Warranty: 24 Months OEM',
  5, 'units', 450, 680, 'EUR',
  ARRAY[
    'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_206d733c-1a07-4864-831d-8d0b40e8d664.jpg',
    'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_788afc34-8703-44d6-840e-cd5895904a4f.jpg'
  ],
  ARRAY['Hydraulics', 'Servo Valve', 'German Engineering', 'High Pressure', 'CNC Machinery'],
  ARRAY['United States', 'Japan', 'United Kingdom', 'India', 'South Korea'],
  true, true, true, 'top_pick', 1240
),
(
  'e1000001-0000-0000-0000-000000000001', '1c2f47fd-f313-4d74-932f-c845879987b5',
  'Heavy-Duty Double-Acting Telescopic Hydraulic Cylinder for Mining & Cranes',
  'heavy-duty-telescopic-hydraulic-cylinder',
  'Multi-stage double-acting chrome-plated telescopic cylinder with hard induction-hardened piston rods for dump trailers, mining trucks, and high-reach marine mobile cranes.',
  'Bore Range: 100mm - 320mm | Stroke Length: Up to 6500mm | Working Pressure: 250 - 320 bar | Piston Rod Coating: 30µm Hard Chrome Plated | Temperature Range: -40°C to +110°C | Mount Type: Trunnion / Clevis Pin Mount',
  2, 'units', 1200, 2400, 'EUR',
  ARRAY[
    'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_206d733c-1a07-4864-831d-8d0b40e8d664.jpg'
  ],
  ARRAY['Hydraulic Cylinder', 'Mining Equipment', 'Telescopic', 'Heavy Machinery'],
  ARRAY['United States', 'Brazil', 'Germany', 'Australia'],
  true, false, false, NULL, 650
),

-- 2. Germany - Rheinland Bio-Polymer Werk AG
(
  'e1000001-0000-0000-0000-000000000002', 'd3aafda1-051e-4541-a5bb-20a3b813b2ca',
  'Bio-Degradable PLA Injection Molding Pellets High-Heat Grade',
  'biodegradable-pla-injection-molding-pellets',
  'Crystallizable high-heat PLA resin pellets offering HDT up to 110°C, ideal for hot-beverage cups, durable bio-composite electronics enclosures, and automotive interior panels.',
  'Base Polymer: 100% Poly L-Lactic Acid | Melt Flow Index: 8-12 g/10min (190°C/2.16kg) | HDT (Heat Deflection): 105°C - 110°C | Tensile Strength: 65 MPa | Certification: EN 13432 & ASTM D6400 Industrial Compostable | Packaging: 25kg foil barrier bags / 800kg jumbo octabins',
  1000, 'kg', 2.8, 3.4, 'EUR',
  ARRAY[
    'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_3dd25eca-4769-4842-bd0b-792905f3b2f3.jpg',
    'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_fd32cf11-5976-4705-b523-1eac69a5514f.jpg'
  ],
  ARRAY['Bioplastics', 'PLA Resin', 'Compostable', 'Injection Molding', 'Eco Friendly'],
  ARRAY['United States', 'United Kingdom', 'France', 'Japan', 'UAE'],
  true, true, true, 'eco_certified', 1890
),

-- 3. USA - Apex Micro-Power Dynamics Inc.
(
  'e1000001-0000-0000-0000-000000000003', '96ca9ba3-18d4-4c5a-9955-1d7b941378f2',
  '3.3kW Industrial Bidirectional GaN DC-DC Power Converter Module',
  'industrial-bidirectional-gan-power-converter-3kw',
  'State-of-the-art Gallium Nitride (GaN) switching power module achieving 98.6% peak efficiency in an ultra-compact liquid-cooled aluminum enclosure, designed for solar microinverters and battery testing.',
  'Output Power: 3300W Continuous | Input Voltage Range: 200V - 450V DC | Output Voltage: 24V - 58V DC Programmable | Peak Efficiency: 98.6% | Switching Frequency: 500 kHz GaN | Cooling: Integrated Cold Plate Liquid / Forced Air | Interface: CAN 2.0B / RS485 Modbus | Protection: OVP, OCP, OTP, Short Circuit',
  10, 'units', 320, 480, 'USD',
  ARRAY[
    'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_d6f9b3ff-984e-42e1-a38f-ba8c1a2c5776.jpg',
    'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_4762d137-8b97-4d44-97fd-87d59b2a85f4.jpg'
  ],
  ARRAY['GaN Power', 'DC-DC Converter', 'EV Infrastructure', 'Power Electronics', 'High Efficiency'],
  ARRAY['Germany', 'Japan', 'South Korea', 'United Kingdom', 'India'],
  true, true, true, 'top_pick', 2140
),

-- 4. USA - Pacific Northwest Timber Corp.
(
  'e1000001-0000-0000-0000-000000000004', 'cb8c4ef8-c360-4e8c-a4fe-32950e554cd7',
  'FSC Douglas Fir Commercial Structural Glulam Beams Architectural Grade',
  'fsc-douglas-fir-structural-glulam-beams',
  'Architectural appearance grade glued laminated timber (glulam) beams crafted from sustainably harvested Pacific Northwest Douglas Fir, kiln-dried and radio-frequency cured with waterproof resorcinol adhesives.',
  'Wood Species: Coastal Douglas Fir-Larch | Stress Class: 24F-V4 / GL28h | Bonding Adhesive: Type I Exterior Resorcinol Waterproof | Widths: 3-1/8 inch, 5-1/8 inch, 6-3/4 inch | Depths: Up to 48 inch | Lengths: Custom up to 66 ft | Treatment: Factory Sealed, Water Repellent Coated | Certification: FSC 100% Chain of Custody, ANSI A190.1',
  500, 'board ft', 4.5, 7.2, 'USD',
  ARRAY[
    'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_7610e66a-3949-479c-8b48-643cc7d2b63f.jpg',
    'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_ba175bf8-9522-42e1-8d07-eb1a54b79101.jpg'
  ],
  ARRAY['Timber', 'Glulam Beams', 'Mass Timber', 'Green Building', 'FSC Certified'],
  ARRAY['Japan', 'United Kingdom', 'Germany', 'Australia'],
  true, false, false, NULL, 870
),

-- 5. Japan - Kyoto Advanced Opto-Electronics Co.
(
  'e1000001-0000-0000-0000-000000000005', '96ca9ba3-18d4-4c5a-9955-1d7b941378f2',
  'Sub-Micron High-Speed Blue Laser Triangulation Sensor 0.05µm Resolution',
  'submicron-blue-laser-triangulation-sensor',
  'Utilizes proprietary Japanese 405nm blue semiconductor laser diode for precise sub-micron profiling of shiny metal, black rubber, and transparent glass substrates with 100 kHz sampling frequency.',
  'Light Source: 405nm Blue Semiconductor Laser (Class 2) | Reference Distance: 50mm | Measuring Range: ±10mm | Linearity: ±0.02% of F.S. | Repeatability: 0.05 µm | Sampling Rate: Up to 100 kHz | Data Output: Gigabit Ethernet, PROFINET, EtherCAT | Ingress Protection: IP67 Oil-Resistant Aluminum Case',
  2, 'units', 1450, 2100, 'USD',
  ARRAY[
    'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_d6f9b3ff-984e-42e1-a38f-ba8c1a2c5776.jpg',
    'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_206d733c-1a07-4864-831d-8d0b40e8d664.jpg'
  ],
  ARRAY['Laser Sensor', 'Sub-Micron Precision', 'Machine Vision', 'Japanese Optics', 'Metrology'],
  ARRAY['United States', 'Germany', 'South Korea', 'Taiwan', 'United Kingdom'],
  true, true, true, 'top_pick', 2780
),

-- 6. Japan - Nippon High-Purity Alloys K.K.
(
  'e1000001-0000-0000-0000-000000000006', 'd3aafda1-051e-4541-a5bb-20a3b813b2ca',
  'Silicon Nitride (Si3N4) High Thermal Conductivity Substrates for EV Inverters',
  'silicon-nitride-thermal-substrates-ev-inverter',
  'High thermal conductivity (90 W/m·K) and high flexural strength (850 MPa) silicon nitride ceramic plates engineered for high-power SiC MOSFET power modules in electric vehicles.',
  'Thermal Conductivity: 90 W/m·K | Flexural Bending Strength: 850 MPa | Fracture Toughness: 6.8 MPa·m^1/2 | Thickness: 0.32mm, 0.50mm, 0.635mm | Metal Cladding: Direct Bond Copper (DBC) or AMB Active Metal Brazing | Breakdown Voltage: >15 kV/mm',
  100, 'pcs', 18, 32, 'USD',
  ARRAY[
    'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_206d733c-1a07-4864-831d-8d0b40e8d664.jpg'
  ],
  ARRAY['Silicon Nitride', 'EV Power Electronics', 'AMB Substrate', 'Advanced Ceramics'],
  ARRAY['Germany', 'United States', 'South Korea', 'Italy'],
  true, false, false, NULL, 940
),

-- 7. South Korea - Hana Smart Energy & Battery Corp.
(
  'e1000001-0000-0000-0000-000000000007', '96ca9ba3-18d4-4c5a-9955-1d7b941378f2',
  'Commercial 100kWh Industrial LiFePO4 Energy Storage Cabinet ESS 0.5C',
  'commercial-100kwh-industrial-lifepo4-ess-cabinet',
  'Turnkey outdoor C&I energy storage cabinet complete with liquid cooling, aerosol fire suppression, integrated 50kW bi-directional PCS inverter, and cloud BMS for peak shaving and microgrids.',
  'Rated Capacity: 100 kWh (280Ah LiFePO4 Grade-A Cells) | Nominal Voltage: 768V DC | Inverter Output: 50kW AC (400V 3-Phase 50/60Hz) | Cycle Life: >6000 cycles at 80% DoD 25°C | Thermal Management: Liquid Cooled Loop | Protection: IP55 Outdoor Rated, FM-200 Fire Suppression | Certifications: IEC 62619, UL 9540A, UN 38.3',
  1, 'set', 14800, 19500, 'USD',
  ARRAY[
    'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_0fd5c97f-69b3-43ce-af7f-a4fa1212e785.jpg',
    'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_f6b7c576-892d-4de4-ae52-8bd0d196aa32.jpg'
  ],
  ARRAY['BESS', 'LiFePO4', 'Solar Storage', 'Commercial ESS', 'Smart Grid'],
  ARRAY['United States', 'Germany', 'Australia', 'United Kingdom', 'UAE'],
  true, true, true, 'top_pick', 3120
),

-- 8. South Korea - Seoul Eco-Tech Polymers & Technical Textiles
(
  'e1000001-0000-0000-0000-000000000008', '158f4042-7fcc-4c77-bcbc-34474341b979',
  '1000D Ballistic Cordura Nylon Fabric Waterproof DWR PU Coating',
  '1000d-ballistic-cordura-nylon-waterproof',
  'High-tenacity 1000 Denier air-textured nylon 6,6 woven fabric with fluorocarbon-free Teflon DWR water repellent finish and 1500mm PU backing for tactical gear, luggage, and motorcycle garments.',
  'Composition: 100% High-Tenacity Nylon 6,6 (Cordura Type) | Yarn Count: 1000D x 1000D | Weight: 330 g/m² ± 5% | Width: 58/60 inches (148-150 cm) | Tear Strength: Warp >350N, Weft >320N | Hydrostatic Head: 1500mm | Abrasion Resistance: >100,000 rubs Martindale | Standard: OEKO-TEX Standard 100',
  300, 'meters', 4.2, 5.8, 'USD',
  ARRAY[
    'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_19173084-f8d1-4d6c-a8e1-71aad2b17bb7.jpg',
    'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_4762d137-8b97-4d44-97fd-87d59b2a85f4.jpg'
  ],
  ARRAY['Cordura Nylon', 'Technical Textile', 'Tactical Gear', 'Waterproof Fabric'],
  ARRAY['United States', 'Germany', 'United Kingdom', 'Vietnam', 'Italy'],
  true, true, false, NULL, 1420
),

-- 9. United Kingdom - Sterling Aerospace & Thermal Systems Ltd.
(
  'e1000001-0000-0000-0000-000000000009', '1c2f47fd-f313-4d74-932f-c845879987b5',
  'Aerospace Grade Inconel 718 Compact Printed Circuit Heat Exchanger (PCHE)',
  'aerospace-inconel-718-printed-circuit-heat-exchanger',
  'Diffusion bonded micro-channel Inconel 718 heat exchanger offering exceptional heat transfer coefficient with pressure endurance over 600 bar at 750°C for gas turbines and aerospace cryogenic cooling.',
  'Material: Inconel 718 Nickel Superalloy | Core Construction: Photochemically etched micro-channels, vacuum diffusion bonded | Max Operating Temp: 750°C | Design Pressure: 650 bar | Helium Leak Rate: <1x10^-9 mbar·L/s | Quality Inspection: 100% X-Ray Radiography & Hydrostatic Proof Test | Standard: AS9100D, ASME Sec VIII Div 1',
  1, 'units', 8500, 14200, 'GBP',
  ARRAY[
    'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_206d733c-1a07-4864-831d-8d0b40e8d664.jpg',
    'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_fd32cf11-5976-4705-b523-1eac69a5514f.jpg'
  ],
  ARRAY['Inconel 718', 'Heat Exchanger', 'Aerospace Engineering', 'PCHE', 'Cryogenics'],
  ARRAY['United States', 'France', 'Germany', 'Japan', 'UAE'],
  true, true, true, 'top_pick', 1980
),

-- 10. United Kingdom - Cotswold Botanical Extracts Ltd
(
  'e1000001-0000-0000-0000-000000000010', 'e6fc9bb9-9e94-4ad3-a3d6-2996d9cbd1c5',
  'Pure Hydrolyzed Wild-Caught Marine Collagen Peptides Type I & III',
  'hydrolyzed-marine-collagen-peptides-powder',
  'Enzymatically hydrolyzed peptide powder derived from wild North Atlantic deep-sea cod skin with low molecular weight (<2000 Daltons) ensuring 98% bioavailability for functional foods and cosmetics.',
  'Protein Assay: >94.0% Dry Basis | Molecular Weight: Average 1800 - 2000 Da | Heavy Metals: Total <10 ppm, Arsenic <1 ppm, Lead <0.5 ppm | Microbiological: Free of pathogens, irradiated cleanroom packed | Solubility: 100% instant cold water soluble, odor-free | Standard: MHRA GMP & Halal/Kosher certified',
  100, 'kg', 24, 35, 'GBP',
  ARRAY[
    'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_22110305-fbda-41c4-a0cc-f053d4a509c6.jpg',
    'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_fd32cf11-5976-4705-b523-1eac69a5514f.jpg'
  ],
  ARRAY['Marine Collagen', 'Nutraceuticals', 'GMP Certified', 'Bioactive Peptides'],
  ARRAY['United States', 'Germany', 'Australia', 'Canada', 'UAE'],
  true, true, false, NULL, 1540
),

-- 11. Vietnam - Mekong Delta Precision Woodcraft
(
  'e1000001-0000-0000-0000-000000000011', '032caf21-7245-4424-91ad-29c8dd612e4a',
  'FSC Acacia 9-Piece Expandable Outdoor Patio Dining Set Wholesale',
  'fsc-acacia-expandable-outdoor-patio-dining-set',
  'Manufactured from 100% FSC certified Vietnamese Acacia hardwood, kiln dried to 10-12% moisture content, with dual-coat outdoor polyurethane oil finish and galvanized rust-proof steel fittings.',
  'Wood: Vietnamese Acacia Wood (FSC Certified) | Table Dimensions: 180cm extending to 240cm x 100cm W x 76cm H | Chair Type: 8 Ergonomic Stacking Armchairs with Olefin Weather-Resistant Cushions | Hardware: Grade 304 Stainless / Dacromet Anti-Rust | KD Packaging: 5-Ply Corrugated Export Cartons with Drop-Test Certification',
  20, 'sets', 280, 410, 'USD',
  ARRAY[
    'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_7610e66a-3949-479c-8b48-643cc7d2b63f.jpg',
    'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_ba175bf8-9522-42e1-8d07-eb1a54b79101.jpg'
  ],
  ARRAY['Outdoor Furniture', 'Acacia Wood', 'Patio Dining Set', 'FSC Certified', 'Vietnam Factory'],
  ARRAY['United States', 'United Kingdom', 'Germany', 'Australia', 'Canada'],
  true, true, true, 'top_pick', 2210
),

-- 12. Vietnam - Red River Technical Garments
(
  'e1000001-0000-0000-0000-000000000012', '158f4042-7fcc-4c77-bcbc-34474341b979',
  'EN ISO 20471 Class 3 Waterproof Breathable Hi-Vis Industrial Parka Jacket',
  'en-iso-20471-waterproof-hivis-industrial-parka',
  'Heavy-duty industrial safety jacket tailored from 300D Oxford polyester PU coated waterproof shell, featuring 3M Scotchlite reflective stripes, storm flap zipper, and detachable fleece thermal liner.',
  'Compliance: EN ISO 20471 Class 3, EN 343 Class 3:3 | Shell Fabric: 300D Oxford 100% Polyester with Waterproof PU Coating 5000mm | Lining: 100% Polyester Taffeta + 280gsm Detachable Anti-Pill Fleece Vest | Reflective Tape: 5cm 3M Scotchlite 8906 Heat-Transfer Tape | Pockets: Concealed ID pocket, radio loop, dual cargo pockets',
  100, 'pcs', 18.5, 26.0, 'USD',
  ARRAY[
    'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_19173084-f8d1-4d6c-a8e1-71aad2b17bb7.jpg',
    'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_4762d137-8b97-4d44-97fd-87d59b2a85f4.jpg'
  ],
  ARRAY['High-Vis Workwear', 'Safety Parka', 'EN ISO 20471', 'Reflective Jacket'],
  ARRAY['Germany', 'United States', 'Japan', 'United Kingdom', 'UAE'],
  true, false, false, NULL, 1120
),

-- 13. UAE - Emirates Petrochem & Polymers
(
  'e1000001-0000-0000-0000-000000000013', '99c7dcf5-9dd4-4233-955f-1477c07ff078',
  'Prime Virgin High Density Polyethylene (HDPE 5502BN) Blow Molding Resin',
  'prime-virgin-hdpe-5502bn-blow-molding-resin',
  'Ethylene-hexene copolymer HDPE resin exhibiting high environmental stress crack resistance (ESCR) and rigidity, formulated for intermediate bulk containers, detergent bottles, and industrial drums.',
  'Density: 0.954 g/cm³ (ASTM D1505) | Melt Index (190°C/2.16kg): 0.35 g/10min | ESCR (Condition B, F50): >45 hours | Tensile Yield Strength: 27 MPa | Flexural Modulus: 1250 MPa | Color: Translucent Natural White Pellets | Packaging: 25 kg bags on shrink-wrapped pallets (FCL 24.75 MT per 40ft HC)',
  5000, 'kg', 1.05, 1.25, 'USD',
  ARRAY[
    'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_3dd25eca-4769-4842-bd0b-792905f3b2f3.jpg',
    'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_ba175bf8-9522-42e1-8d07-eb1a54b79101.jpg'
  ],
  ARRAY['HDPE Resin', 'Blow Molding', 'Virgin Polymers', 'Petrochemicals', 'JAFZA Dubai'],
  ARRAY['India', 'Turkey', 'Egypt', 'United Kingdom', 'Vietnam'],
  true, true, true, 'top_pick', 2640
),

-- 14. UAE - Gulf Solar Technologies & Aluminium
(
  'e1000001-0000-0000-0000-000000000014', 'cb8c4ef8-c360-4e8c-a4fe-32950e554cd7',
  'Structural Anodized Aluminium 6005-T5 Solar Mounting Rail Profile 40x40',
  'structural-anodized-aluminium-solar-mounting-rail-40x40',
  'Heavy extrusion 6005-T5 aluminium alloy structural mounting rail with 15µm silver anodized surface finish, engineered to withstand wind speeds up to 60 m/s for commercial rooftop and ground-mount photovoltaic arrays.',
  'Alloy & Temper: Aluminium 6005-T5 / 6063-T6 | Surface Finish: Clear Anodized 15 µm (Qualanod Standard) | Dimensions: 40mm x 40mm x 4200mm / 4800mm / 6000mm | Yield Strength: >240 MPa | Wind Load Resistance: Up to 60 m/s (216 km/h) | Snow Load: Up to 1.4 kN/m² | Warranty: 12 Years Structural, 25 Years Lifetime',
  200, 'meters', 4.8, 6.5, 'USD',
  ARRAY[
    'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_0fd5c97f-69b3-43ce-af7f-a4fa1212e785.jpg',
    'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_788afc34-8703-44d6-840e-cd5895904a4f.jpg'
  ],
  ARRAY['Solar Mounting Rail', 'Aluminium Extrusion', 'Solar PV Framing', 'Renewable Energy'],
  ARRAY['United States', 'Germany', 'India', 'Saudi Arabia', 'Australia'],
  true, true, false, NULL, 1750
),

-- 15. Turkey - Anatolia Premium Terry & Textiles
(
  'e1000001-0000-0000-0000-000000000015', '158f4042-7fcc-4c77-bcbc-34474341b979',
  '650 GSM 100% Turkish Aegean Combed Cotton Hotel Luxury Bath Sheet',
  '650-gsm-turkish-aegean-cotton-hotel-bath-sheet',
  'Spun from long-staple Turkish Aegean cotton fibers, these heavyweight 650 GSM luxury hotel bath sheets deliver supreme plush absorbency, reinforced double-stitched hems, and resistance to commercial laundry chlorine.',
  'Yarn: 100% Aegean Long-Staple Combed Ring-Spun Cotton (GOTS / OEKO-TEX Standard) | Weight: 650 Grams per Square Meter (GSM) | Dimensions: 100 cm x 180 cm (Bath Sheet) / 70 cm x 140 cm (Bath Towel) | Hem Construction: 4-Side Double Lock-Stitched with Polyester Core Reinforcement | Shrinkage: <4% after 50 industrial wash cycles',
  100, 'pcs', 7.5, 11.2, 'USD',
  ARRAY[
    'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_19173084-f8d1-4d6c-a8e1-71aad2b17bb7.jpg',
    'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_4762d137-8b97-4d44-97fd-87d59b2a85f4.jpg'
  ],
  ARRAY['Turkish Towels', 'Hotel Linen', 'Aegean Cotton', 'Bath Sheet 650GSM'],
  ARRAY['United States', 'United Kingdom', 'Germany', 'UAE', 'France'],
  true, true, true, 'top_pick', 2890
),

-- 16. Turkey - Bosphorus Heavy Forgings & Steel
(
  'e1000001-0000-0000-0000-000000000016', '1c2f47fd-f313-4d74-932f-c845879987b5',
  'DIN 15401 Forged Alloy Steel Single Crane Hook 50 Ton Capacity',
  'din-15401-forged-steel-single-crane-hook-50-ton',
  'Hot die drop forged from certified 34CrNiMo6 alloy steel, normalized and oil quenched with ultrasonic crack detection testing, complete with heavy cast spring-loaded safety latch.',
  'Standard: DIN 15401 / DIN 15402 | Safe Working Load (SWL): 50 Metric Tons (Hook No. 25) | Material Grade: 34CrNiMo6 Alloy Steel (Drive Group V / T / P) | Proof Test Load: 2.5x SWL (125 Tons Tested) | Safety Factor: 5:1 Minimum | Certification: Bureau Veritas / EN 10204 3.1 Material Test Certificate Included',
  1, 'units', 1450, 2200, 'USD',
  ARRAY[
    'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_206d733c-1a07-4864-831d-8d0b40e8d664.jpg',
    'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_788afc34-8703-44d6-840e-cd5895904a4f.jpg'
  ],
  ARRAY['Crane Hook', 'Heavy Forging', 'DIN 15401', 'Lifting Equipment', 'Turkish Steel'],
  ARRAY['Germany', 'United States', 'United Kingdom', 'Italy', 'UAE'],
  true, false, false, NULL, 910
),

-- 17. Italy - Milano Automazione Industriale S.r.l.
(
  'e1000001-0000-0000-0000-000000000017', '1c2f47fd-f313-4d74-932f-c845879987b5',
  'Continuous Rotary High-Speed Blister Packaging Machine 400 Blisters/Min',
  'rotary-high-speed-blister-packaging-machine-400bpm',
  'Premier Italian cGMP pharmaceutical rotary thermoforming and cold-forming (Alu-Alu / PVC-Alu) blister packaging machine with automated optical tablet inspection and motorized recipe changeover.',
  'Production Speed: Up to 400 blister packs/min | Forming Materials: PVC, PVDC, Aclar, Alu-Alu (Cold Form) | Forming Area: 220mm x 150mm | Sealing Principle: Rotary Platen Sealing with Precision PID Temp Control | Inspection: High-Resolution Vision Camera Inspection System (Color, Broken, Empty Pocket) | Control System: Siemens S7-1500 PLC + 15" Color HMI Touchscreen | cGMP Compliant: All 316L Stainless Contact Parts',
  1, 'units', 85000, 135000, 'EUR',
  ARRAY[
    'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_206d733c-1a07-4864-831d-8d0b40e8d664.jpg',
    'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_fd32cf11-5976-4705-b523-1eac69a5514f.jpg'
  ],
  ARRAY['Pharma Packaging', 'Blister Machine', 'Italian Automation', 'cGMP', 'High Speed'],
  ARRAY['United States', 'Germany', 'United Kingdom', 'Japan', 'France', 'India'],
  true, true, true, 'top_pick', 3450
),

-- 18. Italy - Tuscany Heritage Leather & Tannery Group S.p.A.
(
  'e1000001-0000-0000-0000-000000000018', '158f4042-7fcc-4c77-bcbc-34474341b979',
  'Consorzio Certified Italian Vegetable-Tanned Full Grain Vachetta Bovine Leather',
  'italian-vegetable-tanned-full-grain-vachetta-leather',
  'Certified by the Tuscan Vegetable Tanned Leather Consortium, this authentic full grain bovine shoulder leather is slow drum-tanned with natural chestnut extracts, developing an exquisite deep golden patina over time.',
  'Origin: 100% European Bovine Raw Hides Tanned in Santa Croce sull''Arno (Tuscany) | Tanning Method: 100% Traditional Vegetable Tannin (Chestnut & Mimosa) | Cut: Whole Double Shoulders | Substance / Thickness: 1.8mm - 2.0mm / 2.2mm - 2.4mm | Average Hide Size: 14 - 16 sq. ft. (1.3 - 1.5 m²) | Certification: Official numbered holographic seal by Consorzio Vera Pelle Italiana',
  50, 'sq ft', 9.5, 14.0, 'EUR',
  ARRAY[
    'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_19173084-f8d1-4d6c-a8e1-71aad2b17bb7.jpg',
    'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_4762d137-8b97-4d44-97fd-87d59b2a85f4.jpg'
  ],
  ARRAY['Tuscan Leather', 'Vegetable Tanned', 'Vachetta', 'Italian Craftsmanship', 'Luxury Goods'],
  ARRAY['United States', 'Japan', 'United Kingdom', 'France', 'South Korea'],
  true, true, true, 'top_pick', 2930
);
