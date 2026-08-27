[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$workspaceDirectory = Split-Path -Parent $PSScriptRoot
$testSource = Join-Path $PSScriptRoot 'vd18mt-host-tests.rs'
$outputDirectory = Join-Path $workspaceDirectory 'target/host-tests'
$testExecutable = Join-Path $outputDirectory 'vd18mt-host-tests.exe'

New-Item -ItemType Directory -Path $outputDirectory -Force | Out-Null

& rustc --edition=2021 --test $testSource -o $testExecutable
if ($LASTEXITCODE -ne 0) {
    throw "VD18MT host-test compilation failed (exit code $LASTEXITCODE)"
}

& $testExecutable --test-threads=1
if ($LASTEXITCODE -ne 0) {
    throw "VD18MT host tests failed (exit code $LASTEXITCODE)"
}
