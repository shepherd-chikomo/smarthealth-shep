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
