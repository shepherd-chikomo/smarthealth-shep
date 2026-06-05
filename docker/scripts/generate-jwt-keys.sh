#!/bin/sh
# Generate ANON_KEY and SERVICE_ROLE_KEY from JWT_SECRET in .env or environment.
# Usage (from repo root):
#   sh docker/scripts/generate-jwt-keys.sh
set -eu

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
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

docker run --rm -e JWT_SECRET node:20-alpine node <<'NODE'
const crypto = require('crypto');
const secret = process.env.JWT_SECRET;
if (!secret) {
  console.error('JWT_SECRET missing inside container');
  process.exit(1);
}
function b64url(obj) {
  return Buffer.from(JSON.stringify(obj)).toString('base64url');
}
function sign(role) {
  const header = b64url({ alg: 'HS256', typ: 'JWT' });
  const now = Math.floor(Date.now() / 1000);
  const payload = b64url({ role, iss: 'supabase', iat: now, exp: now + 60 * 60 * 24 * 365 * 10 });
  const data = header + '.' + payload;
  const sig = crypto.createHmac('sha256', secret).update(data).digest('base64url');
  return data + '.' + sig;
}
console.log('ANON_KEY=' + sign('anon'));
console.log('SERVICE_ROLE_KEY=' + sign('service_role'));
NODE
