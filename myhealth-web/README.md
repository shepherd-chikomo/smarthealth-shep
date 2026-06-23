# MyHealth marketing site

Standalone patient-app marketing site served at **myhealth.smarthealth.co.zw**.

## Local dev

```bash
cd myhealth-web
npm install
npm run dev
```

Open http://localhost:3004

## Production

Built as `smarthealth-myhealth-web` in Docker Compose (internal port **3004**). Nginx routes `myhealth.smarthealth.co.zw` to this service.

After DNS is set:

```bash
sh docker/scripts/expand-ssl-myhealth.sh
```

Assets are sourced from the Lovable reference site `myhealth-connect-africa.lovable.app`.
