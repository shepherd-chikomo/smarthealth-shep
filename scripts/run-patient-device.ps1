# Run the MyHealth patient app against the local API (main database).
# Prefers USB adb reverse (127.0.0.1) so the phone reaches the PC API without Wi-Fi/firewall issues.
# Usage:
#   ./scripts/run-patient-device.ps1
#   ./scripts/run-patient-device.ps1 -DeviceId RZ8RB1NHRDY
param(
  [string]$DeviceId = ""
)

$ErrorActionPreference = "Stop"
$RepoRoot = Split-Path -Parent $PSScriptRoot

$adb = @(
  "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe",
  "$env:USERPROFILE\AppData\Local\Android\Sdk\platform-tools\adb.exe"
) | Where-Object { Test-Path $_ } | Select-Object -First 1

function Get-WiFiIPv4 {
  $wifi = Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue |
    Where-Object {
      $_.InterfaceAlias -match 'Wi-?Fi' -and
      $_.IPAddress -notmatch '^(127\.|169\.254\.)'
    } |
    Select-Object -ExpandProperty IPAddress -First 1
  if ($wifi) { return $wifi }

  $addrs = Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue |
    Where-Object {
      $_.IPAddress -notmatch '^(127\.|169\.254\.)' -and
      $_.InterfaceAlias -notmatch 'vEthernet|Loopback|WSL|VirtualBox'
    } |
    Sort-Object -Property InterfaceMetric |
    Select-Object -ExpandProperty IPAddress -First 1
  if ($addrs) { return $addrs }
  throw "Could not detect a LAN IPv4 address. Set API_BASE_URL manually."
}

function Setup-AdbReverse {
  param([string]$Serial)

  if (-not $adb) {
    Write-Host "adb not found — using Wi-Fi API URL only."
    return $false
  }

  $adbArgs = @()
  if ($Serial) { $adbArgs += @("-s", $Serial) }

  & $adb @adbArgs reverse tcp:3000 tcp:3000 | Out-Null
  if ($LASTEXITCODE -ne 0) {
    Write-Host "adb reverse failed — falling back to Wi-Fi API URL."
    return $false
  }

  Write-Host "adb reverse: device 127.0.0.1:3000 -> PC localhost:3000"
  return $true
}

$useReverse = $false
if ($adb) {
  if ($DeviceId) {
    $useReverse = Setup-AdbReverse -Serial $DeviceId
  } else {
    $serial = (& $adb devices | Select-String "device$" | ForEach-Object { ($_ -split "\s+")[0] } | Select-Object -First 1)
    if ($serial) {
      $DeviceId = $serial
      $useReverse = Setup-AdbReverse -Serial $serial
    }
  }
}

if ($useReverse) {
  $apiUrl = "http://127.0.0.1:3000/v1"
} else {
  $ip = Get-WiFiIPv4
  $apiUrl = "http://${ip}:3000/v1"
  Write-Host "Wi-Fi API URL: $apiUrl"
  Write-Host "If data does not load, allow inbound TCP 3000 in Windows Firewall or use USB + adb reverse."
}

Write-Host "Using main database via API: $apiUrl"
Write-Host "Ensure API is listening: http://localhost:3000/health"
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
