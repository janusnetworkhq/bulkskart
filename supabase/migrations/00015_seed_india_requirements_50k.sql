
-- Bulk-seed 40,000 India-sourced requirements to push total past 50,000
-- Uses generate_series + modulo cycling over buyers, categories, products, cities
DO $$
DECLARE
  buyer_ids  uuid[] := ARRAY[
    '17e26280-f765-4e40-ae9f-698b8e645260',
    '00000000-0000-0000-0000-000000000002',
    '2c103299-b20e-4549-bddb-29d316ebdf50',
    '1276d24d-da85-4710-a8ab-1e1c16135fc1',
    'e0b7b15a-7b3b-4756-b1e0-c905d6fca61a',
    '8ca86ea3-56be-4c6b-9e77-fa2dd5aa3549'
  ];
  cat_ids uuid[] := ARRAY[
    '158f4042-7fcc-4c77-bcbc-34474341b979',
    '1c2f47fd-f313-4d74-932f-c845879987b5',
    '4e2b20b8-1d5b-402e-88a9-1c74bd5bcf05',
    'd3aafda1-051e-4541-a5bb-20a3b813b2ca',
    '96ca9ba3-18d4-4c5a-9955-1d7b941378f2',
    'cb8c4ef8-c360-4e8c-a4fe-32950e554cd7',
    '032caf21-7245-4424-91ad-29c8dd612e4a',
    'f01ebc60-18c5-4e4f-af6f-324020f63252',
    'e6fc9bb9-9e94-4ad3-a3d6-2996d9cbd1c5',
    '99c7dcf5-9dd4-4233-955f-1477c07ff078',
    'ede57bc5-1ac8-4fa7-862a-98ac327f3744',
    '18bd87c0-fa1a-4ef1-93a4-ca10638cf799'
  ];
  titles text[] := ARRAY[
    'Bulk Cotton Fabric Roll',
    'Basmati Rice Export Grade',
    'Industrial Hydraulic Pump',
    'Ayurvedic Herbal Supplement',
    'LED Street Light Fixture',
    'Handloom Silk Saree',
    'Organic Turmeric Powder',
    'Stainless Steel Fasteners',
    'Polypropylene Granules',
    'Jaipur Block Print Fabric',
    'Diesel Generator Set',
    'Raw Cashew Nuts Grade W240',
    'Automotive Brake Pads',
    'PVC Pipe Fittings',
    'Wooden Furniture Frame',
    'Pharmaceutical API Metformin',
    'Spun Polyester Yarn',
    'Solar Water Heater Panel',
    'Ceramic Floor Tiles',
    'Essential Oils Lavender',
    'Granite Slabs Absolute Black',
    'Guar Gum Powder',
    'Bamboo Handicraft Products',
    'Copper Wire Rods',
    'Sesame Seeds Natural White',
    'Readymade Garments Bulk',
    'Mustard Oil Cold Pressed',
    'Industrial Safety Gloves',
    'Coir Fibre Products',
    'Bengal Muslin Fabric',
    'Rubber Compound Natural',
    'Chilli Powder Guntur S4',
    'Steel Structure Components',
    'Jute Bags Hessian',
    'Ayurvedic Face Cream',
    'Auto Spare Parts Bulk',
    'Marble Tiles Makrana White',
    'Black Pepper Premium Grade',
    'Fire Bricks Refractory',
    'Agarbatti Incense Sticks',
    'Rajasthani Embroidered Fabric',
    'Groundnut Oil Refined',
    'Electronic PCB Assembly',
    'Sandstone Slabs Yellow',
    'Cardamom Green Bold',
    'Plastic Containers HDPE',
    'Iron Ore Fines 63%',
    'Cotton Terry Towels',
    'Pharmaceutical Tablets Strip',
    'Bicycle Parts & Components',
    'Mango Pulp Alphonso',
    'Chemical Fertiliser Urea',
    'Leather Shoes Bulk',
    'Bengal Gram Dal Split',
    'Electrical Cables XLPE',
    'Handmade Paper Products',
    'Aluminium Extrusion Profiles',
    'Onion Dehydrated Powder',
    'Machine Tools CNC',
    'Silk Thread Embroidery',
    'Red Chilli Whole Teja',
    'Tea CTC Assam Premium',
    'Coffee Robusta Green Beans',
    'Cast Iron Valve Flanged',
    'Denim Fabric Stretch',
    'Tamarind Paste Seedless',
    'Packaging Material Corrugated',
    'Zinc Oxide Technical Grade',
    'Woollen Shawl Pashmina',
    'Maize Corn Yellow Grade',
    'Sodium Carbonate Soda Ash',
    'Printed Circuit Board',
    'Sandalwood Oil Pure',
    'Textured Soya Protein TSP',
    'Bicycle Tyres Tubes',
    'Handloom Dhurrie Rug',
    'Sugar ICUMSA 45 White',
    'Steel Pipes ERW Welded',
    'Neem Oil Cold Pressed',
    'Precision Ball Bearings',
    'Paper Cup Manufacturing',
    'Brinjal Eggplant Export',
    'Zinc Diecasting Components',
    'Carpet Tufted Axminster',
    'Agro Chemicals Pesticide',
    'Pumice Stone Powder',
    'Frozen Shrimp Export Grade',
    'Wooden Toys Painted',
    'Granite Tiles P Black',
    'Cardboard Box Industrial',
    'Mustard Seeds Yellow',
    'Cotton Knitwear Hosiery',
    'Diamond Polished Round',
    'Palm Fatty Acid Distillate',
    'IT Hardware Components',
    'Menthol Crystal Pure',
    'Decorative Brass Figurine',
    'Yarn Dyed Check Fabric',
    'Tapioca Starch Modified',
    'Rice Bran Oil Refined'
  ];
  cities text[] := ARRAY[
    'Mumbai','Delhi','Bengaluru','Hyderabad','Ahmedabad',
    'Chennai','Kolkata','Pune','Jaipur','Surat',
    'Lucknow','Kanpur','Nagpur','Indore','Thane',
    'Bhopal','Visakhapatnam','Pimpri-Chinchwad','Patna','Vadodara',
    'Ghaziabad','Ludhiana','Agra','Nashik','Faridabad',
    'Meerut','Rajkot','Varanasi','Srinagar','Aurangabad',
    'Dhanbad','Amritsar','Allahabad','Ranchi','Howrah',
    'Coimbatore','Jabalpur','Gwalior','Vijayawada','Jodhpur',
    'Madurai','Raipur','Kota','Guwahati','Chandigarh',
    'Solapur','Hubli','Tiruchirappalli','Mysore','Tiruppur'
  ];
  dest_countries text[] := ARRAY[
    'India','India','India','India','India',
    'UAE','USA','UK','Germany','Singapore',
    'Australia','Canada','Japan','France','Kenya',
    'Nigeria','South Africa','Netherlands','Saudi Arabia','Indonesia'
  ];
  units text[] := ARRAY['MT','KG','Tons','Pieces','Units','Boxes','Cartons','Liters','Meters','Pairs','Sets','Bags'];
  currencies text[] := ARRAY['INR','USD','INR','INR','USD','EUR','INR','INR','USD','INR'];
