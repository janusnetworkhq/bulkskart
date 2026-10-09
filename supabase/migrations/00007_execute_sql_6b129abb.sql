DO $$
DECLARE
  buyer_id uuid := '00000000-0000-0000-0000-000000000002';
  cats uuid[];
  titles text[] := ARRAY[
    'Bulk Order for Cotton Fabric','Requirement for LED Bulbs','Purchase of Paracetamol API',
    'CNC Machine Tool Procurement','Reactive Dyes Sourcing','Basmati Rice Export Order',
    'Vitrified Tiles Bulk Purchase','HDPE Pipes Requirement','Brake Pads Procurement',
    'Polished Diamonds Sourcing','Brass Decoratives Export','Teak Furniture Order',
    'Woollen Fabric Bulk Buy','Solar Inverter Procurement','Amoxicillin Capsules Order',
    'Hydraulic Cylinder Sourcing','Turmeric Powder Bulk Export','Ceramic Wall Tiles Order',
    'PVC Pipes Large Order','Auto Wire Harness RFQ','Linen Shirts Bulk Order',
    'Power Supply Units Purchase','Herbal Extract Sourcing','Industrial Pump Procurement',
    'Agrochemicals Bulk Order','Spices and Condiments Export','Marble Slabs Purchase',
    'Rubber Seals Requirement','Bearing Sets Bulk Order','Gemstone Jewellery Sourcing',
    'Handicraft Items for Retail','Upholstered Furniture Order','Denim Fabric Wholesale',
    'Electronic Components RFQ','Pharmaceutical Tablets','Forged Flanges Procurement',
    'Industrial Dyes Purchase','Rice and Wheat Commodities','Construction Steel Order',
    'Masterbatch Supply','Engine Components RFQ','Diamond Rings Wholesale',
    'Copper Handicrafts Export','Wooden Cabinets Bulk Buy','Silk Fabric Order',
    'UPS Systems Procurement','Vaccine Raw Materials','Boiler Spare Parts',
    'Chemical Solvents Bulk','Fresh Produce Export','Porcelain Tiles Purchase',
    'Rubber Gaskets Order','Tapered Roller Bearings','Coloured Gemstones Lot',
    'Brass Lamp Export Order','Sheesham Wood Furniture','Printed Fabric Rolls',
    'LED Strip Lights Order','Ayurvedic Extracts RFQ','Submersible Pumps Bulk',
    'Pigments and Resins Order','Spice Oleoresins Export','Granite Countertops Order',
    'CPVC Fittings Procurement','Clutch Facing Components','Sapphire Gemstones Order',
    'Metal Sculpture Export','Dining Table Set Wholesale','Knitwear Bulk Purchase',
    'Power Inverters RFQ','API Chemicals Procurement','VMC Machine Procurement',
    'Disperse Dyes Bulk Order','Wheat Flour Export','TMT Steel Bars Order',
    'Polymer Compound Supply','Transmission Parts RFQ','Polished Ruby Stones',
    'Decorative Plates Export','Rattan Furniture Order','Polyester Blended Fabric',
    'SMPS Power Modules','Herbal Supplement APIs','Fire Fighting Pump Sets',
    'Surfactant Chemicals Bulk','Dry Fruits Export Lot','Sandstone Tiles Order',
    'O-Ring Seals Procurement','Deep Groove Bearings RFQ','Tourmaline Gemstones',
    'Incense and Craft Items','Sofa Set Bulk Purchase','Cotton Yarn Order',
    'Semiconductor Components','Metformin Bulk API','Grinding Machine RFQ',
    'Optical Brighteners Order','Soybean Oil Bulk Export','Structural Steel Profiles',
    'Filler Masterbatch Supply','Brake Shoe Assembly','Tanzanite Gemstone Lot'
  ];
  dest_countries text[] := ARRAY['USA','UK','Germany','UAE','Australia','Japan','France','Canada','Singapore','Netherlands','South Korea','Brazil','Italy','Spain','South Africa'];
  dest_cities   text[] := ARRAY['New York','London','Berlin','Dubai','Sydney','Tokyo','Paris','Toronto','Singapore','Amsterdam','Seoul','Sao Paulo','Milan','Barcelona','Johannesburg'];
  units         text[] := ARRAY['pcs','kg','MT','meters','liters','boxes','cartons','sets','pairs','rolls'];
  currencies    text[] := ARRAY['INR','USD','EUR','GBP','AED'];
  cat_len int;
  i int;
  qty int;
  bmin numeric;
  bmax numeric;
  ddays int;
  st rfq_status;
BEGIN
  SELECT ARRAY_AGG(id ORDER BY name) INTO cats FROM categories;
  cat_len := ARRAY_LENGTH(cats, 1);

  FOR i IN 1..10200 LOOP
    qty   := 100 * (1 + (i % 200));
    bmin  := (50000 + (i % 500) * 1000)::numeric;
    bmax  := bmin * 1.4;
    ddays := 30 + (i % 150);
    st    := CASE WHEN i % 20 = 0 THEN 'expired'::rfq_status
                  WHEN i % 10 = 0 THEN 'closed'::rfq_status
                  ELSE 'active'::rfq_status END;

    INSERT INTO requirements (
      buyer_id, category_id, title, description, specifications,
      quantity, quantity_unit, destination_country, destination_city,
      deadline, budget_min, budget_max, currency,
      status, quote_count, view_count, is_verified_buyer,
      created_at, expires_at
    ) VALUES (
      buyer_id,
      cats[(i % cat_len) + 1],
      titles[(i % 100) + 1] || ' #' || i,
      'We are looking for reliable suppliers for ' || titles[(i % 100) + 1] || '. Quality certification required. Regular orders expected with long-term contracts for qualified vendors.',
      'Grade: Commercial / Industrial. Packaging: Standard export packing. Certifications: ISO/BIS/CE preferred. Samples required before bulk. Delivery: CIF/FOB as agreed.',
      qty,
      units[(i % 10) + 1],
      dest_countries[(i % 15) + 1],
      dest_cities[(i % 15) + 1],
      (CURRENT_DATE + ddays)::date,
      bmin,
      bmax,
      currencies[(i % 5) + 1],
      st,
      (i % 12),
      (i % 80) + 5,
      (i % 3 = 0),
      now() - ((10200 - i) * interval '52 minutes'),
      now() + (ddays * interval '1 day')
    );
  END LOOP;
END $$;