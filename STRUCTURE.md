# SmartHealth monorepo structure

This repository is a **product-oriented monorepo**: mobile apps, web apps, shared packages, and platform services live in predictable places.

## Layout

```text
smarthealth-shep/
├── apps/                         # Deployable products (web + future mobile homes)
│   ├── myhealth-web/             # Patient marketing site
│   ├── mypractice-web/           # Practitioner marketing site
│   ├── facility-portal/          # Facility admin portal
│   └── admin/                    # Staff admin dashboard
├── packages/
│   └── smarthealth_core/         # Shared Flutter library
├── backend/                      # Fastify REST API (→ platform/backend in Phase 4)
├── supabase/                     # Migrations, RLS, edge functions (→ platform/ in Phase 4)
├── docker/                       # Compose helpers, nginx, SSL scripts
├── docs/                         # Cross-cutting documentation
├── scripts/
│   ├── myhealth/                 # Patient app run/deploy helpers
│   ├── mypractice/               # MyPractice app run/deploy helpers
│   ├── platform/                 # API, geocode, compose debug, UAT
│   └── supabase/                 # Local Supabase lifecycle
├── lib/                          # MyHealth Flutter app (→ apps/myhealth in Phase 3)
├── my_practice/                  # MyPractice Flutter app (→ apps/mypractice in Phase 3)
└── README.md                     # Platform index
```

## Where new code goes

| You are building… | Location |
|-------------------|----------|
| Patient mobile UI / health vault | `lib/features/` (until Phase 3: `apps/myhealth/`) |
| Provider mobile / clinical workstation | `my_practice/lib/features/` (until Phase 3) |
| Shared auth, network, theme (Flutter) | `packages/smarthealth_core/` |
| REST API routes & services | `backend/src/` |
| Database schema, RLS, triggers | `supabase/migrations/` |
| Public marketing / SEO pages | `apps/myhealth-web/` or `apps/mypractice-web/` |
| Facility tenant staff UI | `apps/facility-portal/` |
| Internal staff / queue / reporting | `apps/admin/` |
| Nginx, SSL, healthcheck | `docker/` |

## Naming

| Product | Folder | Docker service |
|---------|--------|----------------|
| MyHealth (patient) | `apps/myhealth-web`, Flutter at repo root (Phase 3) | `smarthealth-myhealth-web` |
| MyPractice (provider) | `apps/mypractice-web`, `my_practice/` (Phase 3) | `smarthealth-mypractice-web` |
| Facility portal | `apps/facility-portal` | `smarthealth-facility-portal` |
| Admin | `apps/admin` | `smarthealth-admin` |
| API | `backend/` | `smarthealth-api` |

Use **`myhealth`** and **`mypractice`** (no `my_practice` in new paths).

## Migration phases

| Phase | Status | Scope |
|-------|--------|-------|
| **1** | Done | Docs, cursor rules, `scripts/` layout |
| **2** | Done | Web apps under `apps/` |
| **3** | Pending | Move Flutter apps to `apps/myhealth`, `apps/mypractice`; add Melos |
| **4** | Pending | Move `backend/` + `supabase/` under `platform/` |

See [.cursor/rules/repo-structure.mdc](.cursor/rules/repo-structure.mdc) for agent reminders and per-phase test checklists.

## Quick start

| Product | Command |
|---------|---------|
| MyHealth app | `flutter run` (repo root) or `./scripts/run-patient-device.ps1` |
| MyPractice app | `./scripts/run-mypractice-device.ps1` |
| API | `cd backend && npm run dev` |
| MyHealth marketing | `cd apps/myhealth-web && npm run dev` |
| MyPractice marketing | `cd apps/mypractice-web && npm run dev` |
| Facility portal | `cd apps/facility-portal && npm run dev` |
| Admin | `cd apps/admin && npm run dev` |
| Full stack | `docker compose up -d` |
