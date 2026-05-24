#!/bin/sh
# Scheduled backup runner — runs backup daily at 02:00 UTC
set -eu

echo "SmartHealth backup scheduler started (schedule: ${BACKUP_SCHEDULE:-0 2 * * *})"

while true; do
  HOUR=$(date -u +%H)
  MIN=$(date -u +%M)

  if [ "$HOUR" = "02" ] && [ "$MIN" = "00" ]; then
    echo "==> Running scheduled backup at $(date -u)"
    /bin/sh /backup.sh
    if [ -f /backup-s3.sh ] && [ -n "${S3_BUCKET:-}" ]; then
      /bin/sh /backup-s3.sh
    fi
    sleep 61
  fi

  sleep 30
done
