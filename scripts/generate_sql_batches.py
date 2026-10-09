import urllib.request, json, re, hashlib, os

headers = {
    "apikey": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV3bmZ0dnNodnNyaGF3bHVsb3R5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODk1NTEyNjcsImV4cCI6MjEwNTEyNzI2N30.To52QykipRLs2KEyWubItKkDNiXazrW1zVJGmqo9B_8",
    "Authorization": "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV3bmZ0dnNodnNyaGF3bHVsb3R5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODk1NTEyNjcsImV4cCI6MjEwNTEyNzI2N30.To52QykipRLs2KEyWubItKkDNiXazrW1zVJGmqo9B_8"
}

# 1. Fetch categories
cat_url = "https://ewnftvshvsrhawluloty.supabase.co/rest/v1/categories?select=id,slug,name"
with urllib.request.urlopen(urllib.request.Request(cat_url, headers=headers)) as resp:
    cats = {c['id']: c for c in json.loads(resp.read().decode('utf-8'))}

# 2. Fetch companies
comp_url = "https://ewnftvshvsrhawluloty.supabase.co/rest/v1/companies?select=id,company_name,business_type,key_products&limit=200"
with urllib.request.urlopen(urllib.request.Request(comp_url, headers=headers)) as resp:
    companies = json.loads(resp.read().decode('utf-8'))

# 3. Fetch all products
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

print(f"Loaded {len(companies)} companies and {len(all_products)} products.")

# --- INDUSTRY BANNERS DICTIONARY FOR COMPANIES ---
COMPANY_BANNERS = {
    'wood': 'https://images.unsplash.com/photo-1540555700478-4be289fbecef?auto=format&fit=crop&w=1200&q=80',
    'furniture': 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?auto=format&fit=crop&w=1200&q=80',
    'textile': 'https://images.unsplash.com/photo-1558769132-cb1aea458c5e?auto=format&fit=crop&w=1200&q=80',
    'garment': 'https://images.unsplash.com/photo-1558769132-cb1aea458c5e?auto=format&fit=crop&w=1200&q=80',
    'hosiery': 'https://images.unsplash.com/photo-1558769132-cb1aea458c5e?auto=format&fit=crop&w=1200&q=80',
    'steel': 'https://images.unsplash.com/photo-1504917599217-d4dc5ebe6122?auto=format&fit=crop&w=1200&q=80',
    'forging': 'https://images.unsplash.com/photo-1504917599217-d4dc5ebe6122?auto=format&fit=crop&w=1200&q=80',
    'machinery': 'https://images.unsplash.com/photo-1581092160607-ee22621dd758?auto=format&fit=crop&w=1200&q=80',
    'hydraulic': 'https://images.unsplash.com/photo-1581092162384-8987c1d64718?auto=format&fit=crop&w=1200&q=80',
    'optics': 'https://images.unsplash.com/photo-1581092580497-e0d23cbdf1dc?auto=format&fit=crop&w=1200&q=80',
    'alloy': 'https://images.unsplash.com/photo-1504917599217-d4dc5ebe6122?auto=format&fit=crop&w=1200&q=80',
    'power': 'https://images.unsplash.com/photo-1509391365360-2e959784a276?auto=format&fit=crop&w=1200&q=80',
    'solar': 'https://images.unsplash.com/photo-1509391365360-2e959784a276?auto=format&fit=crop&w=1200&q=80',
    'pharma': 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?auto=format&fit=crop&w=1200&q=80',
    'chemical': 'https://images.unsplash.com/photo-1532187863486-abf9dbad1b69?auto=format&fit=crop&w=1200&q=80',
    'plastic': 'https://images.unsplash.com/photo-1530587191325-3db32d826c18?auto=format&fit=crop&w=1200&q=80',
    'rubber': 'https://images.unsplash.com/photo-1530587191325-3db32d826c18?auto=format&fit=crop&w=1200&q=80',
    'diamond': 'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?auto=format&fit=crop&w=1200&q=80',
    'jewel': 'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?auto=format&fit=crop&w=1200&q=80',
    'gemstone': 'https://images.unsplash.com/photo-1615655406736-b37c4fabf923?auto=format&fit=crop&w=1200&q=80',
    'brass': 'https://images.unsplash.com/photo-1584551246679-0daf3d275d0f?auto=format&fit=crop&w=1200&q=80',
    'handicraft': 'https://images.unsplash.com/photo-1606744837616-56c9a5c6a6eb?auto=format&fit=crop&w=1200&q=80',
    'marble': 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?auto=format&fit=crop&w=1200&q=80',
    'spice': 'https://images.unsplash.com/photo-1596040033229-a9821ebd058d?auto=format&fit=crop&w=1200&q=80',
    'agro': 'https://images.unsplash.com/photo-1586201375761-83865001e31c?auto=format&fit=crop&w=1200&q=80',
    'rice': 'https://images.unsplash.com/photo-1586201375761-83865001e31c?auto=format&fit=crop&w=1200&q=80',
    'sugar': 'https://images.unsplash.com/photo-1587132137056-bfbf0166836e?auto=format&fit=crop&w=1200&q=80',
    'grape': 'https://images.unsplash.com/photo-1510812431401-41d2bd2722f3?auto=format&fit=crop&w=1200&q=80',
    'citrus': 'https://images.unsplash.com/photo-1582979512210-99b6a53386f9?auto=format&fit=crop&w=1200&q=80',
    'seafood': 'https://images.unsplash.com/photo-1534483509719-3feaee7c30da?auto=format&fit=crop&w=1200&q=80',
    'bicycle': 'https://images.unsplash.com/photo-1485965120184-e220f721d03e?auto=format&fit=crop&w=1200&q=80',
    'ceramic': 'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?auto=format&fit=crop&w=1200&q=80',
    'leather': 'https://images.unsplash.com/photo-1524805444758-089113d48a6d?auto=format&fit=crop&w=1200&q=80',
    'electronic': 'https://images.unsplash.com/photo-1518770660439-4636190af475?auto=format&fit=crop&w=1200&q=80',
    'auto': 'https://images.unsplash.com/photo-1486006920555-c77dce18193b?auto=format&fit=crop&w=1200&q=80',
    'bearing': 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?auto=format&fit=crop&w=1200&q=80',
}

# Build company update SQL
comp_sqls = []
for co in companies:
    cid = co['id']
    name = (co['company_name'] or '').lower()
    btype = (co.get('business_type') or '').lower()
    kprods = ' '.join(co.get('key_products') or []).lower()
    text = f"{name} {btype} {kprods}"
    
    assigned_banner = 'https://images.unsplash.com/photo-1581092160607-ee22621dd758?auto=format&fit=crop&w=1200&q=80'
    for k, url in COMPANY_BANNERS.items():
        if k in text:
            assigned_banner = url
            break
            
    comp_sqls.append(f"('{cid}'::uuid, '{assigned_banner}')")

companies_update_sql = f"""
UPDATE companies AS c
SET banner_url = v.banner_url
FROM (VALUES
  {','.join(comp_sqls)}
) AS v(id, banner_url)
WHERE c.id = v.id;
"""

with open('/workspace/app-egd29h5g4zcx/scripts/companies_update.sql', 'w') as f:
    f.write(companies_update_sql)
print("Wrote companies_update.sql")

