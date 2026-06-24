param(
  [string]$DeviceId,
  [string]$ServerUrl = "https://dev.smarthealth.co.zw",
  # Set to $false when pointing at a real server so real login is required.
  [bool]$SkipAuth = $true
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
$authLabel = if ($SkipAuth) { "seed data / skip auth" } else { "real auth required" }
Write-Host "MyPractice -> $apiUrl [DEV_MODE + $authLabel]"

Set-Location (Join-Path $RepoRoot "my_practice")

$runArgs = @(
  "run",
  "--dart-define=DEV_MODE=true",
  "--dart-define=API_BASE_URL=$apiUrl",
  "--dart-define=TRUST_DEV_CERTIFICATES=true"
)

if ($SkipAuth) {
  $runArgs += "--dart-define=SKIP_AUTH=true"
}

if ($DeviceId) {
  $runArgs += @("-d", $DeviceId)
}

flutter @runArgs
