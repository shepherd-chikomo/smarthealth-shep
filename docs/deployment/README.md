# SmartHealth Deployment Documentation

Complete DevOps and deployment guides for self-hosted SmartHealth.

## Guides

| Document | Description |
|----------|-------------|
| [PRODUCTION.md](PRODUCTION.md) | Production deployment guide |
| [SSL.md](SSL.md) | TLS/SSL setup (Let's Encrypt, self-signed, cloud LB) |
| [SCALING.md](SCALING.md) | Horizontal/vertical scaling strategy |
| [DISASTER_RECOVERY.md](DISASTER_RECOVERY.md) | Backups, restore, DR procedures |
| [UBUNTU_VPS.md](UBUNTU_VPS.md) | Generic Ubuntu VPS deployment |
| [HETZNER.md](HETZNER.md) | Hetzner Cloud |
| [DIGITALOCEAN.md](DIGITALOCEAN.md) | DigitalOcean Droplets + managed DB |
| [AWS.md](AWS.md) | AWS EC2 / ECS |
| [AZURE.md](AZURE.md) | Azure VM / Container Apps |

## Quick Start

```bash
cp docker/.env.example .env
make bootstrap
make health
```

## Stack Components

| Service | Container | Port |
|---------|-----------|------|
| Nginx | smarthealth-nginx | 80, 443 |
| API | smarthealth-api | 3000 |
| Admin | smarthealth-admin | 80 (internal) |
| Facility Portal | smarthealth-facility-portal | 3001 (internal) |
| PostgreSQL | smarthealth-db | 5432 (internal) |
| Supabase Kong | smarthealth-kong | 8000 |
| Supabase Auth | smarthealth-auth | 9999 (internal) |
| Redis | smarthealth-redis | 6379 (internal) |
| Grafana | smarthealth-grafana | 3002 |
| Prometheus | smarthealth-prometheus | 9090 |
| Uptime Kuma | smarthealth-uptime-kuma | 3003 |

## CI/CD Workflows

- `.github/workflows/ci.yml` — lint, test, Docker build, smoke test
- `.github/workflows/deploy.yml` — build/push images, deploy to target
- `.github/workflows/security.yml` — security tests, OWASP checks

## Related

- [Self-Host Migration](../supabase/SELF_HOST_MIGRATION.md)
- [Backup Strategy](../supabase/BACKUP.md)
