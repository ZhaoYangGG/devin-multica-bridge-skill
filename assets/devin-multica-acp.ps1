param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$Arguments
)

$devin = Join-Path $env:LOCALAPPDATA 'devin\cli\bin\devin.exe'
if (-not (Test-Path $devin)) {
    [Console]::Error.WriteLine("Devin CLI was not found at $devin")
    exit 127
}

if ($Arguments -contains '--version' -or $Arguments -contains '-V') {
    & $devin --version
    exit $LASTEXITCODE
}

$forwardedArguments = @($Arguments | Where-Object { $_ -ne 'acp' -and $_ -ne '--trust-all-tools' })
& $devin acp @forwardedArguments
exit $LASTEXITCODE
