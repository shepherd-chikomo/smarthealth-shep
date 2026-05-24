# SmartHealth Supabase — Acceptance Verification (Windows)
param(
    [string]$SupabaseUrl = "http://127.0.0.1:54321",
    [string]$AnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0"
)

$ErrorActionPreference = "Stop"
$passed = 0
$failed = 0

function Test-Step($Name, $ScriptBlock) {
    Write-Host "  [$Name] " -NoNewline
    try {
        & $ScriptBlock
        Write-Host "PASS" -ForegroundColor Green
        $script:passed++
    }
    catch {
        Write-Host "FAIL: $_" -ForegroundColor Red
        $script:failed++
    }
}

Write-Host "`n==> SmartHealth Supabase Verification`n" -ForegroundColor Cyan

# 1. API health
Test-Step "API reachable" {
    $r = Invoke-RestMethod -Uri "$SupabaseUrl/rest/v1/" -Headers @{ apikey = $AnonKey } -Method Get
    if ($null -eq $r) { throw "No response" }
}

# 2. Auth health
Test-Step "Auth service" {
    $r = Invoke-WebRequest -Uri "$SupabaseUrl/auth/v1/health" -UseBasicParsing
    if ($r.StatusCode -ne 200) { throw "Status $($r.StatusCode)" }
}

# 3. RLS — public facilities readable
Test-Step "RLS public facilities" {
    $facilities = Invoke-RestMethod -Uri "$SupabaseUrl/rest/v1/facilities?select=id,name&limit=1" `
        -Headers @{ apikey = $AnonKey; Authorization = "Bearer $AnonKey" }
    if ($facilities.Count -lt 1) { throw "No seed facilities found — run 'supabase db reset'" }
}

# 4. Storage buckets exist
Test-Step "Storage buckets" {
    $expected = @("provider-images", "medical-documents", "prescriptions", "facility-assets", "avatars")
    $buckets = Invoke-RestMethod -Uri "$SupabaseUrl/storage/v1/bucket" `
        -Headers @{ apikey = $AnonKey; Authorization = "Bearer $AnonKey" }
    $ids = @($buckets | ForEach-Object { if ($_.id) { $_.id } else { $_.name } })
    foreach ($bucket in $expected) {
        if ($ids -notcontains $bucket) { throw "Missing bucket: $bucket" }
    }
}

# 5. Email signup
Test-Step "Email auth signup" {
    $email = "test-$(Get-Random)@smarthealth.local"
    $body = @{
        email = $email
        password = "TestPass123!"
        data = @{ first_name = "Test"; last_name = "User" }
    } | ConvertTo-Json
    $r = Invoke-RestMethod -Uri "$SupabaseUrl/auth/v1/signup" -Method Post `
        -Headers @{ apikey = $AnonKey; "Content-Type" = "application/json" } -Body $body
    if (-not $r.user.id) { throw "Signup did not return user" }
}

# 6. Emergency facilities (Zimbabwe seed)
Test-Step "Zimbabwe emergency data" {
    $ef = Invoke-RestMethod -Uri "$SupabaseUrl/rest/v1/emergency_facilities?select=name,province&limit=1" `
        -Headers @{ apikey = $AnonKey; Authorization = "Bearer $AnonKey" }
    if ($ef.Count -lt 1) { throw "No emergency facilities — run seed" }
}

Write-Host "`n==> Results: $passed passed, $failed failed`n" -ForegroundColor $(if ($failed -eq 0) { "Green" } else { "Red" })

if ($failed -gt 0) { exit 1 }
