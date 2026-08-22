param(
    [ValidateSet('Debug', 'Release')]
    [string]$Configuration = 'Debug'
)

$ErrorActionPreference = 'Stop'

function Invoke-Checked {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Command,

        [Parameter(Mandatory = $true)]
        [string[]]$Arguments,

        [Parameter(Mandatory = $true)]
        [string]$FailureMessage
    )

    & $Command @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "$FailureMessage (exit code $LASTEXITCODE)"
    }
}

$repositoryRoot = Split-Path -Parent $PSScriptRoot
$validatorPath = Join-Path $PSScriptRoot 'verify-qspi-image.ps1'

if (-not (Test-Path -LiteralPath $validatorPath -PathType Leaf)) {
    throw "QSPI image validator not found: $validatorPath"
}

$cargo = Get-Command 'cargo' -ErrorAction Stop
$objcopy = Get-Command 'arm-none-eabi-objcopy' -ErrorAction Stop

Push-Location $repositoryRoot
try {
    $metadataOutput = & $cargo.Source 'metadata' '--format-version=1' '--no-deps'
    if ($LASTEXITCODE -ne 0) {
        throw "cargo metadata failed (exit code $LASTEXITCODE)"
    }

    $metadata = $metadataOutput | ConvertFrom-Json
    $profileDirectory = $Configuration.ToLowerInvariant()
    $targetDirectory = [string]$metadata.target_directory
    $cargoArtifactDirectory = Join-Path $targetDirectory "thumbv7em-none-eabihf/$profileDirectory"
    $sourceElf = Join-Path $cargoArtifactDirectory 'ExhValveAct'

    # VS Code consumes stable artifacts from the workspace target directory.
    # Keep that interface stable even when Cargo is configured with an external
    # CARGO_TARGET_DIR.
    $stableArtifactDirectory = Join-Path $repositoryRoot "target/thumbv7em-none-eabihf/$profileDirectory"
    [System.IO.Directory]::CreateDirectory($stableArtifactDirectory) | Out-Null
    $stableElf = Join-Path $stableArtifactDirectory 'ExhValveAct-qspi.elf'
    $binaryPath = Join-Path $stableArtifactDirectory 'ExhValveAct-qspi.bin'

    $cargoArguments = @('build', '--features', 'qspi-boot')
    if ($Configuration -eq 'Release') {
        $cargoArguments += '--release'
    }

    Invoke-Checked -Command $cargo.Source -Arguments $cargoArguments -FailureMessage 'QSPI Cargo build failed'

    if (-not (Test-Path -LiteralPath $sourceElf -PathType Leaf)) {
        throw "Cargo did not produce the expected QSPI ELF: $sourceElf"
    }

    # Cargo uses one package artifact name for both link layouts. Preserve a
    # QSPI-labelled ELF before a subsequent RAM build can replace it.
    Copy-Item -LiteralPath $sourceElf -Destination $stableElf -Force

    Invoke-Checked `
        -Command $objcopy.Source `
        -Arguments @('-O', 'binary', $stableElf, $binaryPath) `
        -FailureMessage 'arm-none-eabi-objcopy failed while creating the raw QSPI image'

    & $validatorPath -ElfPath $stableElf -BinaryPath $binaryPath
    if ($LASTEXITCODE -ne 0) {
        throw "QSPI image validation failed (exit code $LASTEXITCODE)"
    }

    Write-Host "QSPI $Configuration artifacts ready:"
    Write-Host "  ELF: $stableElf"
    Write-Host "  BIN: $binaryPath"
}
finally {
    Pop-Location
}
