# SmartHealth PostgreSQL Backup (Windows)
param(
    [string]$OutputDir = "backups",
    [int]$RetentionDays = 30
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$Timestamp = Get-Date -Format "yyyyMMddTHHmmss"
$OutputPath = Join-Path $Root $OutputDir

New-Item -ItemType Directory -Force -Path $OutputPath | Out-Null

Write-Host "==> SmartHealth database backup" -ForegroundColor Cyan

if (Get-Command supabase -ErrorAction SilentlyContinue) {
    $DumpFile = Join-Path $OutputPath "smarthealth-$Timestamp.sql"
    supabase db dump -f $DumpFile
    Write-Host "==> Saved: $DumpFile" -ForegroundColor Green
}
elseif (Get-Command pg_dump -ErrorAction SilentlyContinue) {
    $env:PGPASSWORD = if ($env:POSTGRES_PASSWORD) { $env:POSTGRES_PASSWORD } else { "postgres" }
    $DumpFile = Join-Path $OutputPath "smarthealth-$Timestamp.sql"
    pg_dump -h 127.0.0.1 -p 54322 -U postgres --no-owner --no-acl postgres -f $DumpFile
    Write-Host "==> Saved: $DumpFile" -ForegroundColor Green
}
else {
    Write-Error "Neither supabase CLI nor pg_dump found."
}

# Prune old backups
Get-ChildItem $OutputPath -Filter "smarthealth-*.sql" |
    Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-$RetentionDays) } |
    Remove-Item -Force

Write-Host "==> Backup complete" -ForegroundColor Green
