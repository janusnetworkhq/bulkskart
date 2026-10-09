import urllib.request, json, re, hashlib, os, math

headers = {
    "apikey": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV3bmZ0dnNodnNyaGF3bHVsb3R5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODk1NTEyNjcsImV4cCI6MjEwNTEyNzI2N30.To52QykipRLs2KEyWubItKkDNiXazrW1zVJGmqo9B_8",
    "Authorization": "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV3bmZ0dnNodnNyaGF3bHVsb3R5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODk1NTEyNjcsImV4cCI6MjEwNTEyNzI2N30.To52QykipRLs2KEyWubItKkDNiXazrW1zVJGmqo9B_8"
}

# 1. Fetch categories
cat_url = "https://ewnftvshvsrhawluloty.supabase.co/rest/v1/categories?select=id,slug,name"
with urllib.request.urlopen(urllib.request.Request(cat_url, headers=headers)) as resp:
    cats = {c['id']: c for c in json.loads(resp.read().decode('utf-8'))}

# 2. Fetch all products
all_products = []
offset = 0
step = 1000
while True:
    url = f"https://ewnftvshvsrhawluloty.supabase.co/rest/v1/products?select=id,name,category_id,images&offset={offset}&limit={step}"
    with urllib.request.urlopen(urllib.request.Request(url, headers=headers)) as resp:
        batch = json.loads(resp.read().decode('utf-8'))
        if not batch:
            break
        all_products.extend(batch)
        if len(batch) < step:
            break
        offset += step

print(f"Total products to process: {len(all_products)}")

