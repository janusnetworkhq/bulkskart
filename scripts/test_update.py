import urllib.request, json

url = "https://ewnftvshvsrhawluloty.supabase.co/rest/v1/companies?id=eq.e1000001-0000-0000-0000-000000000011"
headers = {
    "apikey": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV3bmZ0dnNodnNyaGF3bHVsb3R5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODk1NTEyNjcsImV4cCI6MjEwNTEyNzI2N30.To52QykipRLs2KEyWubItKkDNiXazrW1zVJGmqo9B_8",
    "Authorization": "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV3bmZ0dnNodnNyaGF3bHVsb3R5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODk1NTEyNjcsImV4cCI6MjEwNTEyNzI2N30.To52QykipRLs2KEyWubItKkDNiXazrW1zVJGmqo9B_8",
    "Content-Type": "application/json",
    "Prefer": "return=representation"
}
data = json.dumps({
    "banner_url": "https://images.unsplash.com/photo-1586023492125-27b2c045efd7?auto=format&fit=crop&w=1200&q=80"
}).encode('utf-8')

req = urllib.request.Request(url, data=data, headers=headers, method='PATCH')
try:
    with urllib.request.urlopen(req) as resp:
        print("PATCH status:", resp.status)
        print("Result:", resp.read().decode('utf-8')[:100])
except Exception as e:
    print("PATCH failed:", e)
