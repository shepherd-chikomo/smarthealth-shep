# SmartHealth Facility Portal

Next.js facility admin portal for healthcare tenants. Each facility admin is isolated to their assigned facility via membership checks and mandatory `facilityId` on every API call.

## Stack

- **Next.js 15** (App Router) + TypeScript
- **Supabase Auth** (OTP login, session cookies)
- **TanStack Query** (real-time polling on dashboard/queue)
- **Tailwind CSS 4** (dark mode default)
- **Fastify API** `/v1/facility/*` (tenant-scoped CRUD)

## Quick start

```powershell
# Terminal 1 — API
cd backend
npm install
npm run dev

# Terminal 2 — Facility portal
cd facility-portal
cp .env.local.example .env.local
npm install
npm run dev
```

Open http://localhost:3001

## Login

Staff roles with a `facility_memberships` row:

- `facility_admin`
- `doctor`
- `receptionist`

```sql
-- Promote user and assign to facility
UPDATE profiles SET primary_role = 'facility_admin' WHERE phone = '+263771234567';
INSERT INTO facility_memberships (facility_id, user_id, role)
SELECT f.id, p.id, 'facility_admin'
FROM facilities f, profiles p
WHERE f.slug = 'your-facility' AND p.phone = '+263771234567'
ON CONFLICT DO NOTHING;
```

Sign in with phone `0771234567` / OTP `123456` (local Supabase).

## Modules

| Route | Features |
|-------|----------|
| `/` | Analytics dashboard (30s refresh) |
| `/facility` | Facility profile CRUD |
| `/doctors` | Manage doctors (create, list, search) |
| `/hours` | Facility operating hours |
| `/availability` | Doctor working hours |
| `/slots` | Appointment slot settings |
| `/patients` | Register, search, view history |
| `/appointments` | List, filter, cancel |
| `/queue` | Walk-in queue, ticket numbers, status progression, wait estimates |
| `/emergency` | Emergency availability settings |
| `/billing` | **V1 placeholder** — summary counts only |
| `/inventory` | Products, stock alerts |
| `/staff` | Staff membership CRUD |
| `/analytics` | Trends and doctor performance |
| `/reports` | Revenue reports + CSV export |

## Tenant isolation

- Every API request requires `facilityId` (query param) and `X-Facility-Id` header
- Backend verifies `facility_memberships` before any operation
- Super admins bypass membership but still pass `facilityId` for scoping
- Supabase RLS provides a second layer when using direct Supabase client

## V1 scope notes

- **Billing**: Read-only summary dashboard; no invoicing, GL, or medical aid claim workflows
- **Availability edit UI**: View-only list; updates via API (`PUT /facility/availability/:providerId`)
- **Appointment scheduling form**: List + cancel; full schedule/reschedule forms can be added in V1.1

## API docs

Swagger: http://localhost:3000/docs — tag **Facility Portal**
