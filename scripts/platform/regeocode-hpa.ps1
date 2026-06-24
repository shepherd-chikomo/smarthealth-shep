# Re-format addresses and re-geocode HPA facilities (multi-strategy Nominatim).
# Requires local Supabase Postgres on 127.0.0.1:54322 and ~90+ minutes for full HPA set.
$ErrorActionPreference = 'Stop'
Set-Location (Join-Path $PSScriptRoot '..\backend')

Write-Host 'Applying geocode_quality migration...'
npm run db:migrate:geocode-quality

Write-Host 'Fixing facility addresses...'
npm run fix:addresses

$failuresCsv = Join-Path $PSScriptRoot '..\geocode-failures.csv'
Write-Host "Geocoding facilities (failures -> $failuresCsv)..."
npm run geocode:facilities -- --import-source HPA --reset --clear-cache --csv $failuresCsv

Write-Host 'Audit summary:'
npm run audit:geocode
