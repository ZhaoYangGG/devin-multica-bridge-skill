$ErrorActionPreference = 'Stop'

$source = Join-Path $PSScriptRoot 'assets\devin-multica-acp.ps1'
$destinationDirectory = Join-Path $env:LOCALAPPDATA 'devin\cli'
$destination = Join-Path $destinationDirectory 'devin-multica-acp.ps1'
$devin = Join-Path $env:LOCALAPPDATA 'devin\cli\bin\devin.exe'

if (-not (Test-Path $devin)) {
    throw "Devin CLI was not found at $devin"
}

New-Item -ItemType Directory -Path $destinationDirectory -Force | Out-Null
Copy-Item -Path $source -Destination $destination -Force

$version = & powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File $destination acp --trust-all-tools --version
if ($LASTEXITCODE -ne 0) {
    throw 'The Multica wrapper smoke test failed.'
}

$multicaPath = $destination -replace '\\', '/'
Write-Output "Installed wrapper: $destination"
Write-Output "Devin version: $version"
Write-Output 'Multica protocol family: Kiro'
Write-Output "Multica command: powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File $multicaPath"
