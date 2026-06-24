# SmartHealth local UAT — web dev servers (requires Docker stack running)
$ErrorActionPreference = "Stop"
$RepoRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$NodePath = "C:\Program Files\nodejs"
$DockerPath = "C:\Program Files\Docker\Docker\resources\bin"
$env:Path = "$NodePath;$DockerPath;" + $env:Path

Write-Host "Checking Docker stack..."
$running = docker ps --format "{{.Names}}" 2>$null | Select-String -Quiet "smarthealth-api"
if (-not $running) {
  Write-Host "Starting Docker services (db, auth, kong, api)..."
  Set-Location $RepoRoot
  docker compose up -d db redis auth rest storage meta kong inbucket smarthealth-migrate smarthealth-api
}

$devEnv = @"
`$env:Path = '$NodePath;' + `$env:Path
`$env:API_URL = 'http://localhost:3000'
`$env:NEXT_PUBLIC_SUPABASE_URL = 'http://localhost:8000'
"@

Write-Host "Starting Admin UI (http://localhost:5173/admin/)..."
Start-Process powershell -ArgumentList "-NoExit", "-Command", "$devEnv; cd '$RepoRoot\apps\admin'; npm.cmd run dev"

Write-Host "Starting Facility Portal (http://localhost:3001)..."
Start-Process powershell -ArgumentList "-NoExit", "-Command", "$devEnv; cd '$RepoRoot\apps\facility-portal'; npm.cmd run dev"

Write-Host ""
Write-Host "UAT URLs:"
Write-Host "  API:             http://localhost:3000/v1/"
Write-Host "  API docs:        http://localhost:3000/docs"
Write-Host "  Supabase Kong:   http://localhost:8000"
Write-Host "  Admin dashboard: http://localhost:5173/admin/"
Write-Host "  Facility portal: http://localhost:3001"
Write-Host "  Studio:          http://localhost:54323"
Write-Host ""
Write-Host "Test OTP: phone 0771234567 / code 123456"
Write-Host "  First login only: run scripts\platform\setup-dev-admin.ps1 then sign in again"
