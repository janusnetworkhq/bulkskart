from supabase import create_client
import time

SUPABASE_URL = "https://ewnftvshvsrhawluloty.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV3bmZ0dnNodnNyaGF3bHVsb3R5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODk1NTEyNjcsImV4cCI6MjEwNTEyNzI2N30.To52QykipRLs2KEyWubItKkDNiXazrW1zVJGmqo9B_8"

client = create_client(SUPABASE_URL, SUPABASE_KEY)
t0 = time.time()
res = client.table('products').select('id, name, images').limit(2).execute()
print(f"Read 2 products in {time.time()-t0:.2f}s: {len(res.data)}")
