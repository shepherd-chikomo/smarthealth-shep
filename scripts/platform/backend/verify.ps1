# SmartHealth API verification script
param(
    [string]$BaseUrl = "http://localhost:3000"
)

$ErrorActionPreference = "Stop"
$passed = 0
$failed = 0

function Test-Endpoint {
    param(
        [string]$Name,
        [string]$Method,
        [string]$Path,
        [int[]]$ExpectedStatus = @(200)
    )

    try {
        $response = Invoke-WebRequest -Uri "$BaseUrl$Path" -Method $Method -UseBasicParsing -ErrorAction Stop
        if ($ExpectedStatus -contains $response.StatusCode) {
            Write-Host "[PASS] $Name ($($response.StatusCode))" -ForegroundColor Green
            $script:passed++
        } else {
            Write-Host "[FAIL] $Name — expected $($ExpectedStatus -join '/'), got $($response.StatusCode)" -ForegroundColor Red
            $script:failed++
        }
    } catch {
        $status = $_.Exception.Response.StatusCode.value__
        if ($ExpectedStatus -contains $status) {
            Write-Host "[PASS] $Name ($status)" -ForegroundColor Green
            $script:passed++
        } else {
            Write-Host "[FAIL] $Name — $($_.Exception.Message)" -ForegroundColor Red
            $script:failed++
        }
    }
}

Write-Host "`nSmartHealth API Verification" -ForegroundColor Cyan
Write-Host "Base URL: $BaseUrl`n"

Test-Endpoint -Name "Health check" -Method GET -Path "/health"
Test-Endpoint -Name "OpenAPI docs" -Method GET -Path "/docs"
Test-Endpoint -Name "List providers" -Method GET -Path "/v1/providers?page=1&limit=5"
Test-Endpoint -Name "List facilities" -Method GET -Path "/v1/facilities"
Test-Endpoint -Name "Emergency services" -Method GET -Path "/v1/emergency/services"
Test-Endpoint -Name "Protected route (401)" -Method GET -Path "/v1/patients/me" -ExpectedStatus @(401)

Write-Host "`nResults: $passed passed, $failed failed" -ForegroundColor $(if ($failed -eq 0) { "Green" } else { "Yellow" })
if ($failed -gt 0) { exit 1 }
