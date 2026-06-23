#!/usr/bin/env bash
# Expand the dev TLS cert to include myhealth.smarthealth.co.zw (run once after DNS is set).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
PRIMARY="${DOMAIN:-dev.smarthealth.co.zw}"
PRACTICE="${MYPRACTICE_DOMAIN:-mypractice.smarthealth.co.zw}"
HEALTH="${MYHEALTH_DOMAIN:-myhealth.smarthealth.co.zw}"
CONF_DIR="${ROOT}/docker/certbot/conf"
WWW_DIR="${ROOT}/docker/certbot/www"
EMAIL="${ACME_EMAIL:-ops@smarthealth.co.zw}"

mkdir -p "${CONF_DIR}" "${WWW_DIR}"
cd "${ROOT}"

echo "==> Requesting/expand cert for ${PRIMARY}, ${PRACTICE}, and ${HEALTH}"

docker run --rm \
  -v "${CONF_DIR}:/etc/letsencrypt" \
  -v "${WWW_DIR}:/var/www/certbot" \
  certbot/certbot certonly --webroot -w /var/www/certbot \
  --email "${EMAIL}" --agree-tos --non-interactive \
  --expand -d "${PRIMARY}" -d "${PRACTICE}" -d "${HEALTH}" || true

sh "${ROOT}/docker/scripts/renew-ssl.sh"
echo "==> Done. Verify: https://${HEALTH}/"
