# MyPractice marketing website

Standalone public marketing site for the MyPractice practitioner app. Served at **`mypractice.smarthealth.co.zw`**, separate from the facility admin portal on `dev.smarthealth.co.zw`.

## Local dev

```bash
cd apps/mypractice-web
npm install
npm run dev
```

Open http://localhost:3003

## Environment

| Variable | Default | Purpose |
|----------|---------|---------|
| `NEXT_PUBLIC_PORTAL_URL` | `https://dev.smarthealth.co.zw` | Login / claim CTAs |

## Docker

Built as `smarthealth-mypractice-web` (port 3003 internal). Nginx routes `mypractice.smarthealth.co.zw` to this container; all other hosts keep the facility portal.

## SSL

Issue or expand the Let's Encrypt cert to include the subdomain:

```bash
# On the server (after DNS A record for mypractice.smarthealth.co.zw)
docker run --rm \
  -v ./docker/certbot/conf:/etc/letsencrypt \
  -v ./docker/certbot/www:/var/www/certbot \
  certbot/certbot certonly --webroot -w /var/www/certbot \
  --expand -d dev.smarthealth.co.zw -d mypractice.smarthealth.co.zw
sh docker/scripts/renew-ssl.sh
```
