import urllib.request, json

url = "https://ewnftvshvsrhawluloty.supabase.co/rest/v1/products?select=name,category_id&limit=10000"
headers = {
    "apikey": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV3bmZ0dnNodnNyaGF3bHVsb3R5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODk1NTEyNjcsImV4cCI6MjEwNTEyNzI2N30.To52QykipRLs2KEyWubItKkDNiXazrW1zVJGmqo9B_8",
    "Authorization": "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV3bmZ0dnNodnNyaGF3bHVsb3R5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODk1NTEyNjcsImV4cCI6MjEwNTEyNzI2N30.To52QykipRLs2KEyWubItKkDNiXazrW1zVJGmqo9B_8"
}
req = urllib.request.Request(url, headers=headers)
with urllib.request.urlopen(req) as resp:
    data = json.loads(resp.read().decode('utf-8'))

names = set(p['name'] for p in data)
print(f"Total rows: {len(data)}, Unique product names: {len(names)}")
with open('/workspace/app-egd29h5g4zcx/scripts/unique_names.txt', 'w') as f:
    for n in sorted(names):
        f.write(n + '\n')
print("Wrote unique_names.txt")
