#!/bin/bash
cd /opt/smarthealth
docker compose config 2>/tmp/compose-err.txt >/tmp/compose-out.txt
echo "=== stderr ==="
cat /tmp/compose-err.txt
echo "=== GOOGLE in api service ==="
grep -n GOOGLE /tmp/compose-out.txt | head -5
echo "=== container ==="
docker compose exec -T smarthealth-api printenv GOOGLE_MAPS_API_KEY | wc -c
