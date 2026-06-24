# Run the MyHealth patient app against a remote SmartHealth server (dev/staging/prod).
# Usage:
#   ./scripts/run-patient-remote.ps1
#   ./scripts/run-patient-remote.ps1 -ServerUrl https://dev.smarthealth.co.zw -DeviceId RZ8RB1NHRDY
param(
  [string]$ServerUrl = "https://dev.smarthealth.co.zw",
  [string]$DeviceId = ""
)

$ErrorActionPreference = "Stop"
$RepoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)

$base = $ServerUrl.TrimEnd("/")
$apiUrl = "$base/v1"

Write-Host "Remote API: $apiUrl"
Write-Host "Checking server health..."
$healthUrl = "$base/health"
try {
  $resp = Invoke-RestMethod -Uri $healthUrl -TimeoutSec 15
  Write-Host "Health OK: $($resp | ConvertTo-Json -Compress)"
} catch {
  Write-Warning "Could not reach $healthUrl - continuing anyway. $_"
}

Write-Host ""
Write-Host "Note: remote server requires real patient OTP login (SKIP_AUTH is off)."
Write-Host ""

Set-Location $RepoRoot

$flutterArgs = @(
  "run",
  "--dart-define=API_BASE_URL=$apiUrl",
  "--dart-define=USE_MAIN_DATABASE=true"
)
if ($DeviceId) {
  $flutterArgs += @("-d", $DeviceId)
}

& flutter @flutterArgs