# --- DETAILED COMMODITY IMAGE REPOSITORY ---
# Verified, high-resolution, multi-image galleries (3-4 images each) for distinct commodities
COMMODITY_BANKS = {
    # ── 1. MACHINERY & INDUSTRIAL ──
    'bearing': [
        'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1581092160607-ee22621dd758?auto=format&fit=crop&w=800&q=80',
        'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_789b0972-866d-4092-adc2-f0a373bdce2a.jpg'
    ],
    'cnc_lathe': [
        'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_789b0972-866d-4092-adc2-f0a373bdce2a.jpg',
        'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_e896246c-04bd-41c8-aec9-7112056d6c7a.jpg',
        'https://images.unsplash.com/photo-1581092160607-ee22621dd758?auto=format&fit=crop&w=800&q=80'
    ],
    'laser_cutter': [
        'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_e646a5af-4108-447f-b172-bb3b2746d809.jpg',
        'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_e896246c-04bd-41c8-aec9-7112056d6c7a.jpg',
        'https://images.unsplash.com/photo-1504917599217-d4dc5ebe6122?auto=format&fit=crop&w=800&q=80'
    ],
    'hydraulic': [
        'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_b89f3291-fcec-4cf1-ba96-6bfd19734e92.jpg',
        'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_a39f0fbe-ecce-4ebb-ad59-667256afc6cb.jpg',
        'https://images.unsplash.com/photo-1581092162384-8987c1d64718?auto=format&fit=crop&w=800&q=80'
    ],
    'injection_molding': [
        'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_e72aa556-df37-494d-83c8-6951d873a499.jpg',
        'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_c71cb758-1542-418b-b1d0-168a1be0335d.jpg',
        'https://images.unsplash.com/photo-1581092160607-ee22621dd758?auto=format&fit=crop&w=800&q=80'
    ],
    'pump_valve': [
        'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_a39f0fbe-ecce-4ebb-ad59-667256afc6cb.jpg',
        'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_b89f3291-fcec-4cf1-ba96-6bfd19734e92.jpg',
        'https://images.unsplash.com/photo-1541888946425-d0fbb186c5f9?auto=format&fit=crop&w=800&q=80'
    ],
    'motor_compressor': [
        'https://images.unsplash.com/photo-1581092160607-ee22621dd758?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1581092162384-8987c1d64718?auto=format&fit=crop&w=800&q=80',
        'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_b89f3291-fcec-4cf1-ba96-6bfd19734e92.jpg'
    ],
    'heat_exchanger': [
        'https://images.unsplash.com/photo-1504917599217-d4dc5ebe6122?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1581092160607-ee22621dd758?auto=format&fit=crop&w=800&q=80',
        'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_e646a5af-4108-447f-b172-bb3b2746d809.jpg'
    ],

    # ── 2. TEXTILES & APPAREL ──
    'silk_saree': [
        'https://images.unsplash.com/photo-1610030469983-98e550d6193c?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1558769132-cb1aea458c5e?auto=format&fit=crop&w=800&q=80',
        'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_40d3f1bd-f792-4afc-8b43-c068566460ce.jpg'
    ],
    'cotton_denim': [
        'https://images.unsplash.com/photo-1542272604-780c96856592?auto=format&fit=crop&w=800&q=80',
        'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_c7ab4040-9a40-4ea4-86a6-01b517aae8f0.jpg',
        'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?auto=format&fit=crop&w=800&q=80'
    ],
    'linen_fabric': [
        'https://images.unsplash.com/photo-1558769132-cb1aea458c5e?auto=format&fit=crop&w=800&q=80',
        'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_a7a1ee1f-d5ec-4cee-8e0f-dd55a42e3c25.jpg',
        'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_c7ab4040-9a40-4ea4-86a6-01b517aae8f0.jpg'
    ],
    'garment_apparel': [
        'https://images.unsplash.com/photo-1489987707025-afc232f7ea0f?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1521572267360-ee0c2909d518?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1558769132-cb1aea458c5e?auto=format&fit=crop&w=800&q=80'
    ],
    'towels_linen': [
        'https://images.unsplash.com/photo-1584100936595-c0654b55a2e2?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1616627547584-bf28cee262db?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1558769132-cb1aea458c5e?auto=format&fit=crop&w=800&q=80'
    ],

    # ── 3. ELECTRONICS & ELECTRICALS ──
    'solar_energy': [
        'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_b4883059-6f4a-4aab-a4f1-ff4d3564a7f7.jpg',
        'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_6374c68f-954d-4dda-b171-9bc86af979fa.jpg',
        'https://images.unsplash.com/photo-1509391365360-2e959784a276?auto=format&fit=crop&w=800&q=80'
    ],
    'battery_storage': [
        'https://images.unsplash.com/photo-1509391365360-2e959784a276?auto=format&fit=crop&w=800&q=80',
        'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_6374c68f-954d-4dda-b171-9bc86af979fa.jpg',
        'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_b4883059-6f4a-4aab-a4f1-ff4d3564a7f7.jpg'
    ],
    'pcb_chips': [
        'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_a2e6a766-4ab9-470d-9ea1-0f3368a0a438.jpg',
        'https://images.unsplash.com/photo-1518770660439-4636190af475?auto=format&fit=crop&w=800&q=80',
        'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_68127971-1265-45b6-bc19-7bb97825b142.jpg'
    ],
    'switchgear_cables': [
        'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_68127971-1265-45b6-bc19-7bb97825b142.jpg',
        'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_a0fe4b8b-df7e-4b0f-82e3-45338428e464.jpg',
        'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?auto=format&fit=crop&w=800&q=80'
    ],

    # ── 4. CONSTRUCTION & BUILDING ──
    'tmt_rebar': [
        'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_8e3beae7-30f1-4095-b55b-cda800a250c6.jpg',
        'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_481a1b9b-0702-4e16-998c-d37efed9ec08.jpg',
        'https://images.unsplash.com/photo-1504917599217-d4dc5ebe6122?auto=format&fit=crop&w=800&q=80'
    ],
    'steel_coil_pipe': [
        'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_723d95a8-d40b-42fc-8938-c2adf842878f.jpg',
        'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_f19901e5-2ba4-449f-be1b-210849967adf.jpg',
        'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_d310c58a-0af2-4b98-8ca8-6655d6c6bed6.jpg'
    ],
    'granite_marble_tiles': [
        'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1541888946425-d0fbb18086f6?auto=format&fit=crop&w=800&q=80'
    ],
    'cement_blocks': [
        'https://images.unsplash.com/photo-1541888946425-d0fbb18086f6?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1590674899484-d5640e854abe?auto=format&fit=crop&w=800&q=80',
        'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_481a1b9b-0702-4e16-998c-d37efed9ec08.jpg'
    ],

    # ── 5. CHEMICALS & RAW MATERIALS ──
    'caustic_solvents': [
        'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_6aadda13-8376-4a44-9d8e-907d738fc96e.jpg',
        'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_d1c3eced-73eb-40e1-b1e3-f0f0ef860860.jpg',
        'https://images.unsplash.com/photo-1532187863486-abf9dbad1b69?auto=format&fit=crop&w=800&q=80'
    ],
    'pigments_tio2': [
        'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_df67c318-2055-49ac-82ae-3048654271e4.jpg',
        'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_11700251-87ce-4dfc-8f6e-fca56a1b92c4.jpg',
        'https://images.unsplash.com/photo-1532187863486-abf9dbad1b69?auto=format&fit=crop&w=800&q=80'
    ],
    'resins_dyes': [
        'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_d1c3eced-73eb-40e1-b1e3-f0f0ef860860.jpg',
        'https://images.unsplash.com/photo-1532187863486-abf9dbad1b69?auto=format&fit=crop&w=800&q=80',
        'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_6aadda13-8376-4a44-9d8e-907d738fc96e.jpg'
    ],

    # ── 6. PLASTICS & RUBBER ──
    'plastic_granules': [
        'https://images.unsplash.com/photo-1530587191325-3db32d826c18?auto=format&fit=crop&w=800&q=80',
        'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_c71cb758-1542-418b-b1d0-168a1be0335d.jpg',
        'https://images.unsplash.com/photo-1581092160607-ee22621dd758?auto=format&fit=crop&w=800&q=80'
    ],
    'rubber_oring_belts': [
        'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1530587191325-3db32d826c18?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1581092162384-8987c1d64718?auto=format&fit=crop&w=800&q=80'
    ],
    'acrylic_sheets': [
        'https://images.unsplash.com/photo-1530587191325-3db32d826c18?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1541888946425-d0fbb186c5f9?auto=format&fit=crop&w=800&q=80'
    ],

    # ── 7. AGRICULTURE & FOOD PRODUCTS ──
    'rice_grains': [
        'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_e17be388-364f-457c-a067-3dd21d25119b.jpg',
        'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_75363074-6c66-4211-b828-9c1151685b86.jpg',
        'https://images.unsplash.com/photo-1586201375761-83865001e31c?auto=format&fit=crop&w=800&q=80'
    ],
    'spices': [
        'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_cf725590-0907-418f-b19a-f07144b90681.jpg',
        'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_40bdd0a6-589c-4367-9ddf-0945dd99f3d3.jpg',
        'https://images.unsplash.com/photo-1596040033229-a9821ebd058d?auto=format&fit=crop&w=800&q=80'
    ],
    'dry_fruits_nuts': [
        'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_125da5ae-e799-4715-9936-a5e983e50849.jpg',
        'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_b791a564-a277-47ab-b89e-c6a60f3f6bea.jpg',
        'https://images.unsplash.com/photo-1508746829417-e6f548d8d6ed?auto=format&fit=crop&w=800&q=80'
    ],
    'oils_sugar': [
        'https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1587132137056-bfbf0166836e?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1586201375761-83865001e31c?auto=format&fit=crop&w=800&q=80'
    ],
    'fruits_citrus': [
        'https://images.unsplash.com/photo-1582979512210-99b6a53386f9?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1510812431401-41d2bd2722f3?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1586201375761-83865001e31c?auto=format&fit=crop&w=800&q=80'
    ],

    # ── 8. PHARMACEUTICALS & HEALTHCARE ──
    'capsules_tablets': [
        'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_5f6dd57b-5f92-409e-9898-0cc6896ba91a.jpg',
        'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1471864190281-a93a3070b6de?auto=format&fit=crop&w=800&q=80'
    ],
    'medical_supplies': [
        'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?auto=format&fit=crop&w=800&q=80',
        'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_5f6dd57b-5f92-409e-9898-0cc6896ba91a.jpg'
    ],
    'herbal_extracts': [
        'https://images.unsplash.com/photo-1471864190281-a93a3070b6de?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?auto=format&fit=crop&w=800&q=80',
        'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_cf725590-0907-418f-b19a-f07144b90681.jpg'
    ],

    # ── 9. FURNITURE & HOME ──
    'office_furniture': [
        'https://images.unsplash.com/photo-1524758631624-e2822e304c36?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1580481077195-c27b08051778?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?auto=format&fit=crop&w=800&q=80'
    ],
    'wood_dining_beds': [
        'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1540555700478-4be289fbecef?auto=format&fit=crop&w=800&q=80'
    ],
    'sofas_living': [
        'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1580481077195-c27b08051778?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?auto=format&fit=crop&w=800&q=80'
    ],

    # ── 10. GEMS & JEWELLERY ──
    'diamond_solitaire': [
        'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_de278965-ebc2-4cf2-9ccc-58b9a9d59ef2.jpg',
        'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?auto=format&fit=crop&w=800&q=80',
        'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_31ff5d77-6aa6-408c-a403-f43dcc89bf5d.jpg'
    ],
    'gold_necklace': [
        'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_3b486226-cb4f-4622-895a-a0f36d453a4f.jpg',
        'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_535f90ac-8aeb-467b-a089-8bd03642e57a.jpg',
        'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?auto=format&fit=crop&w=800&q=80'
    ],
    'gemstones': [
        'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_b758430c-898c-4618-b0e1-ff89906ac288.jpg',
        'https://images.unsplash.com/photo-1615655406736-b37c4fabf923?auto=format&fit=crop&w=800&q=80',
        'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_d5d8baeb-4688-42a1-adab-0e2b7276e90c.jpg'
    ],
    'bangles_bracelets': [
        'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_66035a18-dadd-4ff7-afbc-f6f00852eb04.jpg',
        'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_d5d8baeb-4688-42a1-adab-0e2b7276e90c.jpg',
        'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?auto=format&fit=crop&w=800&q=80'
    ],

    # ── 11. HANDICRAFTS & GIFTS (DISTINCT FROM JEWELLERY!) ──
    'brassware_statues': [
        'https://images.unsplash.com/photo-1584551246679-0daf3d275d0f?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1606744837616-56c9a5c6a6eb?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1578749556568-bc2c40e68b61?auto=format&fit=crop&w=800&q=80'
    ],
    'marble_inlay_craft': [
        'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1606744837616-56c9a5c6a6eb?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1584551246679-0daf3d275d0f?auto=format&fit=crop&w=800&q=80'
    ],
    'wooden_carvings': [
        'https://images.unsplash.com/photo-1540555700478-4be289fbecef?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1606744837616-56c9a5c6a6eb?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1578749556568-bc2c40e68b61?auto=format&fit=crop&w=800&q=80'
    ],
    'incense_gifts': [
        'https://images.unsplash.com/photo-1608248597359-291113b28f80?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1606744837616-56c9a5c6a6eb?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1578749556568-bc2c40e68b61?auto=format&fit=crop&w=800&q=80'
    ],
    'pottery_ceramic_art': [
        'https://images.unsplash.com/photo-1578749556568-bc2c40e68b61?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1606744837616-56c9a5c6a6eb?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1584551246679-0daf3d275d0f?auto=format&fit=crop&w=800&q=80'
    ],

    # ── 12. AUTO PARTS & VEHICLES ──
    'brake_clutch': [
        'https://images.unsplash.com/photo-1486006920555-c77dce18193b?auto=format&fit=crop&w=800&q=80',
        'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_75ab3028-ac37-4399-8ece-fa5db419ea27.jpg',
        'https://images.unsplash.com/photo-1619642751034-765dfdf7c58e?auto=format&fit=crop&w=800&q=80'
    ],
    'engine_electrical': [
        'https://images.unsplash.com/photo-1486006920555-c77dce18193b?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1619642751034-765dfdf7c58e?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1492144534655-ae79c964c9d7?auto=format&fit=crop&w=800&q=80'
    ],
    'suspension_parts': [
        'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_75ab3028-ac37-4399-8ece-fa5db419ea27.jpg',
        'https://images.unsplash.com/photo-1486006920555-c77dce18193b?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1619642751034-765dfdf7c58e?auto=format&fit=crop&w=800&q=80'
    ],

    # ── 13. PACKAGING ──
    'carton_sacks': [
        'https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1544816155-12df9643f363?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1607344645866-009c320b5ab8?auto=format&fit=crop&w=800&q=80'
    ]
}

