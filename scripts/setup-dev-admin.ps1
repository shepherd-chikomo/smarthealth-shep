param([Parameter(ValueFromRemainingArguments = $true)]$Rest)
& "$PSScriptRoot\platform\setup-dev-admin.ps1" @Rest
