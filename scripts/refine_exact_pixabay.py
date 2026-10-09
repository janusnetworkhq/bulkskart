#!/usr/bin/env python3
import urllib.request
import urllib.parse
import json

API_KEY = '40187197-ed92faff565f23611446b233b'

SPECIFIC_QUERIES = {
    "food_truck_commercial": "food truck catering",
    "food_truck_kitchen": "commercial kitchen restaurant stainless",
    "hydraulic_control_valve": "hydraulic valve",
    "hydraulic_cylinder_machinery": "excavator hydraulics heavy",
    "semiconductor_wafer_cleanroom": "semiconductor computer chip",
    "electrical_copper_wire_harness": "copper wire electrical cable",
    "packaging_plastic_film_roll": "packaging film roll plastic",
    "industrial_robot_automation": "industrial robot arm assembly",
    "corrugated_packaging_boxes": "cardboard boxes warehouse shipping",
    "leather_tannery_hides": "leather hides tannery",
    "luxury_cotton_towels": "cotton towels bathroom luxury",
    "precision_optics_lens": "optical lens optics laboratory",
    "clean_energy_solar_power": "solar panels photovoltaic rooftop",
    "power_electronics_gan_converter": "printed circuit board power electronics",
    "stainless_steel_chemical_blender": "stainless steel tanks brewery industrial",
    "spinning_yarn_cotton_cones": "cotton yarn spools textile spinning"
}

refined = {}

for key, query in SPECIFIC_QUERIES.items():
    encoded_q = urllib.parse.quote(query)
    url = f"https://pixabay.com/api/?key={API_KEY}&q={encoded_q}&image_type=photo&safesearch=true&per_page=5"
    req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
    try:
        with urllib.request.urlopen(req) as resp:
            data = json.loads(resp.read().decode('utf-8'))
            hits = data.get('hits', [])
            for h in hits:
                preview = h.get('previewURL', '')
                if preview and 'cdn.pixabay.com' in preview:
                    cdn_640 = preview.replace('_150.jpg', '_640.jpg').replace('_150.png', '_640.png')
                    cdn_1280 = preview.replace('_150.jpg', '_1280.jpg').replace('_150.png', '_1280.png')
                    refined[key] = {
                        "id": h['id'],
                        "tags": h.get('tags', ''),
                        "cdn_640": cdn_640,
                        "cdn_1280": cdn_1280,
                        "pageURL": h.get('pageURL', '')
                    }
                    print(f"REFINED [{key}]: {h.get('tags')} -> {cdn_640}")
                    break
    except Exception as e:
        print(f"Error {key}: {e}")

with open('/workspace/app-egd29h5g4zcx/tasks/refined_pixabay.json', 'w') as f:
    json.dump(refined, f, indent=2)
