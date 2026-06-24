#!/bin/bash
set -euo pipefail
cd /opt/smarthealth
KEY="$1"
if [ -z "$KEY" ]; then
  echo "usage: fix-dev-google-env.sh API_KEY" >&2
  exit 1
fi
python3 <<PY
from pathlib import Path
key = """${KEY}"""
env = Path(".env")
lines = env.read_text().splitlines()
out = []
found = False
for line in lines:
    if line.startswith("GOOGLE_MAPS_API_KEY="):
        out.append(f"GOOGLE_MAPS_API_KEY={key}")
        found = True
    else:
        out.append(line)
if not found:
    out.append(f"GOOGLE_MAPS_API_KEY={key}")
env.write_text("\n".join(out) + "\n")
print(f"env_key_len={len(key)}")
PY
python3 <<'PY'
from pathlib import Path
p = Path("docker-compose.yml")
text = p.read_text()
if "GOOGLE_MAPS_API_KEY: ${GOOGLE_MAPS_API_KEY:-}" not in text:
    text = text.replace(
        "      GOOGLE_MAPS_API_KEY: \n",
        "      GOOGLE_MAPS_API_KEY: ${GOOGLE_MAPS_API_KEY:-}\n",
    )
    p.write_text(text)
print("compose_ok")
PY
docker compose up -d --force-recreate smarthealth-api
LEN="$(docker compose exec -T smarthealth-api printenv GOOGLE_MAPS_API_KEY | wc -c)"
echo "container_key_bytes=${LEN}"
