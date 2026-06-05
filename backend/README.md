# SmartHealth API

REST API backend for the SmartHealth patient app. Connects to the Supabase PostgreSQL database and Supabase Auth for JWT sessions.

## Stack

- **Fastify 5** — HTTP server
- **TypeScript** — type-safe handlers
- **Zod** — request/response validation
- **@fastify/swagger** — OpenAPI 3.1 spec + Swagger UI
- **pg** — PostgreSQL (Supabase)
- **jsonwebtoken** — JWT verification (Supabase-issued tokens)

## Quick start

```powershell
# Prerequisites: Node 20+, Supabase running locally
cd backend
npm install
cp .env.example .env
# Update .env with keys from `supabase status`

npm run dev
```

| URL | Description |
|-----|-------------|
| http://localhost:3000/v1 | API base |
| http://localhost:3000/docs | Swagger UI |
| http://localhost:3000/health | Health check |

## Environment

Copy `.env.example` to `.env`. Required variables:

| Variable | Description |
|----------|-------------|
| `DATABASE_URL` | PostgreSQL connection string |
| `SUPABASE_URL` | Supabase API URL |
| `SUPABASE_ANON_KEY` | Anon key for auth proxy |
| `SUPABASE_JWT_SECRET` | JWT secret for token verification |
| `SUPABASE_SERVICE_ROLE_KEY` | Service role key |

## API endpoints

### Auth
- `POST /v1/auth/otp/send` — Send phone OTP
- `POST /v1/auth/otp/verify` — Verify OTP, get JWT
- `POST /v1/auth/refresh` — Refresh access token
- `POST /v1/auth/logout` — Invalidate session

### Patients (JWT required)
- `GET /v1/patients/me`
- `PATCH /v1/patients/me`
- `GET /v1/patients/family`
- `POST /v1/patients/family`
- `PATCH /v1/patients/family/:id`
- `DELETE /v1/patients/family/:id`

### Providers
- `GET /v1/providers` — List with pagination & filters
- `GET /v1/providers/search` — Full-text search
- `GET /v1/providers/nearby` — Geo search
- `GET /v1/providers/top-rated`
- `GET /v1/providers/:id`

### Facilities
- `GET /v1/facilities`
- `GET /v1/facilities/nearby`
- `GET /v1/facilities/:id`

### Appointments (JWT required)
- `POST /v1/appointments`
- `GET /v1/appointments`
- `GET /v1/appointments/:id`
- `PATCH /v1/appointments/:id`
- `DELETE /v1/appointments/:id`

### Reviews
- `POST /v1/reviews` (JWT)
- `GET /v1/reviews/provider/:id`

### Emergency
- `GET /v1/emergency/services`
- `GET /v1/emergency/nearest`

### Notifications (JWT required)
- `GET /v1/notifications`
- `PATCH /v1/notifications/:id/read`

### Payments
- `POST /v1/payments/initiate` (JWT)
- `POST /v1/payments/webhook`
- `GET /v1/payments/status/:id` (JWT)

## Features

- **Pagination** — `page`, `limit` (max 100), `sortBy`, `sortOrder`
- **Filtering** — category, specialty, province, city, status, etc.
- **Search** — PostgreSQL full-text search on providers/facilities
- **Rate limiting** — Global + stricter limits on OTP endpoints
- **Error handling** — Consistent `{ error: { code, message, details } }` format
- **Validation** — Zod schemas on all request bodies and query params
- **Logging** — Structured Pino logs with request IDs
- **OpenAPI** — Auto-generated at `/docs` and exportable via `npm run openapi:export`

## Authentication

Protected routes require `Authorization: Bearer <access_token>`.

Obtain tokens via OTP flow:

```powershell
# Send OTP (local test number)
curl -X POST http://localhost:3000/v1/auth/otp/send `
  -H "Content-Type: application/json" `
  -d '{"phone":"0771234567"}'

# Verify OTP (test OTP: 123456)
curl -X POST http://localhost:3000/v1/auth/otp/verify `
  -H "Content-Type: application/json" `
  -d '{"phone":"0771234567","otp":"123456"}'
```

## Scripts

```powershell
npm run dev          # Development with hot reload
npm run build        # Compile TypeScript
npm start            # Run production build
npm test             # Run tests
npm run openapi:export  # Export openapi.json
```

## Facility address formatting

HPA spreadsheet addresses may lack spaces (`LaneBorowdale`, `11Madokero`). The import pipeline runs `formatAddressLine` before storage. To repair existing rows:

```powershell
cd backend
npm run fix:addresses -- --dry-run              # preview (default: import_source HPA)
npm run fix:addresses                           # update address_line1 in DB
```

## Facility geocoding

