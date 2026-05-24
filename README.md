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
