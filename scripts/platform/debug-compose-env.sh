#!/bin/bash
cd /opt/smarthealth
echo "dotenv line:"
grep ^GOOGLE_MAPS_API_KEY= .env | wc -c
echo "compose grep:"
docker compose config | grep GOOGLE || true
echo "shell export:"
set -a
source .env
set +a
echo "len=${#GOOGLE_MAPS_API_KEY}"
