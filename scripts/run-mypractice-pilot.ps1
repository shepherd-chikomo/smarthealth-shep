param(
  [string]$DeviceId,
  [string]$ServerUrl = "https://dev.smarthealth.co.zw"
)

$ErrorActionPreference = "Stop"
$RepoRoot = Split-Path -Parent $PSScriptRoot

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
Write-Host "MyPractice PILOT -> $apiUrl [real auth + sync, no seed bypass]"

Set-Location (Join-Path $RepoRoot "my_practice")

$runArgs = @(
  "run",
  "--dart-define=API_BASE_URL=$apiUrl",
  "--dart-define=TRUST_DEV_CERTIFICATES=true"
)

if ($DeviceId) {
  $runArgs += @("-d", $DeviceId)
}

flutter @runArgs
