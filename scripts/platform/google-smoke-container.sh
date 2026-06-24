#!/bin/bash
cd /opt/smarthealth
docker compose exec -T smarthealth-api npx tsx <<'TS'
import './src/import/geocode-google.js';
const k = process.env.GOOGLE_MAPS_API_KEY ?? '';
const r = await fetch(`https://maps.googleapis.com/maps/api/geocode/json?address=Harare,Zimbabwe&key=${k}`);
const j = await r.json();
console.log('container_fetch_status:', j.status);
if (j.error_message) console.log('error:', j.error_message);
TS
