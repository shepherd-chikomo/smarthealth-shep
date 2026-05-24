# Deploying on AWS

AWS deployment options for SmartHealth range from a single EC2 instance to ECS Fargate with RDS.

## Option A: EC2 + Docker Compose (simplest)

Same as [Ubuntu VPS](UBUNTU_VPS.md) on an EC2 instance.

| Environment | Instance | Specs |
|-------------|----------|-------|
| Staging | t3.large | 2 vCPU, 8 GB |
| Production | t3.xlarge | 4 vCPU, 16 GB |

**Region:** `af-south-1` (Cape Town) — lowest latency to Zimbabwe.

```bash
# Launch EC2 with Ubuntu 24.04, attach security group:
# Inbound: 22 (your IP), 80, 443

ssh ubuntu@EC2_IP
sudo apt update && sudo apt install -y docker.io docker-compose-v2 git
sudo usermod -aG docker ubuntu

git clone https://github.com/your-org/smarthealth-shep.git /opt/smarthealth
cd /opt/smarthealth
cp docker/.env.example .env
# Configure secrets

sh docker/scripts/bootstrap.sh
```

## Option B: ECS Fargate (scalable)

Push images to ECR via GitHub Actions deploy workflow, then:

1. **ECR repositories:** `smarthealth-api`, `smarthealth-admin`, `smarthealth-facility-portal`
2. **RDS PostgreSQL:** `db.t3.medium` in `af-south-1`
3. **ElastiCache Redis:** `cache.t3.micro`
4. **ECS services:** one per app component
5. **ALB:** TLS termination, route `/v1` → API, `/admin` → admin, `/` → portal
6. **S3:** backups + Supabase storage (`STORAGE_BACKEND=s3`)

### Environment variables (ECS task definition)

```json
{
  "DATABASE_URL": "postgresql://...@smarthealth.xxxx.af-south-1.rds.amazonaws.com:5432/postgres?sslmode=require",
  "REDIS_URL": "redis://smarthealth.xxxx.cache.amazonaws.com:6379",
  "SUPABASE_URL": "https://your-supabase-domain",
  "SENTRY_DSN": "https://...@sentry.io/..."
}
```

## S3 Backups

```env
S3_ENDPOINT=https://s3.af-south-1.amazonaws.com
S3_REGION=af-south-1
S3_BUCKET=smarthealth-backups-prod
```

Enable bucket versioning and lifecycle rules (90-day expiry).

## CloudWatch

Forward Docker logs to CloudWatch:

```bash
# Install CloudWatch agent on EC2
sudo apt install amazon-cloudwatch-agent
```

Or use Grafana Cloud as alternative to self-hosted Grafana.

## CI/CD

Configure GitHub secrets:

```
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
AWS_REGION=af-south-1
ECS_CLUSTER=smarthealth-prod
```

Extend `.github/workflows/deploy.yml` AWS step with `aws ecs update-service`.

## Cost estimate (af-south-1)

| Service | Monthly (~) |
|---------|-------------|
| EC2 t3.xlarge | $130 |
| RDS db.t3.medium | $70 |
| S3 + backups | $10 |
| ALB | $25 |
| **Total** | **~$235** |

Single EC2 approach: ~$130/mo.
