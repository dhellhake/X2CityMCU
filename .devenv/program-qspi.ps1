[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ElfPath,

    [Parameter(Mandatory = $true)]
    [string]$BinaryPath,

    [string]$ProbeSerial,

    [ValidateRange(50, 5000)]
    [int]$AdapterSpeedKHz = 100,

    [string]$BackupPath,

    [switch]$SkipBackup,

    [switch]$NoReset,

    [switch]$DryRun,

    [string]$OpenOcdPath
)

$ErrorActionPreference = 'Stop'

function ConvertTo-TclBracedPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    $fullPath = [System.IO.Path]::GetFullPath($Path).Replace('\', '/')
    if (($fullPath.Contains('{')) -or ($fullPath.Contains('}'))) {
        throw "OpenOCD paths containing braces are not supported: $fullPath"
    }
    return $fullPath
}

function Invoke-QspiFailureContainment {
    param(
        [Parameter(Mandatory = $true)]
        [string]$OpenOcdExecutable,

        [Parameter(Mandatory = $true)]
        [string[]]$Arguments
    )

    Write-Warning 'QSPI programming did not complete. Reconnecting to halt the target and verify the masked RTWDOG reset route.'
    & $OpenOcdExecutable @Arguments
    if ($LASTEXITCODE -ne 0) {
        Write-Warning 'Could not prove failure containment. Keep the target isolated and pulse POR_B before any further execution.'
        return
    }

    Write-Warning 'Failure contained: target is halted with the RTWDOG reset route masked. Do not resume the flash-loader context; enter a verified image through Reset() or pulse POR_B.'
}

$repositoryRoot = Split-Path -Parent $PSScriptRoot
$validatorPath = Join-Path $PSScriptRoot 'verify-qspi-image.ps1'
$setupPath = Join-Path $PSScriptRoot 'setup-qspi-flm.ps1'
$targetConfigPath = Join-Path $PSScriptRoot 'openocd/atmel-ice-mimxrt1061.cfg'
$programScriptPath = Join-Path $PSScriptRoot 'openocd/program-qspi.tcl'

foreach ($requiredPath in @($validatorPath, $setupPath, $targetConfigPath, $programScriptPath)) {
    if (-not (Test-Path -LiteralPath $requiredPath -PathType Leaf)) {
        throw "Required QSPI programming component not found: $requiredPath"
    }
}

if (-not (Test-Path -LiteralPath $ElfPath -PathType Leaf)) {
    throw "QSPI ELF not found: $ElfPath"
}
if (-not (Test-Path -LiteralPath $BinaryPath -PathType Leaf)) {
    throw "QSPI binary not found: $BinaryPath"
}

$resolvedElfPath = (Resolve-Path -LiteralPath $ElfPath).Path
$resolvedBinaryPath = (Resolve-Path -LiteralPath $BinaryPath).Path

$programDirectory = Join-Path $repositoryRoot 'target/qspi-program'
[System.IO.Directory]::CreateDirectory($programDirectory) | Out-Null
$validatedImagePath = Join-Path $programDirectory 'ExhValveAct-qspi-validated.bin'

# Take the programming input snapshot before validation. The exact bytes that
# pass validation are then padded and programmed, even if another process
# replaces the original Cargo artifact while this command is running.
$sourceBytes = [System.IO.File]::ReadAllBytes($resolvedBinaryPath)
[System.IO.File]::WriteAllBytes($validatedImagePath, $sourceBytes)
& $validatorPath -ElfPath $resolvedElfPath -BinaryPath $validatedImagePath

$flashCapacity = [uint64](4 * 1024 * 1024)
$sectorSize = [uint64]4096
$pageSize = [uint64]256
$binaryLength = [uint64]$sourceBytes.LongLength
if (($binaryLength -eq 0) -or ($binaryLength -gt $flashCapacity)) {
    throw "QSPI image size must be between 1 byte and 4 MiB; found $binaryLength bytes"
}

