# Deploying on Azure

Azure deployment for SmartHealth using Container Apps or a VM-based Docker Compose stack.

## Option A: Ubuntu VM (Docker Compose)

| Environment | VM Size | Specs |
|-------------|---------|-------|
| Staging | Standard_D4s_v5 | 4 vCPU, 16 GB |
| Production | Standard_D8s_v5 | 8 vCPU, 32 GB |

**Region:** `southafricanorth` (Johannesburg) — best latency for Zimbabwe.

```bash
# Create resource group
az group create --name smarthealth-rg --location southafricanorth

# Create VM
az vm create \
  --resource-group smarthealth-rg \
  --name smarthealth-vm \
  --image Ubuntu2404 \
  --size Standard_D4s_v5 \
  --admin-username azureuser \
  --generate-ssh-keys

# Open ports
az vm open-port --resource-group smarthealth-rg --name smarthealth-vm --port 443
az vm open-port --resource-group smarthealth-rg --name smarthealth-vm --port 80

ssh azureuser@PUBLIC_IP
curl -fsSL https://get.docker.com | sh
# ... follow PRODUCTION.md
```

## Option B: Azure Container Apps

1. Push images to Azure Container Registry (ACR)
2. Create Container Apps Environment
3. Deploy services:

| Container App | Ingress | Port |
|---------------|---------|------|
| smarthealth-api | `/v1`, `/docs`, `/health` | 3000 |
| smarthealth-admin | `/admin` | 80 |
| smarthealth-facility-portal | `/` | 3001 |

4. **Azure Database for PostgreSQL Flexible Server** for `DATABASE_URL`
5. **Azure Cache for Redis** for `REDIS_URL`
6. **Azure Blob Storage** for backups (S3-compatible via endpoint)

### Blob Storage backups

```env
S3_ENDPOINT=https://smarthealthbackups.blob.core.windows.net
S3_BUCKET=backups
S3_ACCESS_KEY=<storage account name>
S3_SECRET_KEY=<storage account key>
```

## Option C: Azure Kubernetes Service (AKS)

For large-scale multi-facility deployments:

- Helm chart (future) wrapping docker-compose services
- Azure Key Vault for secrets via CSI driver
- Application Gateway for TLS

## Monitoring

- **Azure Monitor** for VM metrics
- **Sentry** for application errors (`SENTRY_DSN`)
- Self-hosted Grafana on VM or Grafana Cloud

## CI/CD

GitHub secrets:

```
AZURE_CREDENTIALS={"clientId":"...","clientSecret":"...","subscriptionId":"...","tenantId":"..."}
AZURE_RESOURCE_GROUP=smarthealth-rg
```

Trigger deploy workflow with target `azure`.

## Cost estimate (southafricanorth)

| Service | Monthly (~) |
|---------|-------------|
| VM Standard_D4s_v5 | $140 |
| PostgreSQL Flexible (Burstable B2s) | $30 |
| Blob Storage | $5 |
| **Total** | **~$175** |
