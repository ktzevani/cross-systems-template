$ErrorActionPreference = "Stop"

$VenvRel = ".venv/win64"
$VenvPath = Join-Path $PWD $VenvRel

function Test-VSDeveloperSandbox {
    $hasVsInstall = -not [string]::IsNullOrWhiteSpace($env:VSINSTALLDIR)
    $hasVcTools = -not [string]::IsNullOrWhiteSpace($env:VCToolsInstallDir)
    $hasWindowsSdk = -not [string]::IsNullOrWhiteSpace($env:WindowsSdkDir)
    $hasInclude = -not [string]::IsNullOrWhiteSpace($env:INCLUDE)
    $hasLib = -not [string]::IsNullOrWhiteSpace($env:LIB)

    return ($hasVsInstall -and $hasVcTools -and $hasWindowsSdk -and $hasInclude -and $hasLib)
}

if (-not (Test-VSDeveloperSandbox)) {
    Write-Host "For Windows native development run VS Code from inside a Windows Developer sandbox."
    exit 0
}

if (Test-Path $VenvPath) {
    Write-Host "[startup] Windows uv environment already exists: $VenvRel"
    exit 0
}

Write-Host "[startup] Windows Developer sandbox detected."
Write-Host "[startup] Creating/synchronizing uv environment at: $VenvRel"

$env:UV_PROJECT_ENVIRONMENT = $VenvRel

uv venv $VenvRel --system-site-packages

if ($LASTEXITCODE -ne 0) {
    throw "uv venv failed with exit code $LASTEXITCODE"
}

uv sync --group dev

if ($LASTEXITCODE -ne 0) {
    throw "uv sync failed with exit code $LASTEXITCODE"
}

Write-Host "[startup] uv sync completed."
exit 0
