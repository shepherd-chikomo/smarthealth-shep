#!/bin/sh
# Generate ANON_KEY and SERVICE_ROLE_KEY from JWT_SECRET in .env or environment.
# Usage (from repo root):
#   sh docker/scripts/generate-jwt-keys.sh
set -eu

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"

if [ -z "${JWT_SECRET:-}" ] && [ -f .env ]; then
  JWT_SECRET=$(grep '^JWT_SECRET=' .env | cut -d= -f2- | tr -d '\r')
  export JWT_SECRET
fi

if [ -z "${JWT_SECRET:-}" ]; then
  echo "ERROR: JWT_SECRET is not set. Add it to .env or: export JWT_SECRET='...'" >&2
  exit 1
fi

if [ "${#JWT_SECRET}" -lt 32 ]; then
  echo "ERROR: JWT_SECRET must be at least 32 characters (got ${#JWT_SECRET})." >&2
  exit 1
fi

echo "Using JWT_SECRET (${#JWT_SECRET} chars)..." >&2

docker run --rm \
  -e JWT_SECRET \
  -v "${SCRIPT_DIR}/generate-jwt-keys.js:/generate-jwt-keys.js:ro" \
  node:20-alpine \
  node /generate-jwt-keys.js
