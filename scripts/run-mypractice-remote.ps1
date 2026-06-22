param(
  [string]$ServerUrl = "https://dev.smarthealth.co.zw",
  [string]$DeviceId
)

# Remote run always uses real auth so portal data (services, team, etc.) syncs correctly.
$extraArgs = @{ ServerUrl = $ServerUrl; SkipAuth = $false }
if ($DeviceId) { $extraArgs["DeviceId"] = $DeviceId }

& "$PSScriptRoot/run-mypractice-device.ps1" @extraArgs
