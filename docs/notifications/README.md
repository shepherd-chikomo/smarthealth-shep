# SmartHealth Notification System

Multi-channel notifications with Firebase Cloud Messaging, Supabase database triggers, SMS/email fallbacks, and deep linking.

## Architecture

```
┌─────────────────┐     triggers      ┌──────────────────┐
│  Supabase DB    │ ────────────────► │  notifications   │
│  (appointments) │   enqueue_notification()              │
└─────────────────┘                   └────────┬─────────┘
                                               │ pg_notify
                                               ▼
┌─────────────────┐   poll / webhook  ┌──────────────────┐
│  Edge Function  │ ────────────────► │  Backend API     │
│  notification-  │                   │  dispatch worker │
│  dispatch       │                   └────────┬─────────┘
└─────────────────┘                            │
                    ┌──────────────────────────┼──────────────────────────┐
                    ▼                          ▼                          ▼
                 FCM push                   Twilio SMS                  Resend email
                    │                          │                          │
                    └──────────────────────────┴──────────────────────────┘
                                               ▼
                                    Flutter app (in-app inbox + deep links)
```

## Notification types

| Category | Trigger | Deep link |
|----------|---------|-----------|
| `appointment_reminder` | Appointment INSERT (24h + 2h before) | `/bookings` |
| `appointment_cancellation` | Appointment status → cancelled | `/bookings` |
| `emergency_alert` | `activity_logs.action = emergency_alert` | `/emergency` |
| `provider_message` | API `sendProviderMessage()` | `/provider/:id` |
| `facility_announcement` | Facility portal POST `/facility/announcements` | `/home` |

## Delivery order

1. **In-app** — row in `notifications` table (Realtime-enabled)
2. **Push (FCM)** — if preference enabled and token registered
3. **SMS fallback** — Twilio if push fails/unavailable
4. **Email fallback** — Resend if SMS also fails

## API endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/v1/notifications` | List in-app notifications |
| GET | `/v1/notifications/unread-count` | Badge count |
| PATCH | `/v1/notifications/:id/read` | Mark read |
| PATCH | `/v1/notifications/read-all` | Mark all read |
| POST | `/v1/notifications/push-token` | Register FCM token |
| DELETE | `/v1/notifications/push-token` | Deactivate token |
| GET/PUT | `/v1/notifications/preferences` | User preferences |
| POST | `/v1/notifications/dispatch` | Internal dispatch (secret) |

## Configuration

### Backend (`.env`)

```env
NOTIFICATION_DISPATCH_SECRET=dev-notification-dispatch-secret
NOTIFICATION_WORKER_INTERVAL_MS=30000
FIREBASE_PROJECT_ID=
FIREBASE_CLIENT_EMAIL=
FIREBASE_PRIVATE_KEY=
TWILIO_ACCOUNT_SID=
TWILIO_AUTH_TOKEN=
TWILIO_FROM_NUMBER=
RESEND_API_KEY=
EMAIL_FROM=SmartHealth <notifications@smarthealth.co.zw>
```

In development, missing providers log to console and mark notifications as sent.

### Flutter

```bash
flutterfire configure
# Or pass dart-defines:
flutter run \
  --dart-define=FIREBASE_API_KEY=... \
  --dart-define=FIREBASE_APP_ID=... \
  --dart-define=FIREBASE_PROJECT_ID=... \
  --dart-define=FIREBASE_MESSAGING_SENDER_ID=...
```

### Supabase edge function

Deploy `supabase/functions/notification-dispatch` and configure a Database Webhook on `notifications` INSERT, or rely on the backend worker polling every 30s.

## Scheduled notifications

Set `scheduled_at` when enqueueing. The backend worker only dispatches when `scheduled_at <= now()`. Appointment reminders use 24h and 2h offsets automatically.

## Deep linking

FCM data payload includes `actionUrl`. Flutter `DeepLinkHandler` maps to GoRouter paths. Android supports `smarthealth://` scheme.

## Files

- `supabase/migrations/20260523120300_notification_system.sql`
- `supabase/functions/notification-dispatch/index.ts`
- `backend/src/services/notification-dispatch.service.ts`
- `backend/src/workers/notification-worker.ts`
- `lib/features/notifications/` — Flutter client
