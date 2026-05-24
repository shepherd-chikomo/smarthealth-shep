#!/usr/bin/env bash
# Bootstrap local SmartHealth stack
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if [ ! -f .env ]; then
  echo "Creating .env from docker/.env.example"
  cp docker/.env.example .env
fi

if [ ! -f docker/nginx/ssl/fullchain.pem ]; then
  echo "Generating self-signed SSL certificates..."
  sh docker/scripts/generate-ssl.sh
fi

echo "Building and starting SmartHealth stack..."
docker compose pull db redis kong auth rest storage meta studio prometheus grafana 2>/dev/null || true
docker compose build smarthealth-api smarthealth-admin smarthealth-facility-portal
docker compose up -d

echo ""
echo "Waiting for services to become healthy (up to 3 minutes)..."
sleep 10

for i in $(seq 1 18); do
  if docker compose ps smarthealth-api nginx 2>/dev/null | grep -q healthy; then
    break
  fi
  sleep 10
done

sh docker/scripts/healthcheck.sh || true

echo ""
echo "=== SmartHealth is running ==="
echo "  Portal:     http://localhost/"
echo "  Admin:      http://localhost/admin/"
echo "  API:        http://localhost/v1/"
echo "  API Docs:   http://localhost/docs"
echo "  Supabase:   http://localhost:8000"
echo "  Studio:     http://localhost:54323"
echo ""
echo "  Monitoring: docker compose --profile monitoring up -d"
echo "  Backups:    docker compose --profile backup up -d"
