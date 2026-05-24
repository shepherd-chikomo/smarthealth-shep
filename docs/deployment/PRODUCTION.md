# SmartHealth Production Deployment Guide

This guide covers deploying the full SmartHealth stack on your own infrastructure — suitable for Zimbabwe data residency, air-gapped environments, and cost-controlled VPS hosting.

## Architecture Overview

```
                    ┌─────────────────────────────────────────┐
                    │           Nginx (TLS termination)        │
                    │  :443 / :80                              │
                    └──────┬──────────┬──────────┬─────────────┘
                           │          │          │
              ┌────────────▼──┐  ┌────▼────┐  ┌──▼──────────────┐
              │  Facility      │  │  Admin  │  │  SmartHealth API │
              │  Portal :3001  │  │  :80    │  │  :3000           │
              └────────────────┘  └─────────┘  └────────┬─────────┘
                                                           │
         ┌─────────────────────────────────────────────────┤
         │                                                 │
  ┌──────▼──────┐  ┌─────────┐  ┌──────────┐  ┌─────────▼────────┐
  │  Supabase   │  │  Redis  │  │ Postgres │  │  Prometheus /    │
  │  Kong :8000 │  │  :6379  │  │  :5432   │  │  Grafana / Kuma  │
  └─────────────┘  └─────────┘  └──────────┘  └──────────────────┘
```

## Prerequisites

| Requirement | Minimum | Recommended |
|-------------|---------|-------------|
| CPU | 4 vCPU | 8 vCPU |
| RAM | 8 GB | 16 GB |
| Disk | 80 GB SSD | 256 GB SSD |
| OS | Ubuntu 22.04 LTS | Ubuntu 24.04 LTS |
| Docker | 24+ | Latest stable |
| Docker Compose | v2.20+ | Latest |

## Quick Start (Local / Staging)

```bash
git clone https://github.com/your-org/smarthealth-shep.git
cd smarthealth-shep

cp docker/.env.example .env
# Edit .env — set POSTGRES_PASSWORD, JWT_SECRET, ANON_KEY, SERVICE_ROLE_KEY

sh docker/scripts/bootstrap.sh
# Or manually:
sh docker/scripts/generate-ssl.sh
docker compose up -d
sh docker/scripts/healthcheck.sh
```

### Service URLs (local)

| Service | URL |
|---------|-----|
| Facility Portal | http://localhost/ |
| Admin Dashboard | http://localhost/admin/ |
| REST API | http://localhost/v1/ |
| API Docs | http://localhost/docs |
| Supabase Kong | http://localhost:8000 |
| Supabase Studio | http://localhost:54323 |
| Grafana | http://localhost:3002 (monitoring profile) |
| Uptime Kuma | http://localhost:3003 (monitoring profile) |
| Prometheus | http://localhost:9090 (monitoring profile) |

## Production Deployment Steps

### 1. Provision server

See provider-specific guides:

- [Hetzner](HETZNER.md)
- [DigitalOcean](DIGITALOCEAN.md)
- [AWS](AWS.md)
- [Azure](AZURE.md)
- [Ubuntu VPS](UBUNTU_VPS.md)

### 2. Install Docker

```bash
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER
```

### 3. Configure secrets

```bash
cp docker/.env.example .env
```

**Generate production secrets:**

```bash
# Postgres password
openssl rand -base64 32

# JWT secret (min 32 chars)
openssl rand -base64 48

# API secrets
openssl rand -hex 32  # PAYMENTS_WEBHOOK_SECRET
openssl rand -hex 32  # NOTIFICATION_DISPATCH_SECRET
openssl rand -hex 32  # FIELD_ENCRYPTION_KEY
```

**Generate Supabase JWT keys** using the [Supabase JWT generator](https://supabase.com/docs/guides/self-hosting/docker#generate-api-keys) with your `JWT_SECRET`.

Set in `.env`:

```env
ENVIRONMENT=production
PUBLIC_URL=https://app.smarthealth.co.zw
SITE_URL=https://app.smarthealth.co.zw
SUPABASE_PUBLIC_URL=https://app.smarthealth.co.zw
NEXT_PUBLIC_SUPABASE_URL=https://app.smarthealth.co.zw
DOMAIN=app.smarthealth.co.zw
SSL_MODE=letsencrypt
```

### 4. TLS / SSL

See [SSL.md](SSL.md) for Let's Encrypt, self-signed, and cloud load balancer options.

```bash
# Bootstrap with Let's Encrypt (production)
certbot certonly --webroot -w /var/www/certbot \
  -d app.smarthealth.co.zw \
  --email ops@smarthealth.co.zw --agree-tos

cp /etc/letsencrypt/live/app.smarthealth.co.zw/fullchain.pem docker/nginx/ssl/
cp /etc/letsencrypt/live/app.smarthealth.co.zw/privkey.pem docker/nginx/ssl/
```

### 5. Start the stack

```bash
docker compose pull
docker compose up -d db redis kong auth rest storage meta
docker compose run --rm smarthealth-migrate
docker compose up -d --build
docker compose --profile monitoring up -d
docker compose --profile backup up -d
sh docker/scripts/healthcheck.sh
```

### 6. Seed data (optional)

```bash
docker compose exec -T db psql -U postgres -d postgres < supabase/seed.sql
```

### 7. Configure monitoring

1. Open Grafana at `:3002` — default credentials from `.env`
2. Open Uptime Kuma at `:3003` — add monitors for:
   - `https://app.smarthealth.co.zw/health`
   - `https://app.smarthealth.co.zw/v1/providers`
3. Set `SENTRY_DSN` in `.env` for error tracking

## CI/CD

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| `.github/workflows/ci.yml` | Push/PR to main | Lint, test, build, Docker smoke |
| `.github/workflows/deploy.yml` | Tag `v*.*.*` or manual | Build/push GHCR images, deploy |
| `.github/workflows/security.yml` | Push to backend | Security tests, OWASP checks |

### Release process

```bash
git tag v1.2.0
git push origin v1.2.0
# GitHub Actions builds and pushes images to ghcr.io
# Trigger deploy workflow with target environment
```

## Backups

See [DISASTER_RECOVERY.md](DISASTER_RECOVERY.md).

```bash
# Manual backup
docker compose --profile backup run --rm smarthealth-backup /backup.sh

# Enable scheduled backups (daily 02:00 UTC)
docker compose --profile backup up -d smarthealth-backup
```

Configure S3 in `.env` for off-site backup replication.

## Scaling

See [SCALING.md](SCALING.md).

## Troubleshooting

```bash
# View logs
docker compose logs -f smarthealth-api
docker compose logs -f kong auth db

# Restart a service
docker compose restart smarthealth-api

# Re-run migrations
docker compose run --rm smarthealth-migrate

# Full reset (destructive)
docker compose down -v
```

## Security Checklist

- [ ] Change all default passwords in `.env`
- [ ] Restrict ports 9090, 54323, 3002, 3003 to admin VPN/IP
- [ ] Enable firewall (UFW): allow 80, 443 only publicly
- [ ] Configure S3 backup encryption
- [ ] Set up Sentry alerting
- [ ] Enable Uptime Kuma notifications (Slack/email)
- [ ] Review RLS policies: `docs/supabase/RLS.md`
