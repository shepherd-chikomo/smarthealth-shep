#!/usr/bin/env bash
# SmartHealth Supabase — Local Start Script (Unix)
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

RESET=false
STATUS=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --reset) RESET=true; shift ;;
    --status) STATUS=true; shift ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

command -v supabase >/dev/null 2>&1 || {
  echo "Supabase CLI not found. Install: https://supabase.com/docs/guides/cli"
  exit 1
}

if $STATUS; then
  supabase status
  exit 0
fi

echo "==> Starting SmartHealth Supabase local stack..."
supabase start

if $RESET; then
  echo "==> Resetting database (migrations + seed)..."
  supabase db reset
fi

echo ""
echo "==> SmartHealth Supabase is ready"
echo ""
supabase status

echo ""
echo "Next steps:"
echo "  1. cp supabase/env/.env.local.example .env.local"
echo "  2. Update keys from 'supabase status' output"
echo "  3. Open Studio: http://127.0.0.1:54323"
echo "  4. Run verification: ./scripts/supabase/verify.ps1"
