[CmdletBinding()]
param(
    [string]$OutputDirectory
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

function Assert-Sha256 {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $true)]
        [string]$ExpectedHash,

        [Parameter(Mandatory = $true)]
        [string]$Description
    )

    $actualHash = (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash
    if ($actualHash -ne $ExpectedHash) {
        throw "$Description SHA-256 mismatch: expected $ExpectedHash, found $actualHash"
    }
}

function Expand-ZipEntry {
    param(
        [Parameter(Mandatory = $true)]
        [System.IO.Compression.ZipArchive]$Archive,

        [Parameter(Mandatory = $true)]
        [string]$EntryName,

        [Parameter(Mandatory = $true)]
        [string]$DestinationPath
    )

    $entry = $Archive.GetEntry($EntryName)
    if ($null -eq $entry) {
        throw "Required CMSIS pack entry not found: $EntryName"
    }

    $inputStream = $entry.Open()
    try {
        $outputStream = [System.IO.File]::Create($DestinationPath)
        try {
            $inputStream.CopyTo($outputStream)
        }
        finally {
            $outputStream.Dispose()
        }
    }
    finally {
        $inputStream.Dispose()
    }
}

$repositoryRoot = Split-Path -Parent $PSScriptRoot
if ([string]::IsNullOrWhiteSpace($OutputDirectory)) {
    $OutputDirectory = Join-Path $repositoryRoot 'target/qspi-tools'
}

$packVersion = '26.06.00'
$packUri = "https://mcuxpresso.nxp.com/cmsis_pack/repo/NXP.MIMXRT1061_DFP.$packVersion.pack"
$packHash = '4C207E1470CD565691F059441E21C365C4E1CD983ECA173B7EAB2087FCEBF019'
$flmEntry = 'devices/MIMXRT1061/arm/MIMXRT106x_QSPI_4KB_SEC.FLM'
$flmHash = '495D2291FC61C5D5B71E2A5ACC1386B01ADAB643DF823098F68BFACED3A50DC9'

$resolvedOutputDirectory = [System.IO.Path]::GetFullPath($OutputDirectory)
[System.IO.Directory]::CreateDirectory($resolvedOutputDirectory) | Out-Null

$packPath = Join-Path $resolvedOutputDirectory "NXP.MIMXRT1061_DFP.$packVersion.pack"
$flmPath = Join-Path $resolvedOutputDirectory 'MIMXRT106x_QSPI_4KB_SEC.FLM'
$payloadPath = Join-Path $resolvedOutputDirectory 'MIMXRT106x_QSPI_4KB_SEC.payload.bin'
$algorithmPath = Join-Path $resolvedOutputDirectory 'MIMXRT106x_QSPI_4KB_SEC.openocd.bin'
$manifestPath = Join-Path $resolvedOutputDirectory 'SOURCE.txt'

if (-not (Test-Path -LiteralPath $packPath -PathType Leaf)) {
    Write-Host "Downloading the pinned NXP MIMXRT1061 device pack $packVersion ..."
    Invoke-WebRequest -Uri $packUri -OutFile $packPath -UseBasicParsing
}
Assert-Sha256 $packPath $packHash 'NXP MIMXRT1061 device pack'

Add-Type -AssemblyName System.IO.Compression.FileSystem
$archive = [System.IO.Compression.ZipFile]::OpenRead($packPath)
try {
    Expand-ZipEntry $archive $flmEntry $flmPath

    # Preserve the pack description beside the extracted algorithm so its
    # origin and license metadata remain locally inspectable.
    $pdscEntry = @($archive.Entries | Where-Object { $_.FullName -like '*.pdsc' })
    if ($pdscEntry.Count -eq 1) {
        Expand-ZipEntry $archive $pdscEntry[0].FullName (Join-Path $resolvedOutputDirectory $pdscEntry[0].Name)
    }
}
finally {
    $archive.Dispose()
}
Assert-Sha256 $flmPath $flmHash 'NXP MIMXRT1061 QSPI flash algorithm'

$objcopy = Get-Command 'arm-none-eabi-objcopy' -ErrorAction Stop
Invoke-Checked `
    -Command $objcopy.Source `
    -Arguments @('-O', 'binary', '--only-section=PrgCode', '--only-section=PrgData', $flmPath, $payloadPath) `
    -FailureMessage 'Could not extract the loadable code/data from the NXP FLM'

$payload = [System.IO.File]::ReadAllBytes($payloadPath)
if ($payload.Length -ne 0x380) {
    throw ('Unexpected NXP FLM payload size: expected 0x380, found 0x{0:x}' -f $payload.Length)
}

# The FLM returns through LR. Prefix its image with a two-instruction return
# trap (BKPT; B .) and shift every documented entry/static address by 4 bytes.
$returnTrap = [byte[]](0x00, 0xBE, 0xFE, 0xE7)
$algorithm = [byte[]]::new($returnTrap.Length + $payload.Length)
[System.Array]::Copy($returnTrap, 0, $algorithm, 0, $returnTrap.Length)
[System.Array]::Copy($payload, 0, $algorithm, $returnTrap.Length, $payload.Length)
[System.IO.File]::WriteAllBytes($algorithmPath, $algorithm)

$manifest = @(
    "NXP CMSIS device pack: $packUri"
    "Pack version: $packVersion"
    "Pack SHA-256: $packHash"
    "Pack entry: $flmEntry"
    "FLM SHA-256: $flmHash"
    'OpenOCD wrapper prefix: 00 BE FE E7 (BKPT; B .)'
)
[System.IO.File]::WriteAllLines($manifestPath, $manifest)

Write-Host "Pinned NXP QSPI algorithm ready: $algorithmPath"
