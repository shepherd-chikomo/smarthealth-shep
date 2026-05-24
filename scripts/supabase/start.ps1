# SmartHealth Supabase — Local Start Script (Windows)
param(
    [switch]$Reset,
    [switch]$Status
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)

Push-Location $Root

function Test-Command($Name) {
    return [bool](Get-Command $Name -ErrorAction SilentlyContinue)
}

if (-not (Test-Command supabase)) {
    Write-Error @"
Supabase CLI not found. Install with:
  scoop install supabase
  # or: npm install -g supabase
"@
}

if ($Status) {
    supabase status
    Pop-Location
    exit 0
}

Write-Host "==> Starting SmartHealth Supabase local stack..." -ForegroundColor Cyan
supabase start

if ($Reset) {
    Write-Host "==> Resetting database (migrations + seed)..." -ForegroundColor Cyan
    supabase db reset
}

Write-Host ""
Write-Host "==> SmartHealth Supabase is ready" -ForegroundColor Green
Write-Host ""
supabase status

Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Copy supabase/env/.env.local.example to .env.local"
Write-Host "  2. Update keys from 'supabase status' output above"
Write-Host "  3. Open Studio: http://127.0.0.1:54323"
Write-Host "  4. Run verification: ./scripts/supabase/verify.ps1"

Pop-Location