$paddedLength = [uint64]([Math]::Ceiling($binaryLength / [double]$pageSize) * $pageSize)
$eraseLength = [uint64]([Math]::Ceiling($paddedLength / [double]$sectorSize) * $sectorSize)

$paddedImagePath = Join-Path $programDirectory 'ExhValveAct-qspi-padded.bin'
$readbackPath = Join-Path $programDirectory 'ExhValveAct-qspi-readback.bin'

$paddedBytes = [byte[]]::new([int]$paddedLength)
for ($index = 0; $index -lt $paddedBytes.Length; $index++) {
    $paddedBytes[$index] = 0xFF
}
[System.Array]::Copy($sourceBytes, $paddedBytes, $sourceBytes.Length)
[System.IO.File]::WriteAllBytes($paddedImagePath, $paddedBytes)

# Verify the complete erased prefix, including the sector tail that is not
# passed to ProgramPage. Any non-0xFF byte there means erase verification must
# fail before POR_B is allowed to start the image.
$expectedReadbackBytes = [byte[]]::new([int]$eraseLength)
for ($index = 0; $index -lt $expectedReadbackBytes.Length; $index++) {
    $expectedReadbackBytes[$index] = 0xFF
}
[System.Array]::Copy($paddedBytes, $expectedReadbackBytes, $paddedBytes.Length)
[System.IO.File]::Delete($readbackPath)

$resolvedBackupPath = ''
if (-not $SkipBackup) {
    if ([string]::IsNullOrWhiteSpace($BackupPath)) {
        $backupDirectory = Join-Path $repositoryRoot 'target/qspi-backups'
        [System.IO.Directory]::CreateDirectory($backupDirectory) | Out-Null
        $timestamp = Get-Date -Format 'yyyyMMdd-HHmmss-fff'
        $BackupPath = Join-Path $backupDirectory ("qspi-prefix-$timestamp-0x{0:x}.bin" -f $eraseLength)
    }
    else {
        $backupParent = Split-Path -Parent ([System.IO.Path]::GetFullPath($BackupPath))
        if (-not [string]::IsNullOrWhiteSpace($backupParent)) {
            [System.IO.Directory]::CreateDirectory($backupParent) | Out-Null
        }
    }
    $resolvedBackupPath = [System.IO.Path]::GetFullPath($BackupPath)
    if (Test-Path -LiteralPath $resolvedBackupPath) {
        throw "Refusing to overwrite an existing QSPI backup: $resolvedBackupPath"
    }
}

$toolDirectory = Join-Path $repositoryRoot 'target/qspi-tools'
& $setupPath -OutputDirectory $toolDirectory
$algorithmPath = Join-Path $toolDirectory 'MIMXRT106x_QSPI_4KB_SEC.openocd.bin'
if (-not (Test-Path -LiteralPath $algorithmPath -PathType Leaf)) {
    throw "Prepared NXP flash algorithm not found: $algorithmPath"
}

if ([string]::IsNullOrWhiteSpace($OpenOcdPath)) {
    $openOcd = Get-Command 'openocd' -ErrorAction Stop
    $OpenOcdPath = $openOcd.Source
}
elseif (-not (Test-Path -LiteralPath $OpenOcdPath -PathType Leaf)) {
    throw "OpenOCD executable not found: $OpenOcdPath"
}

$openOcdArguments = @(
    '-c', "set X2_PROBE_SERIAL {$ProbeSerial}"
    '-c', "set X2_ADAPTER_SPEED_KHZ $AdapterSpeedKHz"
    '-c', "set X2_IMAGE {$(ConvertTo-TclBracedPath $paddedImagePath)}"
    '-c', "set X2_ALGORITHM {$(ConvertTo-TclBracedPath $algorithmPath)}"
    '-c', "set X2_IMAGE_LENGTH $paddedLength"
    '-c', "set X2_ERASE_LENGTH $eraseLength"
    '-c', "set X2_BACKUP {$(if ($resolvedBackupPath) { ConvertTo-TclBracedPath $resolvedBackupPath } else { '' })}"
    '-c', "set X2_READBACK {$(ConvertTo-TclBracedPath $readbackPath)}"
    '-f', $targetConfigPath
    '-f', $programScriptPath
)

