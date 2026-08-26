[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$workspaceDirectory = Split-Path -Parent $PSScriptRoot
$testSource = Join-Path $PSScriptRoot 'program-flow-host-tests.rs'
$rtwdogTestSource = Join-Path $PSScriptRoot 'rtwdog-host-tests.rs'
$outputDirectory = Join-Path $workspaceDirectory 'target/host-tests'
$testExecutable = Join-Path $outputDirectory 'program-flow-host-tests.exe'
$rtwdogTestExecutable = Join-Path $outputDirectory 'rtwdog-host-tests.exe'

New-Item -ItemType Directory -Path $outputDirectory -Force | Out-Null

& rustc --edition=2021 --test $testSource -o $testExecutable
if ($LASTEXITCODE -ne 0) {
    throw "Program-flow host-test compilation failed (exit code $LASTEXITCODE)"
}

& $testExecutable --test-threads=1
if ($LASTEXITCODE -ne 0) {
    throw "Program-flow host tests failed (exit code $LASTEXITCODE)"
}

& rustc --edition=2021 --test $rtwdogTestSource -o $rtwdogTestExecutable
if ($LASTEXITCODE -ne 0) {
    throw "RTWDOG host-test compilation failed (exit code $LASTEXITCODE)"
}

& $rtwdogTestExecutable --test-threads=1
if ($LASTEXITCODE -ne 0) {
    throw "RTWDOG host tests failed (exit code $LASTEXITCODE)"
}
