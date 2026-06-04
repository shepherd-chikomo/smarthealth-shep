# SmartHealth Patient App

Production-quality Flutter patient app for Zimbabwe and across Africa — healthcare directory, emergency hub, and future booking, payments, and tele-consult.

## Stack

- Flutter 3.22+ / Dart 3.4+
- Material 3, Riverpod, go_router
- Offline-first (Hive + Dio cache)
- Localisation: English, Shona, Ndebele, French, Portuguese, Swahili

## Setup

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
flutter analyze
flutter run
```

### Patient app → main database (local API)

By default the app talks to `http://localhost:3000/v1` and does **not** seed mock providers
(`USE_MAIN_DATABASE=true`). Start the Docker API first:

```powershell
docker compose up -d db smarthealth-migrate smarthealth-api
```

On a **physical phone**, `localhost` is the phone itself — use your PC's LAN IP:

```powershell
./scripts/run-patient-device.ps1 -DeviceId <your-device-id>
```

Or pass defines manually:

```powershell
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:3000/v1 --dart-define=USE_MAIN_DATABASE=true
```

For offline demos only: `--dart-define=USE_MAIN_DATABASE=false --dart-define=ALLOW_MOCK_DATA=true`

Catalog endpoints used by home tiles and search filters: `/v1/catalog/facility-types`, `/v1/catalog/specialties`, `/v1/catalog/conditions`, `/v1/catalog/age-groups`.

## Android release (low-end devices)

```bash
flutter build apk --release --split-per-abi
```

- `minSdk` 26, `targetSdk` 34, MultiDex, R8 minify enabled in release.

## Project layout

See `lib/` — `core/`, `features/`, `shared/`, `l10n/`.

## Supabase backend

PostgreSQL backend with multi-tenant healthcare schema, auth, storage, RLS, and audit logging.

```powershell
# Prerequisites: Docker Desktop + Supabase CLI
./scripts/supabase/start.ps1 -Reset
./scripts/supabase/verify.ps1
```

See [supabase/README.md](supabase/README.md) for full setup, environments, and self-host migration.

## REST API

Node.js/Fastify REST layer over Supabase — JWT auth, OpenAPI docs, pagination, search, and rate limiting.

```powershell
cd backend
npm install
cp .env.example .env   # keys from `supabase status`
npm run dev
```

- API: http://localhost:3000/v1
- Swagger: http://localhost:3000/docs

See [backend/README.md](backend/README.md) for endpoints and integration.

## Admin Dashboard

Staff web portal — queue management, providers, appointments, reporting, security.

```powershell
cd admin
npm install
npm run dev
```

Open http://localhost:5173 — see [admin/README.md](admin/README.md).

## Facility Portal

Next.js tenant-scoped portal for facility admins — doctors, patients, queue, inventory, reporting.

```powershell
cd facility-portal
npm install
cp .env.local.example .env.local
npm run dev
```

Open http://localhost:3001 — see [facility-portal/README.md](facility-portal/README.md).

## Notifications

FCM push + Supabase triggers + SMS/email fallbacks. See [docs/notifications/README.md](docs/notifications/README.md).

## Analytics

Materialized views, aggregation tables, hourly refresh worker. See [docs/analytics/README.md](docs/analytics/README.md).

## License

Private — SmartHealth.
