# SmartHealth Database Backup & Recovery

## Backup Strategy

| Environment | Method | Schedule | Retention |
|-------------|--------|----------|-----------|
| Local | Manual / disabled | On demand | N/A |
| Staging | pg_dump + S3 | Daily 02:00 CAT | 14 days |
| Production | pg_dump + S3 | Daily 02:00 CAT | 90 days |

## Local Backup

```powershell
supabase db dump -f backups/local-$(Get-Date -Format yyyyMMdd).sql
# or
./scripts/supabase/backup.ps1
```

## Production Backup (pg_dump)

```bash
export DATABASE_URL="postgresql://postgres:PASSWORD@db-host:5432/postgres"
pg_dump --no-owner --no-acl --clean --if-exists "$DATABASE_URL" | gzip > smarthealth-$(date -u +%Y%m%d).sql.gz
```

### Automated backup (cron)

```bash
0 2 * * * postgres /opt/smarthealth/docker/scripts/backup.sh >> /var/log/smarthealth-backup.log 2>&1
```

### Upload to S3

```bash
aws s3 cp smarthealth-$(date -u +%Y%m%d).sql.gz \
  s3://smarthealth-production-backups/daily/ \
  --region af-south-1
```

## Supabase Cloud Backups

Supabase Pro plan includes daily automated backups and point-in-time recovery on Pro+.

## Recovery

```bash
gunzip -c smarthealth-20260523.sql.gz | psql "$DATABASE_URL"
```

## Audit Log Retention

```sql
select audit.purge_old_logs(365);
```

## Disaster Recovery Checklist

- Backups tested monthly (restore to staging)
- Secrets stored in vault (not in backup files)
- RTO/RPO documented for your deployment
- Off-site backup copy (different region/account)
- Runbook shared with ops team