$failureContainmentArguments = @(
    '-c', "set X2_PROBE_SERIAL {$ProbeSerial}"
    '-c', "set X2_ADAPTER_SPEED_KHZ $AdapterSpeedKHz"
    '-f', $targetConfigPath
    '-c', 'init'
    '-c', 'halt'
    '-c', 'wait_halt 5000'
    '-c', 'set x2_source_control [lindex [read_memory 0x400f8000 32 1] 0]'
    '-c', 'if {(($x2_source_control >> 28) & 0xf) != 0x5} { error [format "RTWDOG reset route is not masked: SRC.SCR=0x%08x" $x2_source_control] }'
    '-c', 'shutdown'
)

Write-Host ('QSPI program plan: source=0x{0:x}, padded=0x{1:x}, erase=0x{2:x}' -f $binaryLength, $paddedLength, $eraseLength)
if ($resolvedBackupPath) {
    Write-Host "Pre-erase backup: $resolvedBackupPath"
}
else {
    Write-Warning 'Pre-erase QSPI backup explicitly disabled.'
}

if ($DryRun) {
    Write-Host "Dry run complete; no probe was opened and no flash was changed."
    Write-Host "OpenOCD: $OpenOcdPath"
    exit 0
}

try {
    & $OpenOcdPath @openOcdArguments
    if ($LASTEXITCODE -ne 0) {
        throw "OpenOCD QSPI programming failed (exit code $LASTEXITCODE)"
    }

    if (-not (Test-Path -LiteralPath $readbackPath -PathType Leaf)) {
        throw "OpenOCD did not produce the required QSPI read-back: $readbackPath"
    }

    $readbackBytes = [System.IO.File]::ReadAllBytes($readbackPath)
    if ($readbackBytes.Length -ne $expectedReadbackBytes.Length) {
        throw "QSPI read-back length mismatch: expected $($expectedReadbackBytes.Length), found $($readbackBytes.Length)"
    }
    for ($index = 0; $index -lt $expectedReadbackBytes.Length; $index++) {
        if ($readbackBytes[$index] -ne $expectedReadbackBytes[$index]) {
            throw ('QSPI read-back mismatch at flash +0x{0:x}: expected 0x{1:x2}, found 0x{2:x2}' -f `
                $index,
                $expectedReadbackBytes[$index],
                $readbackBytes[$index])
        }
    }
}
catch {
    Invoke-QspiFailureContainment -OpenOcdExecutable $OpenOcdPath -Arguments $failureContainmentArguments
    throw
}

Write-Host "QSPI programming and full erased-prefix read-back verification succeeded."
if ($resolvedBackupPath) {
    Write-Host "Previous flash prefix retained at: $resolvedBackupPath"
}

if (-not $NoReset) {
    # A POR makes Boot ROM re-latch BOOT_MODE and exercise the real FlexSPI
    # boot path. Disable OpenOCD polling before asserting POR_B because the
    # RT1061 debug port is intentionally unavailable during power-on reset.
    $resetArguments = @(
        '-c', "set X2_PROBE_SERIAL {$ProbeSerial}"
        '-c', "set X2_ADAPTER_SPEED_KHZ $AdapterSpeedKHz"
        '-f', $targetConfigPath
        '-c', 'init'
        '-c', 'poll off'
        '-c', 'adapter assert srst'
        '-c', 'sleep 100'
        '-c', 'adapter deassert srst'
        '-c', 'shutdown'
    )

    & $OpenOcdPath @resetArguments
    if ($LASTEXITCODE -ne 0) {
        throw "QSPI image verified, but the POR_B pulse failed (OpenOCD exit code $LASTEXITCODE)"
    }
    Write-Host 'POR_B pulsed; Boot ROM is starting the verified QSPI image.'
}
else {
    Write-Warning 'Target remains halted with the RTWDOG reset route masked; enter the verified image through Reset() or pulse POR_B instead of resuming the flash-loader context.'
}
