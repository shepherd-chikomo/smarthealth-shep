#!/usr/bin/env bash
docker compose -f /opt/smarthealth/docker-compose.yml exec -T smarthealth-api \
  wget -qO- 'http://127.0.0.1:3000/v1/search/facilities?q=Claremont&lat=-17.8&lon=31.0&radiusKm=50&limit=5'
