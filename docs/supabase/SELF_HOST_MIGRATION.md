# SmartHealth Self-Host Migration Guide

This guide covers deploying SmartHealth's Supabase backend on your own infrastructure — suitable for Zimbabwe data residency requirements and air-gapped deployments.

## Overview

SmartHealth uses standard Supabase migrations that work identically on:

1. **Supabase Cloud** — managed hosting
2. **Supabase CLI local** — development
3. **Self-hosted Docker** — production on your VPS/cloud

All schema, RLS, storage, auth hooks, and audit logging are defined in `supabase/migrations/`.

## Option A: Supabase Cloud (fastest)

```bash
# Create project at https://supabase.com/dashboard
supabase login
supabase link --project-ref YOUR_PROJECT_REF

# Push migrations
supabase db push

# Seed reference data (optional)
psql "$DATABASE_URL" -f supabase/seed.sql
```

Configure in Dashboard:

- **Auth → Providers**: Enable Email, Phone (SMS provider)
- **Auth → Hooks**: Enable Custom Access Token → `public.custom_access_token_hook`
- **Storage**: Buckets are created by migration; verify in Dashboard
- **Database → Extensions**: `pgcrypto`, `pg_trgm` (auto-enabled by migration)

## Option B: Self-Hosted Docker (full control)

### 1. Clone official Supabase Docker

```bash
git clone --depth 1 https://github.com/supabase/supabase.git /opt/supabase-docker
cd /opt/supabase-docker/docker
cp .env.example .env
```

### 2. Configure environment

Merge values from `supabase/env/.env.production.example` into `/opt/supabase-docker/docker/.env`:

```bash
# Required secrets — generate with: openssl rand -base64 32
POSTGRES_PASSWORD=<strong-password>
JWT_SECRET=<32+-char-secret>
ANON_KEY=<generate-via-supabase-jwt-tool>
SERVICE_ROLE_KEY=<generate-via-supabase-jwt-tool>

# SmartHealth
SITE_URL=https://app.smarthealth.co.zw

# Storage — S3 compatible (AWS af-south-1 recommended)
STORAGE_BACKEND=s3
GLOBAL_S3_BUCKET=smarthealth-storage
REGION=af-south-1
```

Generate JWT keys:

```bash
# Using Supabase CLI after linking, or:
# https://supabase.com/docs/guides/self-hosting/docker#generate-api-keys
```

### 3. Start the stack

```bash
cd /opt/supabase-docker/docker
docker compose pull
docker compose up -d
```

Wait for all services to be healthy:

```bash
docker compose ps
curl http://localhost:8000/rest/v1/ -H "apikey: $ANON_KEY"
```

### 4. Apply SmartHealth migrations

```bash
# From SmartHealth repo root
export DATABASE_URL="postgresql://postgres:$POSTGRES_PASSWORD@localhost:5432/postgres"

# Option 1: Supabase CLI
supabase db push --db-url "$DATABASE_URL"

# Option 2: Migration runner container
docker compose -f docker/docker-compose.yml --profile migrate run --rm smarthealth-migrate

# Option 3: Manual
for f in supabase/migrations/*.sql; do psql "$DATABASE_URL" -f "$f"; done
```

### 5. Seed reference data

```bash
psql "$DATABASE_URL" -f supabase/seed.sql
```

### 6. Enable auth hook

In self-hosted Kong/Auth config, enable the custom access token hook:

```
GOTRUE_HOOK_CUSTOM_ACCESS_TOKEN_ENABLED=true
GOTRUE_HOOK_CUSTOM_ACCESS_TOKEN_URI=pg-functions://postgres/public/custom_access_token_hook
```

Or via `config.toml` (already configured for CLI local):

```toml
[auth.hook.custom_access_token]
enabled = true
uri = "pg-functions://postgres/public/custom_access_token_hook"
```

Restart auth service after change.

### 7. Configure SMS for Zimbabwe (+263)

For production phone OTP, set in `.env`:

```bash
GOTRUE_SMS_PROVIDER=twilio
GOTRUE_SMS_TWILIO_ACCOUNT_SID=...
GOTRUE_SMS_TWILIO_AUTH_TOKEN=...
GOTRUE_SMS_TWILIO_MESSAGE_SERVICE_SID=...
```

Alternative: Africa's Talking for regional SMS delivery.

## Migration from Local → Staging → Production

### Export schema diff

```bash
supabase db diff --linked > supabase/migrations/$(date +%Y%m%d%H%M%S)_changes.sql
```

### Zero-downtime migration checklist

- [ ] Run migrations on staging first
- [ ] Verify RLS policies with test users per role
- [ ] Test storage upload/download per bucket
- [ ] Confirm auth hook adds JWT claims
- [ ] Run backup before production migration
- [ ] Apply migrations during maintenance window
- [ ] Smoke test: signup, login, book appointment, upload document

### Rollback

```bash
# Restore from backup (see BACKUP.md)
gunzip -c backups/smarthealth-YYYYMMDD.sql.gz | psql "$DATABASE_URL"
```

For partial rollback, create a reverse migration:

```bash
supabase migration new rollback_feature_x
```

## Data Residency (Zimbabwe)

Recommended self-host regions for low latency:

| Provider | Region | Notes |
|----------|--------|-------|
| AWS | af-south-1 (Cape Town) | Closest managed region |
| Hetzner | EU (fallback) | Cost-effective VPS |
| On-premise | Harare/Bulawayo | Full data sovereignty |

Minimum production specs:

- 4 vCPU, 8 GB RAM, 100 GB SSD
- PostgreSQL 15+
- TLS termination (Caddy/Nginx)
- Daily encrypted backups to separate storage

## Networking

Expose only:

| Port | Service | Access |
|------|---------|--------|
| 443 | Kong (API) | Public |
| 443 | Studio | Admin VPN only |
| 5432 | PostgreSQL | Internal only |

## Troubleshooting

| Issue | Fix |
|-------|-----|
| RLS blocks all queries | Check JWT claims; verify `custom_access_token_hook` is enabled |
| Storage 403 | Verify path matches `{facility_id}/...` convention |
| Phone OTP fails | Confirm +263 format; check SMS provider credentials |
| Migrations fail on hook | Ensure `supabase_auth_admin` role exists (Supabase Postgres image includes it) |

## Support

- Supabase self-hosting: https://supabase.com/docs/guides/self-hosting
- SmartHealth migrations: `supabase/migrations/`
- Issues: project maintainers
