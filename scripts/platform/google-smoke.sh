#!/bin/bash
cd /opt/smarthealth
KEY="$(docker compose exec -T smarthealth-api printenv GOOGLE_MAPS_API_KEY)"
for FLAG in "" "-4"; do
  echo "curl ${FLAG}"
  curl ${FLAG} -s "https://maps.googleapis.com/maps/api/geocode/json?address=Harare,Zimbabwe&key=${KEY}" | python3 -c 'import json,sys; d=json.load(sys.stdin); print("status:", d.get("status")); print("error:", d.get("error_message",""))'
done
