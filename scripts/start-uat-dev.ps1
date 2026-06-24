param([Parameter(ValueFromRemainingArguments = $true)]$Rest)
& "$PSScriptRoot\platform\start-uat-dev.ps1" @Rest
