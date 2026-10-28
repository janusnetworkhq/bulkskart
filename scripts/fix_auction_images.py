#!/usr/bin/env python3
"""Reassign distinct title-relevant images to all auctions (run on prod VM)."""
import hashlib
import re
import subprocess

RULES = [
    (
        r"kraft|paper\s*bag|linerboard|corrugat|carton|packaging|box",
        [
            "https://images.unsplash.com/photo-1553413077-190dd305871c?auto=format&fit=crop&w=800&q=80",
            "https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?auto=format&fit=crop&w=800&q=80",
            "https://cdn.pixabay.com/photo/2016/11/21/14/53/boxes-1845814_1280.jpg",
            "https://images.unsplash.com/photo-1604719312566-8912e9227c6a?auto=format&fit=crop&w=800&q=80",
        ],
    ),
    (
        r"cotton|yarn|textile|fabric|apparel|garment|t-?shirt|woven|knit",
        [
            "https://images.unsplash.com/photo-1606744837616-56c9a5c6a6eb?auto=format&fit=crop&w=800&q=80",
            "https://images.unsplash.com/photo-1558171813-4c0887533814?auto=format&fit=crop&w=800&q=80",
            "https://images.unsplash.com/photo-1489987707025-afc232f7ea0f?auto=format&fit=crop&w=800&q=80",
            "https://cdn.pixabay.com/photo/2016/11/19/18/06/cotton-1840424_1280.jpg",
        ],
    ),
    (
        r"polymer|plastic|polyethylene|polypropylene|abs|pet\b|nylon|resin|granule|pellet|hdpe|ldpe|pvc",
        [
            "https://images.unsplash.com/photo-1615906655593-ad0386982a0f?auto=format&fit=crop&w=800&q=80",
            "https://cdn.pixabay.com/photo/2017/10/25/17/36/cans-2888650_1280.jpg",
            "https://images.unsplash.com/photo-1565043666747-69f6646db940?auto=format&fit=crop&w=800&q=80",
            "https://images.unsplash.com/photo-1581091226825-a6a2a5aee158?auto=format&fit=crop&w=800&q=80",
        ],
    ),
    (
        r"rubber|epdm|sbr|tyre|tire|elastomer",
        [
            "https://images.unsplash.com/photo-1558618666-fcd25c85cd64?auto=format&fit=crop&w=800&q=80",
            "https://cdn.pixabay.com/photo/2017/04/11/16/12/leather-2222053_1280.jpg",
            "https://images.unsplash.com/photo-1486262715619-67b85e0b08d3?auto=format&fit=crop&w=800&q=80",
        ],
    ),
    (
        r"steel|metal|copper|aluminium|aluminum|iron|coil|rebar|wire|ingot|extrusion",
        [
            "https://images.unsplash.com/photo-1504917599217-d4dc5ebe6122?auto=format&fit=crop&w=800&q=80",
            "https://images.unsplash.com/photo-1504328345608-5c56ce5c6f0f?auto=format&fit=crop&w=800&q=80",
            "https://images.unsplash.com/photo-1565793298595-6a381b3f1f4d?auto=format&fit=crop&w=800&q=80",
            "https://cdn.pixabay.com/photo/2016/11/29/09/32/welding-1868731_1280.jpg",
        ],
    ),
    (
        r"solar|inverter|led|electrical|cable|switchgear|transformer",
        [
            "https://images.unsplash.com/photo-1509391365360-2e959784a276?auto=format&fit=crop&w=800&q=80",
            "https://images.unsplash.com/photo-1565814329452-7811bc3270c0?auto=format&fit=crop&w=800&q=80",
            "https://images.unsplash.com/photo-1473341304170-971dccb5ac1e?auto=format&fit=crop&w=800&q=80",
        ],
    ),
    (
        r"cnc|machine|mould|mold|plant|equipment|motor|pump|gear",
        [
            "https://images.unsplash.com/photo-1581091226825-a6a2a5aee158?auto=format&fit=crop&w=800&q=80",
            "https://images.unsplash.com/photo-1581092918056-0c4c3acd3789?auto=format&fit=crop&w=800&q=80",
            "https://images.unsplash.com/photo-1565043666747-69f6646db940?auto=format&fit=crop&w=800&q=80",
        ],
    ),
    (
        r"chemical|solvent|acid|reagent|pharma|lab",
        [
            "https://images.unsplash.com/photo-1532187863486-abf9dbad1b69?auto=format&fit=crop&w=800&q=80",
            "https://cdn.pixabay.com/photo/2016/11/29/09/16/architecture-1868667_1280.jpg",
        ],
    ),
    (
        r"grain|rice|wheat|maize|corn|turmeric|spice|agro|food|oil\s*seed",
        [
            "https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?auto=format&fit=crop&w=800&q=80",
            "https://images.unsplash.com/photo-1586201375761-83865001e31c?auto=format&fit=crop&w=800&q=80",
            "https://images.unsplash.com/photo-1530587191325-3db32d826c18?auto=format&fit=crop&w=800&q=80",
        ],
    ),
    (
        r"ceramic|pottery|marble|brass|handicraft|carpet|rug|embroidery|leather",
        [
            "https://images.unsplash.com/photo-1578749556568-bc2c40e68b61?auto=format&fit=crop&w=800&q=80",
            "https://images.unsplash.com/photo-1600585154340-be6161a56a0c?auto=format&fit=crop&w=800&q=80",
            "https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?auto=format&fit=crop&w=800&q=80",
        ],
    ),
    (
        r"bottle|can|jerry|drum|container|stainless|flask",
        [
            "https://cdn.pixabay.com/photo/2017/10/25/17/36/cans-2888650_1280.jpg",
            "https://images.unsplash.com/photo-1602143407151-7111542de6e8?auto=format&fit=crop&w=800&q=80",
        ],
    ),
]

