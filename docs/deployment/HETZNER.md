# Deploying on Hetzner

Hetzner Cloud offers excellent price/performance for SmartHealth deployments in Europe with acceptable latency to Zimbabwe (~150ms via submarine cable).

## Recommended Instance

| Environment | Type | Specs | Cost (~) |
|-------------|------|-------|----------|
| Staging | CPX31 | 4 vCPU, 8 GB | €12/mo |
| Production | CPX41 | 8 vCPU, 16 GB | €19/mo |
| High traffic | CPX51 | 16 vCPU, 32 GB | €38/mo |

**Location:** Falkenstein (fsn1) or Helsinki — lowest latency from Southern Africa among Hetzner regions.

## Setup

```bash
# Create server via Hetzner Cloud Console or hcloud CLI
hcloud server create --name smarthealth-prod --type cpx41 --image ubuntu-24.04 --location fsn1

# SSH in
ssh root@YOUR_SERVER_IP

# Install Docker
curl -fsSL https://get.docker.com | sh

# Firewall
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw enable

# Deploy
git clone https://github.com/your-org/smarthealth-shep.git /opt/smarthealth
cd /opt/smarthealth
cp docker/.env.example .env
nano .env  # configure secrets

sh docker/scripts/bootstrap.sh
```

## Hetzner Object Storage (backups)

```env
S3_ENDPOINT=https://fsn1.your-objectstorage.com
S3_REGION=fsn1
S3_BUCKET=smarthealth-backups
S3_ACCESS_KEY=your-access-key
S3_SECRET_KEY=your-secret-key
```

Create bucket in Hetzner Console → Object Storage.

## Volumes

Attach a Volume for database persistence:

```bash
hcloud volume create --name smarthealth-data --size 100 --location fsn1
hcloud volume attach --server smarthealth-prod smarthealth-data

# Mount
mkfs.ext4 /dev/disk/by-id/scsi-0HC_Volume_XXXXX
mkdir -p /mnt/smarthealth-data
mount /dev/disk/by-id/scsi-0HC_Volume_XXXXX /mnt/smarthealth-data

# Update docker-compose volume paths or symlink
```

## CI/CD integration

Set GitHub secrets for deploy workflow:

```
DEPLOY_HOST=YOUR_SERVER_IP
DEPLOY_USER=root
DEPLOY_SSH_KEY=<private key>
```

Trigger deploy with target `hetzner`.

## Monitoring

Restrict Grafana/Prometheus ports to your IP:

```bash
ufw allow from YOUR_OFFICE_IP to any port 9090
ufw allow from YOUR_OFFICE_IP to any port 3002
```

Or use SSH tunnel: `ssh -L 3002:localhost:3002 root@YOUR_SERVER_IP`
