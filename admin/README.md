# SmartHealth Admin Dashboard

Staff web portal for platform and facility administration.

## Stack

- React 19 + Vite + TypeScript
- Tailwind CSS 4 (dark mode default)
- TanStack Query (real-time polling)
- React Router 7

## Quick start

```powershell
# Terminal 1 — API
cd backend
npm install
npm run dev

# Terminal 2 — Admin UI
cd admin
npm install
npm run dev
```

Open http://localhost:5173

## Login

Uses the same Supabase JWT auth as the patient API. Staff roles required:

- `super_admin`
- `facility_admin`
- `doctor`
- `receptionist`

Sign in with **email OTP** (phone SMS fallback when a number is on the profile).

Local dev:

1. Promote a user: run `scripts/setup-dev-admin.ps1`, or use **User Management** in the admin portal
2. Sign in with email `dev-admin@smarthealth.co.zw` (OTP in Inbucket at http://127.0.0.1:54324, or Gmail SMTP if configured)
3. Phone fallback: `0771234567` / OTP `123456` (test OTP in Docker GoTrue)

Ensure promoted staff have an email set on their profile before signing in.

## Modules

| Route | Features |
|-------|----------|
| `/` | Real-time dashboard stats |
| `/users` | Platform administrator management (super admin) |
| `/facility-admins` | CRUD facility administrators (super admin) |
| `/queue` | Live queues, wait times, abuse moderation |
| `/providers` | Verify, suspend, ratings |
| `/appointments` | List, filter, booking analytics |
| `/hours` | Operating hours |
| `/content` | Emergency, specialties, notifications |
| `/settings` | Feature flags, config, pricing, templates |
| `/reports` | Revenue reports, CSV/PDF export |
| `/security` | Audit logs, suspicious activity |

## API

All endpoints under `/v1/admin/*` with JWT + RBAC. See backend Swagger at http://localhost:3000/docs
