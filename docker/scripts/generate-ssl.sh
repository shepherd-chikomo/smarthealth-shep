#!/bin/sh
# Generate self-signed TLS certificates for local/production bootstrap
set -eu

SSL_DIR="$(dirname "$0")/../nginx/ssl"
DOMAIN="${DOMAIN:-localhost}"
DAYS="${SSL_CERT_DAYS:-365}"

mkdir -p "${SSL_DIR}"

openssl req -x509 -nodes -days "${DAYS}" -newkey rsa:4096 \
  -keyout "${SSL_DIR}/privkey.pem" \
  -out "${SSL_DIR}/fullchain.pem" \
  -subj "/CN=${DOMAIN}/O=SmartHealth/C=ZW"

echo "Generated self-signed cert for ${DOMAIN} in ${SSL_DIR}"
echo "For production, use Let's Encrypt — see docs/deployment/SSL.md"
