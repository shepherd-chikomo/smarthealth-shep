# SmartHealth local UAT — web dev servers (requires Docker stack running)
$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $Root

Write-Host "Starting Admin UI (http://localhost:5173/admin/)..."
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$Root\admin'; npm run dev"

Write-Host "Starting Facility Portal (http://localhost:3001)..."
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$Root\facility-portal'; `$env:API_URL='http://localhost:3000'; `$env:NEXT_PUBLIC_SUPABASE_URL='http://localhost:8000'; npm run dev"

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
Write-Host "  1. Click Send OTP, then enter code and Sign in"
Write-Host "  2. First login only: run scripts\setup-dev-admin.ps1 to grant super_admin"
