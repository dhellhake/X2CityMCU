[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$workspaceDirectory = Split-Path -Parent $PSScriptRoot
$testSource = Join-Path $PSScriptRoot 'brkhdl-host-tests.rs'
$adcTestSource = Join-Path $PSScriptRoot 'adc-host-tests.rs'
$outputDirectory = Join-Path $workspaceDirectory 'target/host-tests'
$testExecutable = Join-Path $outputDirectory 'brkhdl-host-tests.exe'
$adcTestExecutable = Join-Path $outputDirectory 'adc-host-tests.exe'

New-Item -ItemType Directory -Path $outputDirectory -Force | Out-Null

& rustc --edition=2021 --test $testSource -o $testExecutable
if ($LASTEXITCODE -ne 0) {
    throw "Brake-handle host-test compilation failed (exit code $LASTEXITCODE)"
}

& $testExecutable --test-threads=1
if ($LASTEXITCODE -ne 0) {
    throw "Brake-handle host tests failed (exit code $LASTEXITCODE)"
}

& rustc --edition=2021 --test $adcTestSource -o $adcTestExecutable
if ($LASTEXITCODE -ne 0) {
    throw "ADC host-test compilation failed (exit code $LASTEXITCODE)"
}

& $adcTestExecutable --test-threads=1
if ($LASTEXITCODE -ne 0) {
    throw "ADC host tests failed (exit code $LASTEXITCODE)"
}