def resolve_commodity_images(product_name, category_slug, product_id):
    name_l = product_name.lower()
    cat_l = category_slug.lower()

    target_key = None

    if 'handicraft' in cat_l or 'gift' in cat_l:
        if any(w in name_l for w in ['brass', 'diya', 'lamp', 'copper', 'statue', 'sculpture']):
            target_key = 'brassware_statues'
        elif any(w in name_l for w in ['marble', 'inlay', 'pietra', 'stone', 'vase', 'plate']):
            target_key = 'marble_inlay_craft'
        elif any(w in name_l for w in ['wood', 'carv', 'elephant', 'box', 'figurine']):
            target_key = 'wooden_carvings'
        elif any(w in name_l for w in ['incense', 'agarbatti', 'dhoop', 'hamper', 'fragrance']):
            target_key = 'incense_gifts'
        else:
            target_key = 'pottery_ceramic_art'

    elif 'gem' in cat_l or 'jewel' in cat_l:
        if any(w in name_l for w in ['diamond', 'solitaire', 'brilliant', 'engagement']):
            target_key = 'diamond_solitaire'
        elif any(w in name_l for w in ['necklace', 'choker', 'bridal', 'pendant']):
            target_key = 'gold_necklace'
        elif any(w in name_l for w in ['bangle', 'bracelet', 'kada', 'wristband', 'anklet']):
            target_key = 'bangles_bracelets'
        else:
            target_key = 'gemstones'

    elif 'auto' in cat_l or 'vehicle' in cat_l:
        if any(w in name_l for w in ['brake', 'clutch', 'rotor', 'disc', 'pad', 'caliper']):
            target_key = 'brake_clutch'
        elif any(w in name_l for w in ['shock', 'absorber', 'spring', 'suspension', 'strut']):
            target_key = 'suspension_parts'
        else:
            target_key = 'engine_electrical'

    elif 'furniture' in cat_l or 'home' in cat_l:
        if any(w in name_l for w in ['chair', 'office', 'desk', 'ergonomic', 'mesh']):
            target_key = 'office_furniture'
        elif any(w in name_l for w in ['sofa', 'couch', 'recliner', 'living', 'curtain']):
            target_key = 'sofas_living'
        else:
            target_key = 'wood_dining_beds'

    elif 'pharma' in cat_l or 'health' in cat_l:
        if any(w in name_l for w in ['extract', 'curcumin', 'ashwagandha', 'herbal', 'moringa', 'neem']):
            target_key = 'herbal_extracts'
        elif any(w in name_l for w in ['glove', 'mask', 'needle', 'syringe', 'test', 'diagnostic', 'kit', 'surgical']):
            target_key = 'medical_supplies'
        else:
            target_key = 'capsules_tablets'

    elif 'agri' in cat_l or 'food' in cat_l:
        if any(w in name_l for w in ['rice', 'paddy', 'wheat', 'grain', 'maize', 'flour']):
            target_key = 'rice_grains'
        elif any(w in name_l for w in ['chilli', 'pepper', 'cardamom', 'turmeric', 'coriander', 'cumin', 'spice']):
            target_key = 'spices'
        elif any(w in name_l for w in ['cashew', 'almond', 'nut', 'dry fruit', 'coffee', 'tea']):
            target_key = 'dry_fruits_nuts'
        elif any(w in name_l for w in ['oil', 'sugar', 'liquid', 'sesame', 'mustard']):
            target_key = 'oils_sugar'
        else:
            target_key = 'fruits_citrus'

    elif 'plastic' in cat_l or 'rubber' in cat_l:
        if any(w in name_l for w in ['ring', 'o-ring', 'belt', 'conveyor', 'gasket', 'seal', 'rubber']):
            target_key = 'rubber_oring_belts'
        elif any(w in name_l for w in ['acrylic', 'sheet', 'film', 'transparent']):
            target_key = 'acrylic_sheets'
        else:
            target_key = 'plastic_granules'

    elif 'chemical' in cat_l or 'raw' in cat_l:
        if any(w in name_l for w in ['titanium', 'tio2', 'pigment', 'white powder', 'carbon']):
            target_key = 'pigments_tio2'
        elif any(w in name_l for w in ['resin', 'dye', 'epoxy', 'coating', 'polymer']):
            target_key = 'resins_dyes'
        else:
            target_key = 'caustic_solvents'

    elif 'construct' in cat_l or 'building' in cat_l:
        if any(w in name_l for w in ['tmt', 'rebar', 'bar', 'rod', 'reinforc']):
            target_key = 'tmt_rebar'
        elif any(w in name_l for w in ['granite', 'marble', 'tile', 'sanitary', 'slate', 'stone']):
            target_key = 'granite_marble_tiles'
        elif any(w in name_l for w in ['block', 'brick', 'cement', 'aac', 'concrete']):
            target_key = 'cement_blocks'
        else:
            target_key = 'steel_coil_pipe'

    elif 'electr' in cat_l:
        if any(w in name_l for w in ['solar', 'photovoltaic', 'pv module', 'clean energy']):
            target_key = 'solar_energy'
        elif any(w in name_l for w in ['battery', 'lifepo4', 'bess', 'cell', 'storage']):
            target_key = 'battery_storage'
        elif any(w in name_l for w in ['pcb', 'circuit board', 'microcontroller', 'chip', 'sensor', 'atmega']):
            target_key = 'pcb_chips'
        else:
            target_key = 'switchgear_cables'

    elif 'textile' in cat_l or 'apparel' in cat_l:
        if any(w in name_l for w in ['silk', 'saree', 'mulberry', 'brocade']):
            target_key = 'silk_saree'
        elif any(w in name_l for w in ['towel', 'bath', 'blanket', 'curtain', 'bedsheet', 'linen']):
            target_key = 'towels_linen'
        elif any(w in name_l for w in ['shirt', 'parka', 'coverall', 'garment', 't-shirt', 'jacket', 'jean']):
            target_key = 'garment_apparel'
        elif any(w in name_l for w in ['denim', 'cotton', 'yarn', 'twill']):
            target_key = 'cotton_denim'
        else:
            target_key = 'linen_fabric'

    elif 'packag' in cat_l:
        target_key = 'carton_sacks'

    else:
        # Machinery default checks
        if any(w in name_l for w in ['bearing', '7205', '6205', '6204', 'roller', 'pillow block']):
            target_key = 'bearing'
        elif any(w in name_l for w in ['laser', 'fiber laser', 'cutter', 'cutting']):
            target_key = 'laser_cutter'
        elif any(w in name_l for w in ['hydraulic', 'press', 'cylinder', 'brake press']):
            target_key = 'hydraulic'
        elif any(w in name_l for w in ['injection', 'molding', 'blow mold']):
            target_key = 'injection_molding'
        elif any(w in name_l for w in ['pump', 'valve', 'centrifugal', 'slurry']):
            target_key = 'pump_valve'
        elif any(w in name_l for w in ['motor', 'compressor', 'air compressor', 'induction']):
            target_key = 'motor_compressor'
        elif any(w in name_l for w in ['exchanger', 'boiler', 'heater', 'pche']):
            target_key = 'heat_exchanger'
        else:
            target_key = 'cnc_lathe'

    pool = COMMODITY_BANKS.get(target_key, COMMODITY_BANKS['cnc_lathe'])
    # Rotate images deterministically based on product ID
    h = int(hashlib.md5(product_id.encode('utf-8')).hexdigest(), 16)
    n = len(pool)
    rotated = [pool[(h + i) % n] for i in range(n)]
    return rotated

