# SmartHealth Supabase Backend

Production-grade PostgreSQL backend for SmartHealth — multi-tenant healthcare architecture with Zimbabwe focus.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Supabase Platform                        │
├──────────────┬──────────────┬──────────────┬────────────────┤
│     Auth     │   Storage    │   Realtime   │   PostgreSQL   │
│  Email/OTP   │  5 buckets   │ appointments │  RLS + audit   │
│  JWT + RBAC  │  RLS policies│  providers   │  multi-tenant  │
└──────────────┴──────────────┴──────────────┴────────────────┘
```

### Roles

| Role | Scope | Capabilities |
|------|-------|--------------|
| `super_admin` | Platform | Full access, audit logs, facility management |
| `facility_admin` | Tenant | Manage staff, providers, facility settings |
| `doctor` | Tenant | Appointments, prescriptions, medical documents |
| `receptionist` | Tenant | Bookings, check-in, document upload |
| `patient` | Self | Own profile, family, appointments, documents |

### Storage Buckets

| Bucket | Access | Path pattern |
|--------|--------|--------------|
| `provider-images` | Public read | `{facility_id}/{provider_id}/{file}` |
| `medical-documents` | Private | `{facility_id}/{patient_id}/{doc_id}/{file}` |
| `prescriptions` | Private | `{facility_id}/{patient_id}/{rx_id}/{file}` |
| `facility-assets` | Public read | `{facility_id}/{type}/{file}` |
| `avatars` | Public read | `{user_id}/{file}` |

## Quick Start (Local)

### Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- [Supabase CLI](https://supabase.com/docs/guides/cli/getting-started)

```powershell
# Install Supabase CLI (Windows)
scoop install supabase
# or: npm install -g supabase

# Start local stack
supabase start

# Apply migrations + seed (first run)
supabase db reset

# View credentials
supabase status
```

Local services:

| Service | URL |
|---------|-----|
| API | http://127.0.0.1:54321 |
| Studio | http://127.0.0.1:54323 |
| Inbucket (email) | http://127.0.0.1:54324 |
| PostgreSQL | localhost:54322 |

Copy environment variables:

```powershell
cp supabase/env/.env.local.example .env.local
# Update keys from `supabase status` output
```

### Flutter integration

```powershell
flutter run `
  --dart-define=SUPABASE_URL=http://127.0.0.1:54321 `
  --dart-define=SUPABASE_ANON_KEY=<anon-key-from-supabase-status>
```

## Auth

### Email signup

```sql
-- Via Supabase client:
-- supabase.auth.signUp({ email, password, options: { data: { first_name, last_name } } })
```

Local emails appear in Inbucket: http://127.0.0.1:54324

### Phone OTP (Zimbabwe +263)

Test numbers configured in `config.toml`:

| Phone | OTP |
|-------|-----|
| +263771234567 | 123456 |
| +263771111111 | 654321 |

Production: configure Twilio or Africa's Talking in Dashboard → Auth → Phone.

### JWT & refresh tokens

- Access token expiry: 1 hour (`auth.jwt_expiry`)
- Refresh token rotation: enabled
- Custom claims via `custom_access_token_hook`: `user_role`, `facility_ids`, `app`

### Bootstrap super admin

```sql
-- After creating user via Auth, promote via service role:
update public.profiles
set primary_role = 'super_admin'
where email = 'admin@smarthealth.co.zw';
```

## Migrations

Migrations run in timestamp order:

| File | Purpose |
|------|---------|
| `20260523100000_extensions_and_types.sql` | Extensions, enums, utilities |
| `20260523100100_core_tenant_schema.sql` | Facilities, profiles, memberships |
| `20260523100200_healthcare_entities.sql` | Providers, appointments, documents |
| `20260523100300_auth_and_rbac.sql` | Auth hooks, JWT claims, RBAC helpers |
| `20260523100400_row_level_security.sql` | RLS policies |
| `20260523100500_storage_buckets.sql` | Storage buckets + policies |
| `20260523100600_audit_logging.sql` | Audit trail |
| `20260523100700_realtime.sql` | Realtime publication |
| `20260523110000_postgis_and_enums.sql` | PostGIS, lifecycle enums |
| `20260523110100_tenant_infrastructure.sql` | tenant_id, claiming, countries/cities |
| `20260523110200_appointments_extended.sql` | Walk-ins, queue, notes, payments |
| `20260523110300_medical_records.sql` | Consultations, diagnoses, vitals, allergies |
| `20260523110400_billing.sql` | Invoices, payments, refunds |
| `20260523110500_inventory.sql` | Products, stock, suppliers, POs |
| `20260523110600_notifications.sql` | Push, SMS, email notifications |
| `20260523110700_analytics_and_emergency_services.sql` | Analytics, emergency_services |
| `20260523110800_search_and_indexes.sql` | FTS search_vector, GIS functions |
| `20260523110900_rls_extended.sql` | RLS for all extended tables |
| `20260523111000_audit_and_realtime_extended.sql` | Audit + realtime for new tables |
| `20260523120000_rls_security_functions.sql` | RLS security helpers + audit events |
| `20260523120100_rls_policies_comprehensive.sql` | Full role-based RLS policies |
| `20260523120200_provider_reviews.sql` | Provider reviews and ratings |

### Schema domains

| Domain | Tables |
|--------|--------|
| Tenants | `facilities` (+ `tenant_id`), `facility_memberships`, `facility_claims`, `provider_claims` |
| Appointments | `appointments`, `walk_in_sessions`, `queue_sessions`, `appointment_*` |
| Medical | `consultations`, `diagnoses`, `prescriptions`, `lab_results`, `vitals`, `allergies`, `chronic_conditions` |
| Billing | `invoices`, `invoice_items`, `payments`, `payment_transactions`, `refunds`, `appointment_payments` |
| Inventory | `products`, `stock_movements`, `suppliers`, `purchase_orders`, `purchase_order_items` |
| Notifications | `notifications`, `push_tokens`, `notification_preferences`, `sms_logs`, `email_logs` |
| Analytics | `activity_logs`, `usage_metrics`, `revenue_reports`, `audit.logs` |
| System | `app_settings`, `countries`, `cities`, `specialties`, `emergency_services` |

```powershell
# Create new migration
supabase migration new my_change

# Push to remote
supabase db push

# Diff local vs remote
supabase db diff
```

## Environments

| Environment | Config | Deploy |
|-------------|--------|--------|
| Local | `supabase/env/.env.local.example` | `supabase start` |
| Staging | `supabase/env/.env.staging.example` | `supabase link` + `db push` |
| Production | `supabase/env/.env.production.example` | Self-host or Supabase Cloud |

See [docs/supabase/SELF_HOST_MIGRATION.md](../docs/supabase/SELF_HOST_MIGRATION.md) for self-hosting.

See [docs/supabase/RLS.md](../docs/supabase/RLS.md) for Row Level Security policies and security tests.

## Docker (standalone)

```powershell
# Standalone Postgres with migrations (testing without full Supabase)
docker compose -f docker/docker-compose.yml --profile standalone up -d

# Run backup
docker compose -f docker/docker-compose.yml --profile backup run --rm smarthealth-backup
```

## Verification

```powershell
# Run acceptance checks (requires supabase CLI + Docker)
./scripts/supabase/verify.ps1
```

## Documentation

- [Self-Host Migration Guide](../docs/supabase/SELF_HOST_MIGRATION.md)
- [Auth Configuration](../docs/supabase/AUTH.md)
- [Backup & Recovery](../docs/supabase/BACKUP.md)
