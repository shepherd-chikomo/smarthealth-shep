#!/bin/sh
# Apply SmartHealth SQL migrations in order, skipping already-applied files.
set -eu

MIGRATIONS_DIR="${MIGRATIONS_DIR:-/migrations}"

echo "==> SmartHealth migration runner"
echo "    Host: ${PGHOST}:${PGPORT}/${PGDATABASE}"

psql -v ON_ERROR_STOP=1 <<'SQL'
CREATE TABLE IF NOT EXISTS public.schema_migrations (
  filename text PRIMARY KEY,
  applied_at timestamptz NOT NULL DEFAULT timezone('utc', now())
);
SQL

for migration in $(ls -1 "${MIGRATIONS_DIR}"/*.sql 2>/dev/null | sort); do
  filename=$(basename "$migration")
  applied=$(psql -tAc "SELECT 1 FROM public.schema_migrations WHERE filename = '${filename}'" || echo "")
  if [ "$applied" = "1" ]; then
    echo "    Skipping (already applied): ${filename}"
    continue
  fi
  echo "    Applying: ${filename}"
  psql -v ON_ERROR_STOP=1 -f "$migration"
  psql -v ON_ERROR_STOP=1 -c \
    "INSERT INTO public.schema_migrations (filename) VALUES ('${filename}')"
done

echo "==> All pending migrations applied successfully"
