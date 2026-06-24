#!/bin/bash
set -euo pipefail
cd /opt/smarthealth
KEY="$1"
python3 <<PY
from pathlib import Path
key = """${KEY}"""
p = Path(".env")
lines = p.read_text().splitlines()
out = []
for line in lines:
    if line.startswith("GOOGLE_MAPS_API_KEY="):
        continue
    if line.startswith("BACKUP_SCHEDULE=") and not line.startswith('BACKUP_SCHEDULE="'):
        val = line.split("=", 1)[1]
        out.append(f'BACKUP_SCHEDULE="{val}"')
    else:
        out.append(line)
out.append(f"GOOGLE_MAPS_API_KEY={key}")
p.write_text("\n".join(out) + "\n")
print("env_fixed")
PY
docker compose config 2>&1 | grep GOOGLE_MAPS_API_KEY
docker compose up -d --force-recreate smarthealth-api
LEN="$(docker compose exec -T smarthealth-api printenv GOOGLE_MAPS_API_KEY | wc -c)"
echo "container_key_bytes=${LEN}"
KEY_VAL="$(docker compose exec -T smarthealth-api printenv GOOGLE_MAPS_API_KEY)"
STATUS="$(curl -s "https://maps.googleapis.com/maps/api/geocode/json?address=Harare,Zimbabwe&key=${KEY_VAL}" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("status",""))')"
echo "google_smoke_status=${STATUS}"
