[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$validatorPath = Join-Path $PSScriptRoot 'verify-qspi-image.ps1'
if (-not (Test-Path -LiteralPath $validatorPath -PathType Leaf)) {
    throw "Validator not found: $validatorPath"
}

function Set-U16 {
    param(
        [Parameter(Mandatory = $true)]
        [byte[]]$Bytes,

        [Parameter(Mandatory = $true)]
        [int]$Offset,

        [Parameter(Mandatory = $true)]
        [uint64]$Value
    )

    $Bytes[$Offset] = [byte]($Value -band 0xFF)
    $Bytes[$Offset + 1] = [byte](($Value -shr 8) -band 0xFF)
}

function Set-U32 {
    param(
        [Parameter(Mandatory = $true)]
        [byte[]]$Bytes,

        [Parameter(Mandatory = $true)]
        [int]$Offset,

        [Parameter(Mandatory = $true)]
        [uint64]$Value
    )

    $Bytes[$Offset] = [byte]($Value -band 0xFF)
    $Bytes[$Offset + 1] = [byte](($Value -shr 8) -band 0xFF)
    $Bytes[$Offset + 2] = [byte](($Value -shr 16) -band 0xFF)
    $Bytes[$Offset + 3] = [byte](($Value -shr 24) -band 0xFF)
}

function Copy-Bytes {
    param(
        [Parameter(Mandatory = $true)]
        [byte[]]$Bytes
    )

    $copy = [byte[]]::new($Bytes.Length)
    [System.Array]::Copy($Bytes, $copy, $Bytes.Length)
    return ,$copy
}

function New-ValidRawImage {
    $bytes = [byte[]]::new(0x4100)

    # 512-byte FlexSPI NOR Configuration Block at flash offset zero.
    Set-U32 $bytes 0x0000 0x42464346
    Set-U32 $bytes 0x0004 0x56010400
    $bytes[0x000C] = 0              # internal loopback
    $bytes[0x000D] = 3              # CS hold
    $bytes[0x000E] = 3              # CS setup
    $bytes[0x0044] = 1              # Serial NOR
    $bytes[0x0045] = 4              # four pads
    $bytes[0x0046] = 3              # validated 60 MHz enum
    Set-U32 $bytes 0x0050 0x00400000
    Set-U32 $bytes 0x0080 0x0A1804EB # non-empty read LUT
    Set-U32 $bytes 0x0084 0x26043206 # six dummy cycles, quad read
    Set-U32 $bytes 0x01C0 0x00000100
    Set-U32 $bytes 0x01C4 0x00001000
    Set-U32 $bytes 0x01CC 0x00010000

    # Boot ROM IVT at +0x1000, direct-link Boot Data at +0x1020.
    $bytes[0x1000] = 0xD1
    $bytes[0x1001] = 0x00
    $bytes[0x1002] = 0x20
    $bytes[0x1003] = 0x41
    Set-U32 $bytes 0x1004 0x60002000
    Set-U32 $bytes 0x1008 0
    Set-U32 $bytes 0x100C 0
    Set-U32 $bytes 0x1010 0x60001020
    Set-U32 $bytes 0x1014 0x60001000
    Set-U32 $bytes 0x1018 0
    Set-U32 $bytes 0x101C 0

    Set-U32 $bytes 0x1020 0x60000000
    Set-U32 $bytes 0x1024 $bytes.Length
    Set-U32 $bytes 0x1028 0
    Set-U32 $bytes 0x102C 4294967295

    # Flash-resident Cortex vector and a tiny, synthetic Thumb reset stub.
    Set-U32 $bytes 0x2000 0x20280000
    Set-U32 $bytes 0x2004 0x60002401
    foreach ($vectorIndex in @(2, 3, 4, 5, 6, 11, 12, 14, 15)) {
        Set-U32 $bytes (0x2000 + ($vectorIndex * 4)) 0x60002401
    }
    $bytes[0x2400] = 0xFE
    $bytes[0x2401] = 0xE7

    # Relocated ITCM vector/payload and initialized DTCM payload.
    Set-U32 $bytes 0x3000 0x20040000
    Set-U32 $bytes 0x3004 0x60002401
    foreach ($vectorIndex in @(2, 3, 4, 5, 6, 11, 12, 14, 15)) {
        Set-U32 $bytes (0x3000 + ($vectorIndex * 4)) 0x00000401
    }
    foreach ($vectorIndex in 16..173) {
        Set-U32 $bytes (0x3000 + ($vectorIndex * 4)) 0x00000401
    }
    $bytes[0x3400] = 0xFE
    $bytes[0x3401] = 0xE7
    for ($index = 0; $index -lt 0x100; $index++) {
        $bytes[0x4000 + $index] = [byte]($index -band 0xFF)
    }

    return ,$bytes
}

function Set-ProgramHeader {
    param(
        [Parameter(Mandatory = $true)]
        [byte[]]$Elf,

        [Parameter(Mandatory = $true)]
        [int]$Index,

        [Parameter(Mandatory = $true)]
        [uint64]$FileOffset,

        [Parameter(Mandatory = $true)]
        [uint64]$VirtualAddress,

        [Parameter(Mandatory = $true)]
        [uint64]$PhysicalAddress,

        [Parameter(Mandatory = $true)]
        [uint64]$FileSize,

        [Parameter(Mandatory = $true)]
        [uint64]$MemorySize,

        [Parameter(Mandatory = $true)]
        [uint64]$Flags
    )

    $offset = 52 + ($Index * 32)
    Set-U32 $Elf ($offset + 0) 1
    Set-U32 $Elf ($offset + 4) $FileOffset
    Set-U32 $Elf ($offset + 8) $VirtualAddress
    Set-U32 $Elf ($offset + 12) $PhysicalAddress
    Set-U32 $Elf ($offset + 16) $FileSize
    Set-U32 $Elf ($offset + 20) $MemorySize
    Set-U32 $Elf ($offset + 24) $Flags
    Set-U32 $Elf ($offset + 28) 0x1000
}

function New-ValidElf {
    param(
        [Parameter(Mandatory = $true)]
        [byte[]]$RawImage
    )

    $elf = [byte[]]::new(0x5100)
    $elf[0] = 0x7F
    $elf[1] = 0x45
    $elf[2] = 0x4C
    $elf[3] = 0x46
    $elf[4] = 1  # ELFCLASS32
    $elf[5] = 1  # little endian
    $elf[6] = 1  # EV_CURRENT

    Set-U16 $elf 16 2             # ET_EXEC
    Set-U16 $elf 18 40            # EM_ARM
    Set-U32 $elf 20 1             # EV_CURRENT
    Set-U32 $elf 24 0x60002400    # Reset entry
    Set-U32 $elf 28 52            # e_phoff
    Set-U32 $elf 32 0             # no section table needed by validator
    Set-U32 $elf 36 0x05000200    # EABI5, soft-float-compatible fixture
    Set-U16 $elf 40 52
    Set-U16 $elf 42 32
    Set-U16 $elf 44 4
    Set-U16 $elf 46 40
    Set-U16 $elf 48 0
    Set-U16 $elf 50 0

    Set-ProgramHeader $elf 0 0x1000 0x60000000 0x60000000 0x3000 0x3000 5
    Set-ProgramHeader $elf 1 0x4000 0x00000000 0x60003000 0x0400 0x0400 5
    Set-ProgramHeader $elf 2 0x4400 0x00000400 0x60003400 0x0400 0x0400 5
    Set-ProgramHeader $elf 3 0x5000 0x20000000 0x60004000 0x0100 0x0200 6

    [System.Array]::Copy($RawImage, 0x0000, $elf, 0x1000, 0x3000)
    [System.Array]::Copy($RawImage, 0x3000, $elf, 0x4000, 0x0800)
    [System.Array]::Copy($RawImage, 0x4000, $elf, 0x5000, 0x0100)
    return ,$elf
}

function Write-Fixture {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name,

        [Parameter(Mandatory = $true)]
        [byte[]]$Bytes
    )

    $path = Join-Path $script:temporaryDirectory $Name
    [System.IO.File]::WriteAllBytes($path, $Bytes)
    return $path
}

