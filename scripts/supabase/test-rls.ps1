# SmartHealth RLS Security Test Runner (Windows)
param(
    [string]$DatabaseUrl = $env:DATABASE_URL
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)

if (-not $DatabaseUrl) {
    $DatabaseUrl = "postgresql://postgres:postgres@127.0.0.1:54322/postgres"
}

Write-Host "==> Running RLS security tests" -ForegroundColor Cyan
Write-Host "    Database: $DatabaseUrl"

if (Get-Command psql -ErrorAction SilentlyContinue) {
    psql $DatabaseUrl -v ON_ERROR_STOP=1 -f (Join-Path $Root "supabase\tests\rls_security_tests.sql")
}
elseif (Get-Command supabase -ErrorAction SilentlyContinue) {
    supabase db execute --db-url $DatabaseUrl -f (Join-Path $Root "supabase\tests\rls_security_tests.sql")
}
else {
    Write-Error "psql or supabase CLI required to run RLS tests."
}

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n==> All RLS security tests passed" -ForegroundColor Green
} else {
    Write-Error "RLS security tests failed."
}
