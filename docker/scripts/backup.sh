#!/bin/sh
# SmartHealth PostgreSQL backup script
set -eu

BACKUP_DIR="${BACKUP_DIR:-/backups}"
TIMESTAMP=$(date -u +"%Y%m%dT%H%M%SZ")
FILENAME="smarthealth-${TIMESTAMP}.sql.gz"
RETENTION="${BACKUP_RETENTION_DAYS:-30}"

mkdir -p "${BACKUP_DIR}"

echo "==> Backing up ${PGDATABASE}@${PGHOST}:${PGPORT}"
pg_dump --no-owner --no-acl --clean --if-exists | gzip > "${BACKUP_DIR}/${FILENAME}"
echo "==> Backup saved: ${BACKUP_DIR}/${FILENAME}"

echo "==> Pruning backups older than ${RETENTION} days"
find "${BACKUP_DIR}" -name "smarthealth-*.sql.gz" -mtime +"${RETENTION}" -delete

echo "==> Backup complete"
