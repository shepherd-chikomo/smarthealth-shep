#!/bin/bash
set -euo pipefail
echo "SELECT COUNT(latitude) AS with_coords, COUNT(*) AS total FROM facilities WHERE import_source='HPA';" \
  | ssh smarthealth-dev 'cd /opt/smarthealth && docker compose exec -T db psql -U postgres -d postgres -t'
echo "SELECT COUNT(*) AS google_cache FROM geocode_cache WHERE cache_key LIKE 'google:%';" \
  | ssh smarthealth-dev 'cd /opt/smarthealth && docker compose exec -T db psql -U postgres -d postgres -t'
ssh smarthealth-dev 'tail -5 /tmp/geocode-backfill.log 2>/dev/null || true'
ssh smarthealth-dev 'pgrep -af geocode_facilities || echo "backfill not running"'
