import urllib.request, json, re
from collections import defaultdict

url = "https://ewnftvshvsrhawluloty.supabase.co/rest/v1/products?select=id,name,category_id&limit=10000"
headers = {
    "apikey": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV3bmZ0dnNodnNyaGF3bHVsb3R5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODk1NTEyNjcsImV4cCI6MjEwNTEyNzI2N30.To52QykipRLs2KEyWubItKkDNiXazrW1zVJGmqo9B_8",
    "Authorization": "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV3bmZ0dnNodnNyaGF3bHVsb3R5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODk1NTEyNjcsImV4cCI6MjEwNTEyNzI2N30.To52QykipRLs2KEyWubItKkDNiXazrW1zVJGmqo9B_8"
}
req = urllib.request.Request(url, headers=headers)
with urllib.request.urlopen(req) as resp:
    products = json.loads(resp.read().decode('utf-8'))

# Also get categories
cat_url = "https://ewnftvshvsrhawluloty.supabase.co/rest/v1/categories?select=id,slug,name"
cat_req = urllib.request.Request(cat_url, headers=headers)
with urllib.request.urlopen(cat_req) as resp:
    cats = {c['id']: c for c in json.loads(resp.read().decode('utf-8'))}

base_names = defaultdict(lambda: {'count': 0, 'category': '', 'examples': []})

for p in products:
    name = p['name']
    cat = cats.get(p['category_id'], {'slug': 'unknown'})['slug']
    # Clean suffix: " #123", " Batch120", " Lot267", " P2", " SKU..."
    base = re.sub(r'\s*(#\d+|Batch\d+|Lot\d+|SKU\d+|Ref\d+|\bP\d+\b|\b\d+$)', '', name).strip()
    base_names[base]['count'] += 1
    base_names[base]['category'] = cat
    if len(base_names[base]['examples']) < 2:
        base_names[base]['examples'].append(name)

print(f"Total products: {len(products)}")
print(f"Total distinct base commodities: {len(base_names)}")
sorted_bases = sorted(base_names.items(), key=lambda x: (x[1]['category'], x[0]))

with open('/workspace/app-egd29h5g4zcx/scripts/base_commodities.json', 'w') as f:
    json.dump({k: v for k, v in sorted_bases}, f, indent=2)

print("Saved base_commodities.json successfully.")
