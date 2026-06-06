#!/usr/bin/env bash
# Renew Let's Encrypt certs and reload nginx.
# Certs are stored under docker/certbot/conf (not /etc/letsencrypt).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
DOMAIN="${DOMAIN:-dev.smarthealth.co.zw}"
CONF_DIR="${ROOT}/docker/certbot/conf"
WWW_DIR="${ROOT}/docker/certbot/www"
SSL_DIR="${ROOT}/docker/nginx/ssl"

mkdir -p "${CONF_DIR}" "${WWW_DIR}" "${SSL_DIR}"

cd "${ROOT}"

if [ -d "${WWW_DIR}/.well-known" ] || docker compose ps nginx --status running >/dev/null 2>&1; then
  docker run --rm \
    -v "${CONF_DIR}:/etc/letsencrypt" \
    -v "${WWW_DIR}:/var/www/certbot" \
    certbot/certbot renew --webroot -w /var/www/certbot --quiet || true
else
  docker compose stop nginx
  docker run --rm -p 80:80 \
    -v "${CONF_DIR}:/etc/letsencrypt" \
    certbot/certbot renew --standalone --quiet || true
  docker compose up -d nginx
fi

docker run --rm \
  -v "${CONF_DIR}:/etc/letsencrypt" \
  -v "${SSL_DIR}:/ssl" \
  alpine sh -c "test -f /etc/letsencrypt/live/${DOMAIN}/fullchain.pem && cp /etc/letsencrypt/live/${DOMAIN}/fullchain.pem /ssl/ && cp /etc/letsencrypt/live/${DOMAIN}/privkey.pem /ssl/ && chmod 644 /ssl/fullchain.pem && chmod 600 /ssl/privkey.pem"

docker compose restart nginx
