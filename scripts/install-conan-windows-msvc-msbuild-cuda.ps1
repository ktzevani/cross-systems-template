param(
    [string[]] $Configurations = @(
        "Debug",
        "Release",
        "RelWithDebInfo",
        "MinSizeRel"
    )
)

$ErrorActionPreference = "Stop"

$ProjectRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$Profile = Join-Path $ProjectRoot "profiles/windows-msvc-msbuild-cuda"
$OutputFolder = Join-Path $ProjectRoot "out/conan/windows-msvc-msbuild-cuda"

foreach ($Config in $Configurations) {
    $RuntimeType = if ($Config -eq "Debug") { "Debug" } else { "Release" }

    Write-Host "[conan] Installing Windows MSVC/MSBuild CUDA dependencies for $Config"

    & uv run --active conan install $ProjectRoot `
        --profile:host $Profile `
        --profile:build $Profile `
        --settings:host "build_type=$Config" `
        --settings:host "compiler.runtime_type=$RuntimeType" `
        --settings:build "build_type=$Config" `
        --settings:build "compiler.runtime_type=$RuntimeType" `
        --build=missing `
        -of $OutputFolder

    if ($LASTEXITCODE -ne 0) {
        throw "conan install failed for $Config with exit code $LASTEXITCODE"
    }
}

Write-Host "[conan] Windows MSVC/MSBuild CUDA dependency metadata is ready: $OutputFolder"
