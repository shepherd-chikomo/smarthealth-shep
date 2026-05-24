# Deploying on Ubuntu VPS

Generic guide for any Ubuntu 22.04/24.04 VPS — Contabo, Vultr, Linode, OVH, or on-premise hardware.

## Minimum Requirements

- Ubuntu 22.04 or 24.04 LTS
- 4 vCPU, 8 GB RAM, 80 GB SSD
- Public IP with ports 80 and 443 accessible
- Domain name (optional for staging, required for production TLS)

## 1. Initial Server Setup

```bash
ssh root@YOUR_SERVER_IP

# Create deploy user
adduser smarthealth
usermod -aG sudo smarthealth
rsync --archive --chown=smarthealth:smarthealth ~/.ssh /home/smarthealth

# As smarthealth user
su - smarthealth
```

## 2. Install Docker

```bash
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER
newgrp docker

docker --version
docker compose version
```

## 3. Firewall

```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 22/tcp comment 'SSH'
sudo ufw allow 80/tcp comment 'HTTP'
sudo ufw allow 443/tcp comment 'HTTPS'
sudo ufw enable
sudo ufw status
```

## 4. Deploy SmartHealth

```bash
sudo mkdir -p /opt/smarthealth
sudo chown $USER:$USER /opt/smarthealth
git clone https://github.com/your-org/smarthealth-shep.git /opt/smarthealth
cd /opt/smarthealth

cp docker/.env.example .env
nano .env
```

Required `.env` changes for production:

```env
ENVIRONMENT=production
POSTGRES_PASSWORD=<strong-password>
JWT_SECRET=<32+-char-secret>
ANON_KEY=<generated>
SERVICE_ROLE_KEY=<generated>
DOMAIN=app.smarthealth.co.zw
PUBLIC_URL=https://app.smarthealth.co.zw
SITE_URL=https://app.smarthealth.co.zw
```

```bash
sh docker/scripts/bootstrap.sh
```

## 5. TLS with Let's Encrypt

```bash
sudo apt install certbot
sudo certbot certonly --webroot -w /var/www/html \
  -d app.smarthealth.co.zw \
  --email ops@smarthealth.co.zw --agree-tos

sudo cp /etc/letsencrypt/live/app.smarthealth.co.zw/fullchain.pem docker/nginx/ssl/
sudo cp /etc/letsencrypt/live/app.smarthealth.co.zw/privkey.pem docker/nginx/ssl/
sudo chown $USER:$USER docker/nginx/ssl/*.pem

docker compose restart nginx
```

## 6. Systemd Service (auto-start on boot)

```bash
sudo tee /etc/systemd/system/smarthealth.service << 'EOF'
[Unit]
Description=SmartHealth Docker Stack
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/opt/smarthealth
ExecStart=/usr/bin/docker compose up -d
ExecStop=/usr/bin/docker compose down
User=smarthealth

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable smarthealth
sudo systemctl start smarthealth
```

## 7. Log Rotation

Docker json-file logging is configured in `docker-compose.yml` (10 MB × 3 files per service).

View logs:

```bash
docker compose logs -f --tail=100 smarthealth-api
journalctl -u smarthealth -f
```

## 8. Updates

```bash
cd /opt/smarthealth
git pull origin main
docker compose build
docker compose run --rm smarthealth-migrate
docker compose up -d --remove-orphans
sh docker/scripts/healthcheck.sh
```

## 9. Hardening

```bash
# Disable root SSH login
sudo sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
sudo systemctl restart sshd

# Automatic security updates
sudo apt install unattended-upgrades
sudo dpkg-reconfigure -plow unattended-upgrades

# Fail2ban
sudo apt install fail2ban
sudo systemctl enable fail2ban
```

## 10. Verify Deployment

```bash
sh docker/scripts/healthcheck.sh
curl -s https://app.smarthealth.co.zw/health | jq .
curl -s https://app.smarthealth.co.zw/v1/providers | jq '.pagination'
```

## CI/CD Deploy

Configure GitHub secrets and trigger deploy workflow with target `ubuntu-vps`.

See [PRODUCTION.md](PRODUCTION.md) for full reference.
