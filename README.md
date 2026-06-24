# SmartHealth platform

Monorepo for **MyHealth** (patient), **MyPractice** (provider), facility & staff web portals, marketing sites, and the shared API/database stack for Zimbabwe and across Africa.

**Repository layout:** see [STRUCTURE.md](STRUCTURE.md).

## Products

| Product | Type | Location | Local dev |
|---------|------|----------|-----------|
| **MyHealth** | Flutter patient app | Repo root (`lib/`) | `flutter run` or `./scripts/run-patient-device.ps1` |
| **MyPractice** | Flutter provider app | `my_practice/` | `./scripts/run-mypractice-device.ps1` |
| **MyHealth marketing** | Next.js | `apps/myhealth-web/` | `cd apps/myhealth-web && npm run dev` → :3004 |
| **MyPractice marketing** | Next.js | `apps/mypractice-web/` | `cd apps/mypractice-web && npm run dev` → :3003 |
| **Facility portal** | Next.js | `apps/facility-portal/` | `cd apps/facility-portal && npm run dev` → :3001 |
| **Admin dashboard** | Vite + React | `apps/admin/` | `cd apps/admin && npm run dev` → :5173 |
| **REST API** | Fastify / Node | `backend/` | `cd backend && npm run dev` → :3000 |
| **Database** | PostgreSQL / Supabase | `supabase/` | `./scripts/supabase/start.ps1` |

Shared Flutter code: `packages/smarthealth_core/`.

## MyHealth patient app

Production-quality Flutter app — healthcare directory, emergency hub, booking, health vault.

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
flutter analyze
flutter run
```

### Patient app → main database (local API)

```powershell
docker compose up -d db smarthealth-migrate smarthealth-api
./scripts/run-patient-device.ps1
```

On a physical phone, use `./scripts/run-patient-device.ps1` (USB adb reverse) or `./scripts/run-patient-remote.ps1 -ServerUrl https://dev.smarthealth.co.zw`.

Catalog endpoints: `/v1/catalog/facility-types`, `/v1/catalog/specialties`, `/v1/catalog/conditions`, `/v1/catalog/age-groups`.

See `lib/` — `core/`, `features/`, `shared/`, `l10n/`.

## MyPractice provider app

See [my_practice/README.md](my_practice/README.md).

## Platform services

### Supabase / PostgreSQL

```powershell
./scripts/supabase/start.ps1 -Reset
./scripts/supabase/verify.ps1
```

See [supabase/README.md](supabase/README.md).

### REST API

```powershell
cd backend
npm install
cp .env.example .env
npm run dev
```

- API: http://localhost:3000/v1  
- Swagger: http://localhost:3000/docs  

See [backend/README.md](backend/README.md).

## Web apps

### Admin dashboard

```powershell
cd apps/admin
npm install
npm run dev
```

Open http://localhost:5173 — see [apps/admin/README.md](apps/admin/README.md).

### Facility portal

```powershell
cd apps/facility-portal
npm install
cp .env.local.example .env.local
npm run dev
```

Open http://localhost:3001 — see [apps/facility-portal/README.md](apps/facility-portal/README.md).

### Marketing sites

- **MyHealth:** [apps/myhealth-web/README.md](apps/myhealth-web/README.md) — https://myhealth.smarthealth.co.zw  
- **MyPractice:** [apps/mypractice-web/README.md](apps/mypractice-web/README.md) — https://mypractice.smarthealth.co.zw  

## Docker full stack

```bash
cp docker/.env.example .env
docker compose up -d
./docker/scripts/healthcheck.sh
```

## Notifications & analytics

- [docs/notifications/README.md](docs/notifications/README.md)  
- [docs/analytics/README.md](docs/analytics/README.md)  

## License

Private — SmartHealth.