FALLBACK = [
    "https://images.unsplash.com/photo-1581091226825-a6a2a5aee158?auto=format&fit=crop&w=800&q=80",
    "https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?auto=format&fit=crop&w=800&q=80",
    "https://images.unsplash.com/photo-1504917599217-d4dc5ebe6122?auto=format&fit=crop&w=800&q=80",
    "https://images.unsplash.com/photo-1509391365360-2e959784a276?auto=format&fit=crop&w=800&q=80",
    "https://images.unsplash.com/photo-1553413077-190dd305871c?auto=format&fit=crop&w=800&q=80",
    "https://images.unsplash.com/photo-1615906655593-ad0386982a0f?auto=format&fit=crop&w=800&q=80",
    "https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?auto=format&fit=crop&w=800&q=80",
    "https://images.unsplash.com/photo-1581092918056-0c4c3acd3789?auto=format&fit=crop&w=800&q=80",
    "https://cdn.pixabay.com/photo/2016/11/29/09/32/welding-1868731_1280.jpg",
    "https://images.unsplash.com/photo-1565814329452-7811bc3270c0?auto=format&fit=crop&w=800&q=80",
    "https://images.unsplash.com/photo-1532187863486-abf9dbad1b69?auto=format&fit=crop&w=800&q=80",
    "https://images.unsplash.com/photo-1504328345608-5c56ce5c6f0f?auto=format&fit=crop&w=800&q=80",
]


def h(s: str) -> int:
    return int(hashlib.md5(s.encode()).hexdigest()[:8], 16)


def pick(pool, key):
    return pool[h(key) % len(pool)]


def resolve(aid, title):
    key = f"{aid}|{title}"
    for pat, urls in RULES:
        if re.search(pat, title or "", re.I):
            return pick(urls, key)
    return pick(FALLBACK, key)


def main():
    raw = subprocess.check_output(
        [
            "docker",
            "exec",
            "supabase-db",
            "psql",
            "-U",
            "postgres",
            "-d",
            "postgres",
            "-t",
            "-A",
            "-F",
            "|",
            "-c",
            "SELECT id, title FROM auctions ORDER BY created_at",
        ],
        text=True,
    )
    rows = [ln.split("|", 1) for ln in raw.strip().splitlines() if "|" in ln]
    # Prefer unused URLs within the matched category pool; allow reuse only after pool exhaustion
    used = set()
    updates = []
    for aid, title in rows:
        url = resolve(aid, title)
        if url in used:
            pool = FALLBACK
            for pat, urls in RULES:
                if re.search(pat, title or "", re.I):
                    pool = urls
                    break
            for salt in range(len(pool) * 3):
                cand = pick(pool, f"{aid}-salt-{salt}")
                if cand not in used:
                    url = cand
                    break
            else:
                # Pool exhausted — still title-hash so similar titles diverge when possible
                url = pick(pool + FALLBACK, f"{aid}|{title}|final")
        used.add(url)
        updates.append((aid, url))

    sql_path = "/tmp/fix_auction_images.sql"
    with open(sql_path, "w") as f:
        f.write("BEGIN;\n")
        for aid, url in updates:
            esc = url.replace("'", "''")
            f.write(f"UPDATE auctions SET images = ARRAY['{esc}']::text[] WHERE id = '{aid}';\n")
        f.write("COMMIT;\n")

    with open(sql_path, "rb") as f:
        subprocess.check_call(
            ["docker", "exec", "-i", "supabase-db", "psql", "-U", "postgres", "-d", "postgres"],
            stdin=f,
        )
    print(f"UPDATED {len(updates)} auctions; unique images={len(used)}")
    print(
        subprocess.check_output(
            [
                "docker",
                "exec",
                "supabase-db",
                "psql",
                "-U",
                "postgres",
                "-d",
                "postgres",
                "-c",
                "SELECT images[1], count(*) FROM auctions GROUP BY 1 ORDER BY 2 DESC LIMIT 10;",
            ],
            text=True,
        )
    )


if __name__ == "__main__":
    main()
