param(
  [string]$ServerUrl = "https://dev.smarthealth.co.zw"
)

$ErrorActionPreference = "Stop"
$RepoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)

$apiUrl = if ($ServerUrl.EndsWith("/v1")) { $ServerUrl } else { "$ServerUrl/v1" }
Write-Host "Building MyPractice release APK -> $apiUrl"

Set-Location (Join-Path $RepoRoot "my_practice")

flutter build apk --release `
  --dart-define=API_BASE_URL=$apiUrl

$apk = Join-Path $RepoRoot "my_practice\build\app\outputs\flutter-apk\app-release.apk"
if (Test-Path $apk) {
  Write-Host ""
  Write-Host "Release APK: $apk"
} else {
  Write-Host "Build may have failed - check output above."
}
