# Deploying on DigitalOcean

DigitalOcean provides managed databases, object storage, and load balancers that simplify SmartHealth production operations.

## Recommended Setup

| Component | Service | Size |
|-----------|---------|------|
| App server | Droplet | 8 GB / 4 vCPU ($48/mo) |
| Database | Managed PostgreSQL | 2 GB RAM ($30/mo) |
| Backups | Spaces (S3-compatible) | 250 GB ($5/mo) |
| Load balancer | DO Load Balancer | ($12/mo) — optional |

**Region:** `ams3` (Amsterdam) or `lon1` (London) for Africa latency.

## Droplet Setup

```bash
# Create droplet with Docker marketplace image, or:
doctl compute droplet create smarthealth-prod \
  --size s-4vcpu-8gb \
  --image ubuntu-24-04-x64 \
  --region ams3

ssh root@DROPLET_IP

curl -fsSL https://get.docker.com | sh
git clone https://github.com/your-org/smarthealth-shep.git /opt/smarthealth
cd /opt/smarthealth
cp docker/.env.example .env
```

## Managed PostgreSQL

When using DO Managed Database instead of containerized Postgres:

```env
# Comment out or don't start the db service
DATABASE_URL=postgresql://doadmin:PASSWORD@db-postgresql-ams3-do-user-xxx.db.ondigitalocean.com:25060/defaultdb?sslmode=require
POSTGRES_HOST=db-postgresql-ams3-do-user-xxx.db.ondigitalocean.com
POSTGRES_PORT=25060
```

Update `docker-compose.yml` to exclude `db` service or use profile:

```bash
docker compose up -d --scale db=0 smarthealth-api nginx ...
docker compose run --rm smarthealth-migrate  # uses DATABASE_URL from .env
```

## Spaces (S3 backups)

```env
S3_ENDPOINT=https://ams3.digitaloceanspaces.com
S3_REGION=ams3
S3_BUCKET=smarthealth-backups
S3_ACCESS_KEY=DO00...
S3_SECRET_KEY=...
```

## Load Balancer + TLS

1. Create DO Load Balancer pointing to Droplet
2. Enable SSL (Let's Encrypt managed by DO)
3. Forward ports 80/443 to Droplet
4. Disable Nginx TLS block — LB handles HTTPS

## Deploy via GitHub Actions

```
DEPLOY_HOST=DROPLET_IP
DEPLOY_USER=root
DEPLOY_SSH_KEY=<key>
```

Trigger deploy workflow with target `digitalocean`.