$script:passed = 0
$script:failed = 0

function Assert-Passes {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name,

        [Parameter(Mandatory = $true)]
        [hashtable]$Arguments
    )

    try {
        & $script:validatorPath @Arguments *> $null
        Write-Host "PASS: $Name"
        $script:passed++
    } catch {
        Write-Host "FAIL: $Name -- $($_.Exception.Message)"
        $script:failed++
    }
}

function Assert-Fails {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name,

        [Parameter(Mandatory = $true)]
        [hashtable]$Arguments,

        [Parameter(Mandatory = $true)]
        [string]$MessagePattern
    )

    try {
        & $script:validatorPath @Arguments *> $null
        Write-Host "FAIL: $Name -- validator unexpectedly accepted the fixture"
        $script:failed++
    } catch {
        if ($_.Exception.Message -notmatch $MessagePattern) {
            Write-Host "FAIL: $Name -- unexpected error: $($_.Exception.Message)"
            $script:failed++
            return
        }
        Write-Host "PASS: $Name"
        $script:passed++
    }
}

$tempRoot = [System.IO.Path]::GetFullPath([System.IO.Path]::GetTempPath())
$script:temporaryDirectory = Join-Path $tempRoot ('X2CityMCU-qspi-validator-' + [guid]::NewGuid().ToString('N'))
[void](New-Item -ItemType Directory -Path $temporaryDirectory)

