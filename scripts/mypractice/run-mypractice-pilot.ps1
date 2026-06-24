param(
  [string]$ServerUrl = "https://dev.smarthealth.co.zw",
  [string]$DeviceId
)

$ErrorActionPreference = "Stop"
$RepoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)

$adb = @(
  "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe",
  "$env:USERPROFILE\AppData\Local\Android\Sdk\platform-tools\adb.exe"
) | Where-Object { Test-Path $_ } | Select-Object -First 1

if (-not $DeviceId -and $adb) {
  $DeviceId = (& $adb devices | Select-String "device$" | ForEach-Object { ($_ -split "\s+")[0] } | Select-Object -First 1)
}

if ($DeviceId) {
  Write-Host "Using device: $DeviceId"
} else {
  Write-Host "No adb device found - flutter will pick default target."
}

$apiUrl = if ($ServerUrl.EndsWith("/v1")) { $ServerUrl } else { "$ServerUrl/v1" }
Write-Host "MyPractice (PILOT) -> $apiUrl [real auth, no seed data]"

Set-Location (Join-Path $RepoRoot "my_practice")

# No DEV_MODE, no SKIP_AUTH, no dev-cert trust — identical to production behaviour
# in a debug build so you can iterate quickly without a release build.
$runArgs = @(
  "run",
  "--dart-define=API_BASE_URL=$apiUrl"
)

if ($DeviceId) {
  $runArgs += @("-d", $DeviceId)
}

flutter @runArgs
