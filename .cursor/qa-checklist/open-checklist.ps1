# Opens the QA checklist canvas in Cursor (interactive test checklist).
$canvas = Join-Path $env:USERPROFILE ".cursor\projects\c-Users-sheph-Projects-smarthealth-shep\canvases\qa-checklist.canvas.tsx"
if (-not (Test-Path $canvas)) {
    Write-Error "Canvas not found: $canvas"
    exit 1
}
& cursor -r -g "${canvas}:1"
Write-Host "Opened $canvas - click Open Canvas in the editor to show it beside chat."
