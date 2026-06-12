param(
  [string]$DeviceId,
  [string]$ServerUrl = "https://dev.smarthealth.co.zw"
)

$ErrorActionPreference = "Stop"
Set-Location (Split-Path $PSScriptRoot -Parent)

$apiUrl = if ($ServerUrl.EndsWith("/v1")) { $ServerUrl } else { "$ServerUrl/v1" }

Set-Location (Join-Path (Split-Path $PSScriptRoot -Parent) "my_practice")

$runArgs = @(
  "run",
  "--dart-define=DEV_MODE=true",
  "--dart-define=API_BASE_URL=$apiUrl",
  "--dart-define=SKIP_AUTH=true"
)

if ($DeviceId) {
  $runArgs += @("-d", $DeviceId)
}

flutter @runArgs
