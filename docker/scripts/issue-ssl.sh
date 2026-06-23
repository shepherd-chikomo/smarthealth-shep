#!/usr/bin/env bash
# Issue or expand Let's Encrypt certificate for DOMAIN + SSL_EXTRA_DOMAINS.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
DOMAIN="${DOMAIN:-dev.smarthealth.co.zw}"
EXTRA="${SSL_EXTRA_DOMAINS:-mypractice.smarthealth.co.zw}"
CONF_DIR="${ROOT}/docker/certbot/conf"
WWW_DIR="${ROOT}/docker/certbot/www"
SSL_DIR="${ROOT}/docker/nginx/ssl"
EMAIL="${ACME_EMAIL:-ops@smarthealth.co.zw}"

mkdir -p "${CONF_DIR}" "${WWW_DIR}" "${SSL_DIR}"
cd "${ROOT}"

DOMAIN_ARGS=(-d "${DOMAIN}")
if [ -n "${EXTRA}" ]; then
  IFS=',' read -ra EXTRAS <<< "${EXTRA}"
  for d in "${EXTRAS[@]}"; do
    d="$(echo "$d" | xargs)"
    [ -n "$d" ] && DOMAIN_ARGS+=(-d "$d")
  done
fi

echo "==> Requesting certificate for: ${DOMAIN_ARGS[*]}"

docker compose up -d nginx

docker run --rm \
  -v "${CONF_DIR}:/etc/letsencrypt" \
  -v "${WWW_DIR}:/var/www/certbot" \
  certbot/certbot certonly --webroot -w /var/www/certbot \
  --email "${EMAIL}" --agree-tos --no-eff-email \
  --cert-name "${DOMAIN}" \
  --expand \
  "${DOMAIN_ARGS[@]}"

docker run --rm \
  -v "${CONF_DIR}:/etc/letsencrypt" \
  -v "${SSL_DIR}:/ssl" \
  alpine sh -c "cp /etc/letsencrypt/live/${DOMAIN}/fullchain.pem /ssl/ && cp /etc/letsencrypt/live/${DOMAIN}/privkey.pem /ssl/ && chmod 644 /ssl/fullchain.pem && chmod 600 /ssl/privkey.pem"

docker compose restart nginx
echo "==> Certificate installed for ${DOMAIN} (+ extras)"
