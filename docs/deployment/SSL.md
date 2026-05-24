# SSL / TLS Setup

SmartHealth terminates TLS at Nginx. All internal service communication uses the Docker bridge network (unencrypted).

## Option A: Let's Encrypt (recommended for production)

### Prerequisites

- Domain pointing to your server (A record)
- Port 80 open for ACME HTTP-01 challenge

### Using Certbot standalone

```bash
sudo apt install certbot
sudo certbot certonly --standalone \
  -d app.smarthealth.co.zw \
  --email ops@smarthealth.co.zw \
  --agree-tos --non-interactive

sudo cp /etc/letsencrypt/live/app.smarthealth.co.zw/fullchain.pem docker/nginx/ssl/
sudo cp /etc/letsencrypt/live/app.smarthealth.co.zw/privkey.pem docker/nginx/ssl/
sudo chown $USER:$USER docker/nginx/ssl/*.pem

docker compose restart nginx
```

### Auto-renewal

```bash
# /etc/cron.d/smarthealth-certbot
0 3 * * * root certbot renew --quiet --deploy-hook "cp /etc/letsencrypt/live/app.smarthealth.co.zw/*.pem /opt/smarthealth/docker/nginx/ssl/ && docker compose -f /opt/smarthealth/docker-compose.yml restart nginx"
```

## Option B: Self-signed (local / staging)

```bash
sh docker/scripts/generate-ssl.sh
docker compose restart nginx
```

Browsers will show a certificate warning — acceptable for staging.

## Option C: Cloud load balancer TLS

When using AWS ALB, Azure Application Gateway, or DigitalOcean Load Balancer:

1. Terminate TLS at the load balancer
2. Forward HTTP to Nginx on port 80 (internal)
3. Comment out the `listen 443 ssl` block in `docker/nginx/conf.d/smarthealth.conf`
4. Set `X-Forwarded-Proto` headers (already configured in Nginx)

## Option D: Caddy (alternative to Nginx)

For simpler automatic HTTPS, replace Nginx with Caddy:

```caddyfile
app.smarthealth.co.zw {
  reverse_proxy /v1/* smarthealth-api:3000
  reverse_proxy /admin/* smarthealth-admin:80
  reverse_proxy /* smarthealth-facility-portal:3001
}
```

See `docs/supabase/SELF_HOST_MIGRATION.md` for Caddy integration notes.

## Encryption in transit checklist

| Path | Encryption |
|------|------------|
| Client → Nginx | TLS 1.2+ (HTTPS) |
| Nginx → API | HTTP (internal Docker network) |
| API → PostgreSQL | Unencrypted (same host) — use SSL for managed DB |
| API → Supabase Kong | HTTP (internal) |
| Backups → S3 | HTTPS (TLS) |
| Supabase → external SMS/email | HTTPS |

For managed PostgreSQL (RDS, Azure Database), set `DATABASE_URL` with `?sslmode=require`.

## HSTS

HSTS is enabled in the Nginx TLS server block:

```
Strict-Transport-Security: max-age=31536000; includeSubDomains
```

Only enable after confirming HTTPS works correctly — HSTS is difficult to revert.