Imported HPA facilities are geocoded on `import:dual` using OpenStreetMap Nominatim (Zimbabwe-only, ~1 request/second). The backfill CLI uses a **multi-strategy cascade** (structured street search, name+address, address-only, name+city) with scoring and city plausibility checks. Results are cached in `public.geocode_cache`; `facilities.geocode_quality` controls whether `/v1/facilities/nearby` returns `distanceKm` (`address`, `name`, `manual` only).

**Fix bad provinces** before geocoding (Nominatim city lookup, caches in `public.cities`):

```powershell
cd backend
npm run fix:provinces -- --dry-run
npm run fix:provinces -- --import-source HPA --csv ../provinces-fixed.csv
```

**Fix bad distances:** reformat addresses, reset coordinates, and geocode again (no city-centre fallback by default on `--reset`):

```powershell
# From repo root (applies migration, fix:addresses, geocode, audit)
.\scripts\regeocode-hpa.ps1

# Or manually:
cd backend
npm run db:migrate:geocode-quality
npm run fix:addresses
npm run geocode:facilities -- --import-source HPA --reset --clear-cache --csv ../geocode-failures.csv
npm run audit:geocode
npm run geocode:import-csv -- --file manual-coords.csv   # optional overrides
```

**Backfill** existing rows missing coordinates (required for `/v1/facilities/nearby`):

```powershell
cd backend
npm run geocode:facilities -- --city Harare --limit 50   # smoke test
npm run geocode:facilities                              # full backfill (~45+ min first run)
npm run geocode:facilities -- --dry-run                 # preview counts only
npm run geocode:facilities -- --skip-remote             # cache + city-centre fallback only
npm run geocode:facilities -- --csv failures.csv        # write unresolved rows to CSV
```

| Flag | Purpose |
|------|---------|
| `--dry-run` | No database writes |
| `--skip-remote` | Skip Nominatim; use cache and city-centre fallback |
| `--reset` | Clear lat/lon/formatted_address before geocoding (default scope: HPA) |
| `--no-city-fallback` | Skip city-centre fallback on failed lookups (default when `--reset`) |
| `--allow-city-fallback` | Re-enable city-centre fallback during a reset run |
| `--clear-cache` | Truncate `geocode_cache` (use with `--reset` after address fixes) |
| `--import-source HPA` | Limit reset/geocode to one import source |
| `--limit N` | Process at most N facilities |
| `--city Harare` | Restrict to one city |
| `--csv path` | Export facilities that could not be geocoded |

**Province backfill** (`npm run fix:provinces`): resolves `facilities.province` from Nominatim per distinct city (~1 req/s). Use `--dry-run` first, `--limit N` to smoke-test, `--unresolved-csv` for cities Nominatim could not place.

**Other scripts:** `npm run audit:geocode` (coverage + duplicate coord report), `npm run geocode:import-csv -- --file coords.csv` (manual lat/lon).

**Import options:** pass `--skip-geocoding` to `npm run import:dual` to skip remote geocoding during HPA import.

Respect [Nominatim usage policy](https://operations.osmfoundation.org/policies/nominatim/): cache hits avoid repeat lookups; do not run multiple parallel backfills.

## Facility type classification

Home category tiles and search filters use `facilities.facility_type` (`hospital`, `clinic`, `pharmacy`, `laboratory`, `dental`, `optometry`, `imaging`, `other`). HPA import infers type from the facility name; practitioner import and the backfill CLI also use linked doctor specialties.

**Backfill** rows still marked `clinic` after import:

```powershell
cd backend
npm run classify:facilities -- --city Harare --dry-run   # preview changes
npm run classify:facilities -- --city Harare             # update Harare facilities
npm run classify:facilities -- --force                   # reclassify all types (not only clinic)
npm run classify:facilities -- --csv reclassified.csv    # audit export
```

| Flag | Purpose |
|------|---------|
| `--dry-run` | No database writes |
| `--city Harare` | Restrict to one city |
| `--limit N` | Process at most N facilities |
| `--force` | Update any row when inference differs (default: only `clinic` rows) |
| `--csv path` | Export id, name, from_type, to_type for changed rows |

Re-run after `npm run import:link` so specialty votes can refine generic surgery names. New HPA imports set `facility_type` on insert and upgrade `clinic` rows on re-import.

## Docker

```powershell
docker compose -f backend/docker-compose.yml up -d
```

## Flutter integration

```powershell
flutter run `
  --dart-define=API_BASE_URL=http://10.0.2.2:3000/v1 `
  --dart-define=SUPABASE_URL=http://127.0.0.1:54321 `
  --dart-define=SUPABASE_ANON_KEY=<anon-key>
```
