#!/usr/bin/env python3
import urllib.request
import urllib.parse
import json

API_KEY = '40187197-ed92faff565f23611446b233b'

# Target list with strict semantic search query
TARGETS = {
    # Companies
    "tuscany_leather": "leather workshop artisan",
    "kyoto_optics": "optical lens optics laboratory",
    "anatolia_textile": "towels cotton bathroom textile",
    "hana_energy": "solar panels photovoltaic rooftop",
    "bavaria_hydraulics": "hydraulic cylinder machine",
    "milano_automazione": "robot packaging factory",
    "pune_heavy_eng": "food truck commercial trailer",
    "apex_micropower": "circuit board electronics chip",
    "seoul_ecotech": "textile fabric rolls warehouse",
    "red_river_garments": "clothing factory sewing apparel",
    "emirates_petrochem": "plastic granules chemical factory",
    "siam_packaging": "cardboard boxes packaging warehouse",
    "cotswold_botanical": "essential oil laboratory herbs",
    "gulf_solar": "solar panel installation farm",
    "moradabad_brassware": "brass metal handicraft metalwork",
    "surat_diamond": "diamond gemstone jewelry luxury",
    "delhi_wire_harness": "wires electrical cables automotive",
    "rajkot_ceramic": "ceramic tiles interior floor",
    "ankleshwar_dyes": "chemical laboratory flask science",
    "haridwar_herbal": "herbal spices dry herbs",
    "bengaluru_tech": "microchip semiconductor computer",
    "chennai_friction": "car brake disc automotive",
    "kochi_seafood": "fish seafood market export",
    "hyderabad_semiconductor": "wafer semiconductor cleanroom",
    "varanasi_handloom": "loom weaving silk fabric",
    # Curated Products
    "prod_packaging_machine": "packaging machine industrial factory",
    "prod_hdpe_resin": "plastic granules pellets polymer",
    "prod_laser_cutter": "laser cutter metal cutting cnc",
    "prod_gan_converter": "electronic circuit motherboard processor",
    "prod_hydraulic_valve": "hydraulic system valve pipes",
    "prod_food_truck": "food truck trailer kitchen",
    "prod_cnc_machining": "cnc milling metal machine",
    "prod_bopp_film": "plastic film roll packaging",
    "prod_solar_inverter": "solar inverter renewable power",
    "prod_ribbon_blender": "industrial mixing tank stainless steel",
    "prod_cotton_yarn": "yarn spools thread textile",
    "prod_ndt_detector": "industrial measuring device instrument"
}

results = {}

for key, query in TARGETS.items():
    encoded_q = urllib.parse.quote(query)
    url = f"https://pixabay.com/api/?key={API_KEY}&q={encoded_q}&image_type=photo&safesearch=true&per_page=5"
    req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
    try:
        with urllib.request.urlopen(req) as resp:
            data = json.loads(resp.read().decode('utf-8'))
            hits = data.get('hits', [])
            best = None
            for h in hits:
                preview = h.get('previewURL', '')
                if preview and 'cdn.pixabay.com' in preview:
                    # convert preview to 640 and 1280
                    cdn_640 = preview.replace('_150.jpg', '_640.jpg').replace('_150.png', '_640.png')
                    cdn_1280 = preview.replace('_150.jpg', '_1280.jpg').replace('_150.png', '_1280.png')
                    best = {
                        "id": h['id'],
                        "tags": h.get('tags', ''),
                        "cdn_640": cdn_640,
                        "cdn_1280": cdn_1280,
                        "pageURL": h.get('pageURL', '')
                    }
                    break
            if best:
                results[key] = best
                print(f"MATCH [{key}]: {best['tags']} -> {best['cdn_640']}")
            else:
                print(f"NO DIRECT CDN HIT for [{key}] with query: {query}")
    except Exception as e:
        print(f"Error querying for [{key}]: {e}")

with open('/workspace/app-egd29h5g4zcx/tasks/pixabay_exact_matches.json', 'w') as f:
    json.dump(results, f, indent=2)

print("\nDone! Saved to /workspace/app-egd29h5g4zcx/tasks/pixabay_exact_matches.json")
