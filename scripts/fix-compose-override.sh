#!/bin/bash
set -euo pipefail
cd /opt/smarthealth
python3 <<'PY'
from pathlib import Path
p = Path("docker-compose.override.yml")
text = p.read_text()
text = text.replace("      GOOGLE_MAPS_API_KEY: EOF\n", "")
p.write_text(text)
print("removed bad GOOGLE_MAPS_API_KEY from override")
PY
docker compose config | grep GOOGLE_MAPS_API_KEY
docker compose up -d --force-recreate smarthealth-api
LEN="$(docker compose exec -T smarthealth-api printenv GOOGLE_MAPS_API_KEY | wc -c)"
echo "container_key_bytes=${LEN}"
KEY_VAL="$(docker compose exec -T smarthealth-api printenv GOOGLE_MAPS_API_KEY)"
STATUS="$(curl -s "https://maps.googleapis.com/maps/api/geocode/json?address=Harare,Zimbabwe&key=${KEY_VAL}" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("status",""))')"
echo "google_smoke_status=${STATUS}"