try {
    $validRaw = New-ValidRawImage
    $validElf = New-ValidElf $validRaw
    $validRawPath = Write-Fixture 'valid.bin' $validRaw
    $validElfPath = Write-Fixture 'valid.elf' $validElf

    Assert-Passes 'valid raw image' @{ BinaryPath = $validRawPath }
    Assert-Passes 'valid ELF image' @{ ElfPath = $validElfPath }
    Assert-Passes 'matching ELF and raw image' @{ ElfPath = $validElfPath; BinaryPath = $validRawPath }

    $itcmResetRaw = Copy-Bytes $validRaw
    Set-U32 $itcmResetRaw 0x3004 0x00000401
    $itcmResetElf = New-ValidElf $itcmResetRaw
    $itcmResetElfPath = Write-Fixture 'itcm-reset.elf' $itcmResetElf
    Assert-Passes 'allows an alternate relocated Reset handler in ITCM' @{ ElfPath = $itcmResetElfPath }

    $badTag = Copy-Bytes $validRaw
    Set-U32 $badTag 0 3735928559
    $badTagPath = Write-Fixture 'bad-fcb-tag.bin' $badTag
    Assert-Fails 'rejects an invalid FCB tag' @{ BinaryPath = $badTagPath } 'FCB tag is invalid'

    $badCapacity = Copy-Bytes $validRaw
    Set-U32 $badCapacity 0x50 0x00800000
    $badCapacityPath = Write-Fixture 'bad-capacity.bin' $badCapacity
    Assert-Fails 'rejects FCB capacity mismatch' @{ BinaryPath = $badCapacityPath } 'sflashA1Size does not match'

    $truncatedReadLut = Copy-Bytes $validRaw
    Set-U32 $truncatedReadLut 0x84 0
    $truncatedReadLutPath = Write-Fixture 'truncated-read-lut.bin' $truncatedReadLut
    Assert-Fails 'rejects a truncated quad-read LUT' @{ BinaryPath = $truncatedReadLutPath } 'FCB read LUT must encode'

    $badSelf = Copy-Bytes $validRaw
    Set-U32 $badSelf 0x1014 0x60001004
    $badSelfPath = Write-Fixture 'bad-ivt-self.bin' $badSelf
    Assert-Fails 'rejects an invalid IVT self pointer' @{ BinaryPath = $badSelfPath } 'IVT self pointer is invalid'

    $badThumb = Copy-Bytes $validRaw
    Set-U32 $badThumb 0x2004 0x60002400
    $badThumbPath = Write-Fixture 'bad-thumb.bin' $badThumb
    Assert-Fails 'rejects a non-Thumb reset vector' @{ BinaryPath = $badThumbPath } 'Thumb bit'

    $badBootstrapFault = Copy-Bytes $validRaw
    Set-U32 $badBootstrapFault 0x2008 0
    $badBootstrapFaultPath = Write-Fixture 'bad-bootstrap-fault.bin' $badBootstrapFault
    Assert-Fails 'rejects a missing bootstrap fault handler' `
        @{ BinaryPath = $badBootstrapFaultPath } `
        'Bootstrap handler vector 2 does not have the Thumb bit set'

    $configurableOcramSp = Copy-Bytes $validRaw
    Set-U32 $configurableOcramSp 0x2000 0x20280008
    $configurableOcramSpPath = Write-Fixture 'configurable-ocram-sp.bin' $configurableOcramSp
    Assert-Fails 'rejects a bootstrap SP in configurable OCRAM' `
        @{ BinaryPath = $configurableOcramSpPath } `
        'not valid at Boot ROM handoff'

    $shortBootData = Copy-Bytes $validRaw
    Set-U32 $shortBootData 0x1024 0x3000
    $shortBootDataPath = Write-Fixture 'short-boot-data.bin' $shortBootData
    Assert-Fails 'rejects Boot Data shorter than the programmed image' @{ BinaryPath = $shortBootDataPath } 'does not cover the complete programmed image'

    $mismatchedRaw = Copy-Bytes $validRaw
    $mismatchedRaw[0x4000] = $mismatchedRaw[0x4000] -bxor 0xFF
    $mismatchedRawPath = Write-Fixture 'elf-raw-mismatch.bin' $mismatchedRaw
    Assert-Fails 'rejects an ELF/raw content mismatch' @{ ElfPath = $validElfPath; BinaryPath = $mismatchedRawPath } 'Raw/ELF byte mismatch'

    $mismatchedGapRaw = Copy-Bytes $validRaw
    $mismatchedGapRaw[0x3900] = 0xA5
    $mismatchedGapRawPath = Write-Fixture 'elf-gap-mismatch.bin' $mismatchedGapRaw
    Assert-Fails 'rejects nonzero data in an ELF LOAD gap' `
        @{ ElfPath = $validElfPath; BinaryPath = $mismatchedGapRawPath } `
        'Raw byte in ELF LOAD gap'

    $trailingRaw = [byte[]]::new($validRaw.Length + 1)
    [System.Array]::Copy($validRaw, $trailingRaw, $validRaw.Length)
    $trailingRawPath = Write-Fixture 'elf-extra-trailing-byte.bin' $trailingRaw
    Assert-Fails 'rejects raw bytes beyond the ELF LOAD span' `
        @{ ElfPath = $validElfPath; BinaryPath = $trailingRawPath } `
        'Raw image length does not match'

    $overflowElf = Copy-Bytes $validElf
    Set-U32 $overflowElf (52 + (2 * 32) + 20) 0x0003FC01
    $overflowElfPath = Write-Fixture 'itcm-overflow.elf' $overflowElf
    Assert-Fails 'rejects ITCM geometry beyond 256 KiB' @{ ElfPath = $overflowElfPath } 'outside FlexSPI1, 256-KiB ITCM/DTCM, and OCRAM'

    $outOfFlashElf = Copy-Bytes $validElf
    Set-U32 $outOfFlashElf (52 + (3 * 32) + 12) 0x60400000
    $outOfFlashElfPath = Write-Fixture 'load-out-of-flash.elf' $outOfFlashElf
    Assert-Fails 'rejects a relocation LMA outside 4 MiB flash' @{ ElfPath = $outOfFlashElfPath } 'outside FlexSPI1 flash'

    $discontiguousItcmElf = Copy-Bytes $validElf
    Set-U32 $discontiguousItcmElf (52 + (2 * 32) + 12) 0x60003500
    $discontiguousItcmElfPath = Write-Fixture 'discontiguous-itcm-lma.elf' $discontiguousItcmElf
    Assert-Fails 'rejects a discontiguous ITCM LMA/VMA mapping' @{ ElfPath = $discontiguousItcmElfPath } 'ITCM LOAD segments do not use one contiguous LMA/VMA mapping'

    $badRuntimeVector = Copy-Bytes $validRaw
    Set-U32 $badRuntimeVector 0x3008 0x00000400
    $badRuntimeElf = New-ValidElf $badRuntimeVector
    $badRuntimeElfPath = Write-Fixture 'bad-runtime-vector.elf' $badRuntimeElf
    Assert-Fails 'rejects a non-Thumb relocated ITCM vector' @{ ElfPath = $badRuntimeElfPath } 'ITCM vector NMI does not have the Thumb bit set'

    $badReservedVector = Copy-Bytes $validRaw
    Set-U32 $badReservedVector (0x3000 + (7 * 4)) 1
    $badReservedElf = New-ValidElf $badReservedVector
    $badReservedElfPath = Write-Fixture 'bad-reserved-vector.elf' $badReservedElf
    Assert-Fails 'rejects a populated reserved Cortex vector' @{ ElfPath = $badReservedElfPath } 'reserved vector 7 must be zero'

    $badExternalVector = Copy-Bytes $validRaw
    Set-U32 $badExternalVector (0x3000 + (16 * 4)) 0x60002401
    $badExternalElf = New-ValidElf $badExternalVector
    $badExternalElfPath = Write-Fixture 'bad-external-vector.elf' $badExternalElf
    Assert-Fails 'rejects an external IRQ handler outside ITCM' @{ ElfPath = $badExternalElfPath } 'ITCM vector IRQ0 is not covered exactly once'

    Assert-Fails 'rejects a configured flash size below the image minimum' `
        @{ BinaryPath = $validRawPath; FlashSizeBytes = [uint64]0x2000 } `
        'FlashSizeBytes must be between'

    Assert-Fails 'rejects flash capacity beyond the 24-bit read LUT' `
        @{ BinaryPath = $validRawPath; FlashSizeBytes = [uint64]0x02000000 } `
        'FlashSizeBytes must be between'

    Assert-Fails 'rejects a configured flash size beyond the 32-bit window' `
        @{ BinaryPath = $validRawPath; FlashSizeBytes = [uint64]4294967296 } `
        'FlashSizeBytes must be between'
} finally {
    $resolvedTemporaryDirectory = [System.IO.Path]::GetFullPath($temporaryDirectory)
    $expectedParent = [System.IO.Path]::GetFullPath((Split-Path -Parent $resolvedTemporaryDirectory))
    $leafName = Split-Path -Leaf $resolvedTemporaryDirectory
    if (($expectedParent -ne $tempRoot.TrimEnd([System.IO.Path]::DirectorySeparatorChar)) -or
        (-not $leafName.StartsWith('X2CityMCU-qspi-validator-', [System.StringComparison]::Ordinal))) {
        throw "Refusing to remove unexpected test directory: $resolvedTemporaryDirectory"
    }
    Remove-Item -LiteralPath $resolvedTemporaryDirectory -Recurse -Force
}

Write-Host ('QSPI validator self-tests: {0} passed, {1} failed' -f $passed, $failed)
if ($failed -ne 0) {
    throw "$failed QSPI validator self-test(s) failed"
}
