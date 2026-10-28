#!/usr/bin/env python3
"""Import JSON table dumps into Postgres with correct array/jsonb handling."""
from __future__ import annotations

import json
import os
import sys
from pathlib import Path

try:
    import psycopg
    from psycopg.types.json import Jsonb
except ImportError:
    import subprocess

    subprocess.check_call([sys.executable, "-m", "pip", "install", "psycopg[binary]", "-q"])
    import psycopg
    from psycopg.types.json import Jsonb

DATA_DIR = Path(sys.argv[1] if len(sys.argv) > 1 else "backups/supabase-20261009/data")
DSN = os.environ.get(
    "DATABASE_URL",
    "postgresql://postgres:postgres@127.0.0.1:5432/postgres",
)

ORDER = [
    "categories",
    "companies",
    "profiles",
    "products",
    "company_certifications",
    "requirements",
    "auctions",
    "auction_bids",
    "buyer_profiles",
    "product_inventory",
    "quotations",
    "orders",
    "conversations",
    "messages",
    "notifications",
    "subscriptions",
    "subscription_orders",
    "buyer_subscriptions",
    "company_reviews",
    "sample_requests",
    "saved_manufacturers",
    "bulk_discount_rules",
    "auto_quotations",
    "rfq_matches",
]


def adapt_value(value, typname: str | None):
    if value is None:
        return None
    if typname in ("json", "jsonb"):
        return Jsonb(value)
    if typname and typname.startswith("_"):  # array types e.g. _text, _uuid
        if isinstance(value, str):
            try:
                value = json.loads(value)
            except Exception:
                pass
        if isinstance(value, list):
            return value
        return [value]
    if isinstance(value, (dict, list)) and typname not in ("json", "jsonb"):
        # Fallback: if we somehow get complex types without typname
        return Jsonb(value) if isinstance(value, dict) else value
    return value


def column_types(cur, table: str) -> dict[str, str]:
    cur.execute(
        """
        SELECT a.attname, t.typname
        FROM pg_attribute a
        JOIN pg_class c ON a.attrelid = c.oid
        JOIN pg_namespace n ON c.relnamespace = n.oid
        JOIN pg_type t ON a.atttypid = t.oid
        WHERE n.nspname = 'public' AND c.relname = %s AND a.attnum > 0 AND NOT a.attisdropped
        """,
        (table,),
    )
    return {r[0]: r[1] for r in cur.fetchall()}


def import_table(cur, table: str, rows: list[dict], types: dict[str, str]):
    if not rows:
        print(f"{table}: skip empty")
        return
    cols = [c for c in rows[0].keys() if c in types]
    col_list = ", ".join(f'"{c}"' for c in cols)
    placeholders = ", ".join(["%s"] * len(cols))
    sql = f'INSERT INTO public."{table}" ({col_list}) VALUES ({placeholders})'
    if "id" in cols:
        updates = ", ".join(f'"{c}" = EXCLUDED."{c}"' for c in cols if c != "id")
        sql += f' ON CONFLICT ("id") DO UPDATE SET {updates}'

    ok = 0
    for row in rows:
        vals = [adapt_value(row.get(c), types.get(c)) for c in cols]
        cur.execute(sql, vals)
        ok += 1
    print(f"{table}: imported {ok}/{len(rows)}")


def main():
    print(f"Connecting ... from {DATA_DIR}")
    with psycopg.connect(DSN) as conn:
        conn.execute("SET session_replication_role = replica")
        for table in ORDER:
            path = DATA_DIR / f"{table}.json"
            if not path.exists():
                continue
            rows = json.loads(path.read_text())
            if not isinstance(rows, list):
                print(f"{table}: bad json")
                continue
            with conn.cursor() as cur:
                types = column_types(cur, table)
                if not types:
                    print(f"{table}: table missing, skip")
                    continue
                try:
                    import_table(cur, table, rows, types)
                    conn.commit()
                except Exception as e:
                    conn.rollback()
                    print(f"{table}: ABORT {e}")
        conn.execute("SET session_replication_role = DEFAULT")
        conn.commit()
    print("DONE")


if __name__ == "__main__":
    main()
