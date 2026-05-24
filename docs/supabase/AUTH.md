# SmartHealth Auth Configuration

Authentication is powered by Supabase Auth with SmartHealth-specific RBAC via PostgreSQL RLS and JWT custom claims.

## Supported Methods

| Method | Local | Staging | Production |
|--------|-------|---------|------------|
| Email OTP (primary for staff) | Inbucket / Gmail SMTP | Gmail SMTP | Gmail SMTP |
| Phone OTP (+263) | Test OTP | Twilio | Twilio / Africa's Talking |
| Email + password | Legacy | SMTP | SMTP |
| Magic link | Yes | Yes | Yes |
| OAuth (Google/Apple) | Disabled | Optional | Optional |

## Email-primary OTP (staff portals)

Admin and facility portals sign in with **email OTP first**. Phone SMS is a fallback only when the staff profile has a registered `profiles.phone`.

| Client | API `context` | Default channel | Phone fallback |
|--------|---------------|-----------------|----------------|
| Admin portal | `staff` | email | `{ context: 'staff', email, channel: 'phone' }` |
| Facility portal | `staff` | email | Same as admin |
| Mobile app | `mobile` | User picks email or phone | Always allowed |
| Account recovery | `recovery` | email | Same rules as staff |

### API

```http
POST /v1/auth/otp/send
{ "context": "staff", "email": "admin@example.com" }

POST /v1/auth/otp/verify
{ "context": "staff", "email": "admin@example.com", "otp": "123456", "channel": "email" }
```

Send response: `{ "message", "channel": "email"|"sms", "destination": "a***@example.com" }`

Mobile app example:

```http
POST /v1/auth/otp/send
{ "context": "mobile", "channel": "phone", "phone": "0771234567" }
```

### Self-hosted GoTrue SMTP (Docker)

Set in root `.env` (never commit secrets):

```
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=noreply@smarthealth.co.zw
SMTP_PASS=<app-password>
SMTP_SENDER_NAME=SmartHealth
```

Restart auth after changes: `docker compose up -d --force-recreate auth`

`GOTRUE_MAILER_AUTOCONFIRM` must be `false` in production so email OTP is enforced.

Staff users must have a unique email in `profiles` (see migration `20260524130000_email_auth_indexes.sql`).

## Configuration Files

- `supabase/config.toml` — local auth settings
- `supabase/migrations/20260523100300_auth_and_rbac.sql` — hooks and RBAC
- `supabase/env/.env.*.example` — environment-specific secrets

## Email Auth

### Local development

Emails are captured by Inbucket at http://127.0.0.1:54324 — no SMTP needed.

### Production SMTP

Set in Supabase Dashboard → Project Settings → Auth → SMTP:

```
Host: smtp.sendgrid.net (or your provider)
Port: 587
User: apikey
Password: <sendgrid-api-key>
Sender: noreply@smarthealth.co.zw
```

## Phone OTP (Zimbabwe)

### Phone normalization

All phone numbers are normalized to E.164 format: `+263XXXXXXXXX`

Accepted input formats:

- `0771234567` → `+263771234567`
- `263771234567` → `+263771234567`
- `+263771234567` → unchanged

### Local test numbers

Configured in `config.toml`:

```toml
[auth.sms.test_otp]
"263771234567" = "123456"
"263771111111" = "654321"
```

### Production SMS

**Twilio** (recommended for international):

1. Create Twilio account with Zimbabwe-capable sender
2. Configure in Supabase Dashboard → Auth → Phone
3. Set `AUTH_SMS_PROVIDER=twilio` in environment

**Africa's Talking** (regional alternative):

- Better rates for African carriers
- Configure via custom SMS hook if needed

## JWT Sessions

| Setting | Value | Config key |
|---------|-------|------------|
| Access token expiry | 1 hour | `auth.jwt_expiry = 3600` |
| Refresh token rotation | Enabled | `auth.enable_refresh_token_rotation = true` |
| Reuse interval | 10 seconds | `auth.refresh_token_reuse_interval = 10` |
| Session timebox | 24 hours | `auth.sessions.timebox = "24h"` |
| Inactivity timeout | 8 hours | `auth.sessions.inactivity_timeout = "8h"` |

### Custom JWT claims

The `custom_access_token_hook` adds:

```json
{
  "user_role": "patient",
  "facility_ids": ["uuid-1", "uuid-2"],
  "app": "smarthealth"
}
```

## Refresh Token Handling

Supabase client handles refresh automatically. For server-side revocation tracking:

```sql
select private.register_refresh_token(
  p_user_id := 'user-uuid',
  p_token_hash := 'sha256-hash',
  p_expires_at := now() + interval '7 days'
);

select private.revoke_refresh_token('sha256-hash');
select private.revoke_all_user_tokens('user-uuid');
```

## Role-Based Access Control

| Role | How assigned |
|------|--------------|
| `patient` | Default on signup |
| `facility_admin`, `doctor`, `receptionist` | Insert into `facility_memberships` |
| `super_admin` | Manual update to `profiles.primary_role` (service role) |

## Security Checklist

- Disable signup in production if invite-only
- Enable email confirmation for production
- Configure rate limiting on auth endpoints
- Use strong JWT_SECRET (32+ characters)
- Never expose SUPABASE_SERVICE_ROLE_KEY in client apps
- Enable MFA for admin accounts when ready
- Audit log review for auth-related tables