print("Generating SQL update batches for 5,355 products...")
BATCH_SIZE = 500
total_batches = math.ceil(len(all_products) / BATCH_SIZE)

for b_idx in range(total_batches):
    batch = all_products[b_idx * BATCH_SIZE : (b_idx + 1) * BATCH_SIZE]
    sql_tuples = []
    for p in batch:
        pid = p['id']
        pname = p['name']
        cat_slug = cats.get(p.get('category_id'), {}).get('slug', 'machinery')
        imgs = resolve_commodity_images(pname, cat_slug, pid)
        # Format as PostgreSQL text[] array literal
        escaped_imgs = "ARRAY[" + ",".join([f"'{url}'" for url in imgs]) + "]::text[]"
        sql_tuples.append(f"('{pid}'::uuid, {escaped_imgs})")
    
    batch_sql = f"""UPDATE products AS p
SET images = v.images
FROM (VALUES
  {','.join(sql_tuples)}
) AS v(id, images)
WHERE p.id = v.id;
"""
    file_path = f"/workspace/app-egd29h5g4zcx/scripts/batch_{b_idx}.sql"
    with open(file_path, 'w') as f:
        f.write(batch_sql)
    print(f"Wrote batch {b_idx} with {len(batch)} products.")

print(f"All {total_batches} batches written successfully.")

