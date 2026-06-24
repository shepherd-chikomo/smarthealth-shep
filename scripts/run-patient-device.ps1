param([Parameter(ValueFromRemainingArguments = $true)]$Rest)
& "$PSScriptRoot\myhealth\run-patient-device.ps1" @Rest