BEGIN
  INSERT INTO requirements (
    buyer_id, category_id, title, description,
    quantity, quantity_unit,
    destination_country, destination_city,
    budget_min, budget_max, currency,
    status, quote_count, view_count,
    is_verified_buyer, created_at, updated_at
  )
  SELECT
    buyer_ids[ (i % 6) + 1 ],
    cat_ids[ (i % 12) + 1 ],
    titles[ (i % 100) + 1 ] || ' - Lot #' || (50000 + i)::text,
    'Requirement from India. Looking for verified manufacturers for bulk supply. '
      || 'Quality: Export grade. Payment: LC/TT. Inspection: Third party. '
      || 'Dispatch: Within 30 days of PO.',
    -- quantity: cycles 50–10000
    (50 + (i % 9950))::numeric,
    units[ (i % 12) + 1 ],
    dest_countries[ (i % 20) + 1 ],
    cities[ (i % 50) + 1 ],
    -- budget_min / budget_max
    (1000 + (i % 490000))::numeric,
    (5000 + (i % 990000))::numeric,
    currencies[ (i % 10) + 1 ],
    'active',
    -- quote_count 0–12
    (i % 13),
    -- view_count 0–200
    (i % 201),
    -- 30% verified buyers
    (i % 3 = 0),
    -- spread created_at over past 72 hours (live feel)
    now() - (((i % 259200) || ' seconds')::interval),
    now() - (((i % 259200) || ' seconds')::interval)
  FROM generate_series(1, 40000) AS s(i);
END $$;
