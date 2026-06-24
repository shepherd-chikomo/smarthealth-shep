param([Parameter(ValueFromRemainingArguments = $true)]$Rest)
& "$PSScriptRoot\myhealth\run-patient-remote.ps1" @Rest
