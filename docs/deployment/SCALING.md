# Scaling Strategy

SmartHealth is designed to scale horizontally at the application layer while keeping PostgreSQL as the primary bottleneck to plan for.

## Current Architecture (single node)

All services run on one Docker host via `docker-compose.yml`. Suitable for:

- Up to ~500 concurrent users
- Single-facility or small multi-facility deployments
- MVP and staging environments

## Scaling Tiers

### Tier 1 — Vertical scaling (easiest)

Increase VPS resources without architecture changes:

| Workload | vCPU | RAM | Disk |
|----------|------|-----|------|
| Dev/staging | 4 | 8 GB | 80 GB |
| Small prod (< 50 facilities) | 8 | 16 GB | 256 GB |
| Medium prod (< 200 facilities) | 16 | 32 GB | 512 GB |

```bash
# After resizing VPS
docker compose up -d --force-recreate
```

### Tier 2 — Service separation

Move components to dedicated nodes:

```
Node 1: Nginx + API (2–3 replicas) + Admin + Portal
Node 2: PostgreSQL (primary)
Node 3: Supabase services + Redis
Node 4: Monitoring + Backups
```

Use Docker Swarm or manual compose files per node with shared network via VPN (WireGuard/Tailscale).

### Tier 3 — Horizontal API scaling

Run multiple API containers behind Nginx upstream:

```nginx
upstream smarthealth_api {
  least_conn;
  server api-1:3000;
  server api-2:3000;
  server api-3:3000;
}
```

Requirements:

- **Redis** for distributed rate limiting (replace in-memory `@fastify/rate-limit` store)
- **Sticky sessions not required** — JWT is stateless
- **Workers**: run notification/analytics/retention workers on a single dedicated API instance or extract to separate worker containers

```yaml
# docker-compose.override.yml
services:
  smarthealth-api:
    deploy:
      replicas: 3
```

### Tier 4 — Database scaling

| Strategy | When | Tooling |
|----------|------|---------|
| Connection pooling | > 100 concurrent API connections | Supavisor (included in Supabase stack) or PgBouncer |
| Read replicas | Heavy reporting queries | PostgreSQL streaming replication |
| Managed database | Production at scale | AWS RDS, Azure Database, DigitalOcean Managed DB |

Point `DATABASE_URL` at PgBouncer/Supavisor:

```
postgresql://postgres:pass@supavisor:6543/postgres
```

### Tier 5 — Multi-region (future)

For Zimbabwe + regional expansion:

- Primary region: `af-south-1` (Cape Town) — lowest latency to Harare
- CDN for static assets (admin, portal `_next/static`)
- Read replica in secondary region for analytics
- S3 cross-region replication for backups

## Redis usage roadmap

Redis is included in the stack but not yet required by the API. Planned uses:

| Feature | Priority |
|---------|----------|
| Distributed rate limiting | High |
| Session cache | Medium |
| Notification job queue | Medium |
| Real-time pub/sub | Low |

Set `REDIS_URL=redis://:password@redis:6379` in API environment when implemented.

## Monitoring-driven scaling

Set Grafana alerts (included datasource) for:

- API p95 latency > 500ms
- PostgreSQL connections > 80% of max
- Disk usage > 80%
- Error rate > 1% (via Sentry + Prometheus)

Scale up when alerts fire consistently for > 15 minutes.

## Load testing

```bash
# Install k6
brew install k6  # or apt install k6

# Smoke test
k6 run - <<'EOF'
import http from 'k6/http';
export default function () {
  http.get('http://localhost/health');
}
EOF
```

Target: 100 RPS on `/health` with p95 < 100ms before scaling.

## Cost optimization

- Use Hetzner CPX41 (~€19/mo) for small production
- DigitalOcean droplet + managed DB for hands-off Postgres
- Reserve instances on AWS/Azure for 1-year commitments at scale
