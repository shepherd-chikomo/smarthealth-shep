#!/bin/sh
# Upload latest backup and storage snapshot to S3-compatible object storage
set -eu

if [ -z "${S3_BUCKET:-}" ] || [ -z "${S3_ACCESS_KEY:-}" ]; then
  echo "==> S3 upload skipped (S3_BUCKET or S3_ACCESS_KEY not configured)"
  exit 0
fi

BACKUP_DIR="${BACKUP_DIR:-/backups}"
LATEST=$(ls -t "${BACKUP_DIR}"/smarthealth-*.sql.gz 2>/dev/null | head -1)

if [ -z "${LATEST}" ]; then
  echo "==> No backup file found to upload"
  exit 1
fi

TIMESTAMP=$(date -u +"%Y%m%dT%H%M%SZ")
FILENAME=$(basename "${LATEST}")

echo "==> Uploading ${FILENAME} to s3://${S3_BUCKET}/postgres/${FILENAME}"

if command -v aws >/dev/null 2>&1; then
  AWS_ARGS=""
  if [ -n "${S3_ENDPOINT:-}" ]; then
    AWS_ARGS="--endpoint-url ${S3_ENDPOINT}"
  fi
  AWS_ACCESS_KEY_ID="${S3_ACCESS_KEY}" \
  AWS_SECRET_ACCESS_KEY="${S3_SECRET_KEY}" \
  AWS_DEFAULT_REGION="${S3_REGION:-af-south-1}" \
    aws s3 cp "${LATEST}" "s3://${S3_BUCKET}/postgres/${FILENAME}" ${AWS_ARGS}

  if [ -d /storage-backup ]; then
    STORAGE_ARCHIVE="/backups/smarthealth-storage-${TIMESTAMP}.tar.gz"
    tar -czf "${STORAGE_ARCHIVE}" -C /storage-backup .
    AWS_ACCESS_KEY_ID="${S3_ACCESS_KEY}" \
    AWS_SECRET_ACCESS_KEY="${S3_SECRET_KEY}" \
    AWS_DEFAULT_REGION="${S3_REGION:-af-south-1}" \
      aws s3 cp "${STORAGE_ARCHIVE}" "s3://${S3_BUCKET}/storage/$(basename ${STORAGE_ARCHIVE})" ${AWS_ARGS}
    echo "==> Storage backup uploaded"
  fi
else
  echo "==> aws CLI not available — install aws-cli in backup container for S3 upload"
  exit 1
fi

echo "==> S3 upload complete"
