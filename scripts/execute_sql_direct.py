import urllib.request, json

# Check if there is a SQL endpoint or if we should test via Python
print("Checking batch file sizes:")
import os
for i in range(11):
    fn = f"/workspace/app-egd29h5g4zcx/scripts/batch_{i}.sql"
    print(f"Batch {i}: {os.path.getsize(fn)} bytes")
