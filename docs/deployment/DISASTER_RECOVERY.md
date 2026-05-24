# Disaster Recovery

SmartHealth backup and recovery procedures for PostgreSQL, object storage, and full stack restoration.

## Recovery Objectives

| Metric | Target |
|--------|--------|
| RPO (Recovery Point Objective) | 24 hours (daily backups) |
| RTO (Recovery Time Objective) | 4 hours (full stack restore) |
| Backup retention | 30 days local, 90 days S3 |

## What Gets Backed Up

| Component | Method | Frequency | Location |
|-----------|--------|-----------|----------|
| PostgreSQL | `pg_dump` (gzip) | Daily 02:00 UTC | `/backups` volume + S3 |
| Storage files | tar.gz snapshot | Daily (with S3 profile) | S3 |
| Redis | AOF persistence | Continuous | Docker volume |
| Config/secrets | `.env` (encrypted) | Manual / vault | Off-server |

## Automated Backups

```bash
# Start backup scheduler
docker compose --profile backup up -d smarthealth-backup

# Manual backup
docker compose --profile backup run --rm smarthealth-backup /backup.sh
```

Configure S3 in `.env`:

```env
S3_ENDPOINT=https://s3.af-south-1.amazonaws.com
S3_REGION=af-south-1
S3_BUCKET=smarthealth-backups-prod
S3_ACCESS_KEY=AKIA...
S3_SECRET_KEY=...
```

## Restore PostgreSQL

### From local backup

```bash
# List backups
docker compose exec smarthealth-backup ls -la /backups/

# Restore (destructive — drops existing data)
BACKUP_FILE=smarthealth-20260523T020000Z.sql.gz

docker compose stop smarthealth-api smarthealth-facility-portal
docker compose exec -T db psql -U postgres -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;"

gunzip -c backups/${BACKUP_FILE} | docker compose exec -T db psql -U postgres -d postgres

docker compose run --rm smarthealth-migrate
docker compose up -d
```

### From S3

```bash
aws s3 cp s3://smarthealth-backups-prod/postgres/smarthealth-20260523T020000Z.sql.gz ./restore.sql.gz
gunzip -c restore.sql.gz | docker compose exec -T db psql -U postgres -d postgres
```

## Full Stack Recovery (new server)

1. Provision new VPS (see [PRODUCTION.md](PRODUCTION.md))
2. Install Docker
3. Clone repository and restore `.env` from secure vault
4. Restore SSL certificates
5. Start database only: `docker compose up -d db`
6. Restore PostgreSQL from backup (above)
7. Start remaining services: `docker compose up -d`
8. Verify: `sh docker/scripts/healthcheck.sh`
9. Update DNS to new server IP
10. Verify Uptime Kuma monitors green

## Point-in-Time Recovery

For production requiring PITR (< 24h RPO):

- Enable WAL archiving on PostgreSQL
- Use managed database with PITR (AWS RDS, Azure Flexible Server)
- Or configure `archive_mode = on` with WAL shipping to S3

## Storage Recovery

```bash
# Download storage backup from S3
aws s3 cp s3://smarthealth-backups-prod/storage/smarthealth-storage-20260523T020000Z.tar.gz ./

# Restore to storage volume
docker compose stop storage
tar -xzf smarthealth-storage-20260523T020000Z.tar.gz -C /var/lib/docker/volumes/smarthealth_smarthealth-storage-data/_data/
docker compose start storage
```

## Disaster Scenarios

### Scenario 1: Database corruption

1. Stop API to prevent writes
2. Restore latest clean backup
3. Re-run migrations if needed
4. Resume services

### Scenario 2: Complete server loss

1. Follow "Full Stack Recovery"
2. RTO target: 4 hours
3. Communicate downtime to users via status page (Uptime Kuma public page)

### Scenario 3: Ransomware / compromise

1. Isolate server (firewall block all traffic)
2. Provision clean server
3. Restore from S3 backup predating incident
4. Rotate ALL secrets (JWT, API keys, Postgres password)
5. Revoke all user sessions: `SELECT private.revoke_all_user_tokens(user_id) ...`
6. Review audit logs: `/admin/security/audit-logs`

## Backup Verification

Run monthly restore drill:

```bash
# Restore to staging environment
docker compose -f docker-compose.yml -f docker-compose.staging.yml up -d db
# ... restore backup ...
sh docker/scripts/healthcheck.sh
```

Document results and RTO achieved.

## Related

- [BACKUP.md](../supabase/BACKUP.md) — detailed pg_dump procedures
- [PRODUCTION.md](PRODUCTION.md) — deployment guide
