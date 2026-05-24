#!/bin/sh
# Verify all SmartHealth Docker services are healthy
set -eu

COMPOSE="${COMPOSE:-docker compose}"
FAILED=0

check() {
  name="$1"
  if $COMPOSE ps --status running "$name" 2>/dev/null | grep -q "$name"; then
    health=$($COMPOSE ps --format json "$name" 2>/dev/null | grep -o '"Health":"[^"]*"' | head -1 || echo "")
    if echo "$health" | grep -qE 'healthy|""'; then
      echo "OK  $name"
    else
      echo "WARN $name (running, health pending)"
    fi
  else
    echo "FAIL $name (not running)"
    FAILED=1
  fi
}

echo "=== SmartHealth Stack Health Check ==="
echo ""

for svc in db redis kong auth smarthealth-migrate smarthealth-api smarthealth-admin smarthealth-facility-portal nginx; do
  check "$svc"
done

echo ""
echo "--- Endpoint checks ---"

if wget -qO- http://localhost/health 2>/dev/null | grep -q '"status"'; then
  echo "OK  http://localhost/health"
else
  echo "FAIL http://localhost/health"
  FAILED=1
fi

if wget -qO- http://localhost:8000/auth/v1/health 2>/dev/null | grep -qE 'GoTrue|ok|version'; then
  echo "OK  Supabase Auth (Kong :8000)"
else
  echo "WARN Supabase Auth endpoint (may need first boot time)"
fi

echo ""
if [ "$FAILED" -eq 0 ]; then
  echo "All core services healthy."
  exit 0
else
  echo "Some services failed. Run: docker compose ps"
  exit 1
fi
