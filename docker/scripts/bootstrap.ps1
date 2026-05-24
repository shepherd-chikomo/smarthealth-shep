# Bootstrap SmartHealth stack on Windows (PowerShell)
$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $Root

if (-not (Test-Path .env)) {
    Copy-Item docker\.env.example .env
    Write-Host "Created .env from docker/.env.example"
}

if (-not (Test-Path docker\nginx\ssl\fullchain.pem)) {
    Write-Host "Generating self-signed SSL certificates..."
    docker run --rm -v "${Root}/docker/nginx/ssl:/ssl" alpine/openssl req -x509 -nodes -days 365 `
        -newkey rsa:4096 -keyout /ssl/privkey.pem -out /ssl/fullchain.pem `
        -subj "/CN=localhost/O=SmartHealth/C=ZW"
}

Write-Host "Building and starting SmartHealth stack..."
docker compose build smarthealth-api smarthealth-admin smarthealth-facility-portal
docker compose up -d

Write-Host ""
Write-Host "=== SmartHealth is starting ==="
Write-Host "  Portal:  http://localhost/"
Write-Host "  Admin:   http://localhost/admin/"
Write-Host "  API:     http://localhost/v1/"
Write-Host "  Studio:  http://localhost:54323"
Write-Host ""
Write-Host "Run health check: docker compose ps"
