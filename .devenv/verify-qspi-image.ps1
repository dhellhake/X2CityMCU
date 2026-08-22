[CmdletBinding()]
param(
    [Parameter()]
    [string]$ElfPath,

    [Parameter()]
    [string]$BinaryPath,

    [Parameter()]
    [uint64]$FlashSizeBytes = 0x00400000
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$flashBase = [uint64]0x60000000
$fcbSize = [uint64]0x200
$ivtAddress = $flashBase + 0x1000
$bootDataAddress = $flashBase + 0x1020
$applicationVectorAddress = $flashBase + 0x2000
$expectedFcbTag = [uint64]0x42464346
$expectedFcbVersion = [uint64]0x56010400

$itcmStart = [uint64]0x00000000
$itcmEnd = [uint64]0x00040000
$dtcmStart = [uint64]0x20000000
$dtcmEnd = [uint64]0x20040000
$romDefaultDtcmEnd = [uint64]0x20020000
$ocramStart = [uint64]0x20200000
$ocramEnd = [uint64]0x20280000
$thumbAddressMask = [uint64]4294967294

function Format-AddressHex {
    param(
        [Parameter(Mandatory = $true)]
        [uint64]$Value,

        [Parameter()]
        [int]$Width = 8
    )

    return '0x' + $Value.ToString("x$Width")
}

function Get-CheckedEnd {
    param(
        [Parameter(Mandatory = $true)]
        [uint64]$Start,

        [Parameter(Mandatory = $true)]
        [uint64]$Length,

        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if ($Length -gt ([uint64]::MaxValue - $Start)) {
        throw "$Context address range overflows"
    }

    return $Start + $Length
}

function Test-PowerOfTwo {
    param(
        [Parameter(Mandatory = $true)]
        [uint64]$Value
    )

    return ($Value -ne 0) -and (($Value -band ($Value - 1)) -eq 0)
}

function Assert-ByteRange {
    param(
        [Parameter(Mandatory = $true)]
        [byte[]]$Bytes,

        [Parameter(Mandatory = $true)]
        [uint64]$Offset,

        [Parameter(Mandatory = $true)]
        [uint64]$Count,

        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $length = [uint64]$Bytes.LongLength
    if (($Offset -gt $length) -or ($Count -gt ($length - $Offset))) {
        throw ('{0} is outside the file: offset={1}, size={2}, file-size={3}' -f $Context, (Format-AddressHex $Offset), (Format-AddressHex $Count), (Format-AddressHex $length))
    }

    if (($Offset -gt [int]::MaxValue) -or ($Count -gt [int]::MaxValue)) {
        throw "$Context is too large for this PowerShell validator"
    }
}

function Read-U16 {
    param(
        [Parameter(Mandatory = $true)]
        [byte[]]$Bytes,

        [Parameter(Mandatory = $true)]
        [uint64]$Offset,

        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    Assert-ByteRange $Bytes $Offset 2 $Context
    return [uint64][System.BitConverter]::ToUInt16($Bytes, [int]$Offset)
}

function Read-U32 {
    param(
        [Parameter(Mandatory = $true)]
        [byte[]]$Bytes,

        [Parameter(Mandatory = $true)]
        [uint64]$Offset,

        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    Assert-ByteRange $Bytes $Offset 4 $Context
    return [uint64][System.BitConverter]::ToUInt32($Bytes, [int]$Offset)
}

function Copy-ByteRange {
    param(
        [Parameter(Mandatory = $true)]
        [byte[]]$Bytes,

        [Parameter(Mandatory = $true)]
        [uint64]$Offset,

        [Parameter(Mandatory = $true)]
        [uint64]$Count,

        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    Assert-ByteRange $Bytes $Offset $Count $Context
    $result = [byte[]]::new([int]$Count)
    [System.Array]::Copy($Bytes, [int]$Offset, $result, 0, [int]$Count)
    return $result
}

function Read-Elf32 {
    param(
        [Parameter(Mandatory = $true)]
        [byte[]]$Bytes,

        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    Assert-ByteRange $Bytes 0 52 'ELF header'
    if (($Bytes[0] -ne 0x7F) -or ($Bytes[1] -ne 0x45) -or ($Bytes[2] -ne 0x4C) -or ($Bytes[3] -ne 0x46)) {
        throw "Not an ELF file: $Path"
    }
    if ($Bytes[4] -ne 1) {
        throw "ELF must be 32-bit (ELFCLASS32): $Path"
    }
    if ($Bytes[5] -ne 1) {
        throw "ELF must use little-endian encoding (ELFDATA2LSB): $Path"
    }
    if ($Bytes[6] -ne 1) {
        throw "ELF identification version is not EV_CURRENT: $Path"
    }

    $elfType = Read-U16 $Bytes 16 'ELF type'
    $machine = Read-U16 $Bytes 18 'ELF machine'
    $elfVersion = Read-U32 $Bytes 20 'ELF version'
    $entry = Read-U32 $Bytes 24 'ELF entry point'
    $programHeaderOffset = Read-U32 $Bytes 28 'ELF program-header offset'
    $headerSize = Read-U16 $Bytes 40 'ELF header size'
    $programHeaderEntrySize = Read-U16 $Bytes 42 'ELF program-header entry size'
    $programHeaderCount = Read-U16 $Bytes 44 'ELF program-header count'

    if ($elfType -ne 2) {
        throw ('ELF must be an executable image (ET_EXEC), found e_type={0}' -f $elfType)
    }
    if ($machine -ne 40) {
        throw ('ELF is not an Arm image (EM_ARM=40), found e_machine={0}' -f $machine)
    }
    if ($elfVersion -ne 1) {
        throw ('ELF header version is not EV_CURRENT: {0}' -f $elfVersion)
    }
    if ($headerSize -ne 52) {
        throw ('Unexpected ELF32 header size: {0}' -f $headerSize)
    }
    if ($programHeaderEntrySize -ne 32) {
        throw ('Unexpected ELF32 program-header size: {0}' -f $programHeaderEntrySize)
    }
    if ($programHeaderCount -eq 0) {
        throw 'ELF contains no program headers'
    }

    $programHeaderTableSize = [uint64]$programHeaderEntrySize * [uint64]$programHeaderCount
    Assert-ByteRange $Bytes $programHeaderOffset $programHeaderTableSize 'ELF program-header table'

    $segments = [System.Collections.Generic.List[object]]::new()
    for ($index = 0; $index -lt $programHeaderCount; $index++) {
        $offset = $programHeaderOffset + ([uint64]$index * $programHeaderEntrySize)
        $type = Read-U32 $Bytes $offset "program header $index type"
        if ($type -ne 1) {
            continue
        }

        $fileOffset = Read-U32 $Bytes ($offset + 4) "LOAD[$index] file offset"
        $virtualAddress = Read-U32 $Bytes ($offset + 8) "LOAD[$index] virtual address"
        $physicalAddress = Read-U32 $Bytes ($offset + 12) "LOAD[$index] physical address"
        $fileSize = Read-U32 $Bytes ($offset + 16) "LOAD[$index] file size"
        $memorySize = Read-U32 $Bytes ($offset + 20) "LOAD[$index] memory size"
        $flags = Read-U32 $Bytes ($offset + 24) "LOAD[$index] flags"
        $alignment = Read-U32 $Bytes ($offset + 28) "LOAD[$index] alignment"

        if ($fileSize -gt $memorySize) {
            throw ('LOAD[{0}] has p_filesz greater than p_memsz: filesz={1}, memsz={2}' -f $index, (Format-AddressHex $fileSize), (Format-AddressHex $memorySize))
        }
        Assert-ByteRange $Bytes $fileOffset $fileSize "LOAD[$index] file bytes"

        if (($alignment -gt 1) -and -not (Test-PowerOfTwo $alignment)) {
            throw ('LOAD[{0}] alignment is not a power of two: {1}' -f $index, (Format-AddressHex $alignment))
        }
        if (($alignment -gt 1) -and (($virtualAddress % $alignment) -ne ($fileOffset % $alignment))) {
            throw ('LOAD[{0}] violates ELF p_vaddr/p_offset alignment congruence' -f $index)
        }

        [void]$segments.Add([pscustomobject]@{
            Index = $index
            FileOffset = [uint64]$fileOffset
            VirtualAddress = [uint64]$virtualAddress
            PhysicalAddress = [uint64]$physicalAddress
            FileSize = [uint64]$fileSize
            MemorySize = [uint64]$memorySize
            Flags = [uint64]$flags
            Alignment = [uint64]$alignment
            FileEnd = Get-CheckedEnd $fileOffset $fileSize "LOAD[$index] file"
            VirtualEnd = Get-CheckedEnd $virtualAddress $memorySize "LOAD[$index] virtual"
            PhysicalEnd = Get-CheckedEnd $physicalAddress $fileSize "LOAD[$index] physical"
        })
    }

    if ($segments.Count -eq 0) {
        throw 'ELF contains no PT_LOAD segments'
    }

    return [pscustomobject]@{
        Bytes = $Bytes
        Entry = [uint64]$entry
        LoadSegments = $segments.ToArray()
    }
}

function Get-ElfBytesAtPhysicalAddress {
    param(
        [Parameter(Mandatory = $true)]
        [object]$Elf,

        [Parameter(Mandatory = $true)]
        [uint64]$Address,

        [Parameter(Mandatory = $true)]
        [uint64]$Count,

        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if ($Count -gt [int]::MaxValue) {
        throw "$Context is too large for this PowerShell validator"
    }

    $result = [byte[]]::new([int]$Count)
    $cursor = $Address
    $written = [uint64]0
    while ($written -lt $Count) {
        $matches = @($Elf.LoadSegments | Where-Object {
            ($_.FileSize -gt 0) -and ($cursor -ge $_.PhysicalAddress) -and ($cursor -lt $_.PhysicalEnd)
        })
        if ($matches.Count -ne 1) {
            throw ('{0} is not covered exactly once by an ELF file-backed LOAD segment at {1}' -f $Context, (Format-AddressHex $cursor))
        }

        $segment = $matches[0]
        $available = $segment.PhysicalEnd - $cursor
        $remaining = $Count - $written
        $copyCount = [uint64][Math]::Min([double]$available, [double]$remaining)
        $sourceOffset = $segment.FileOffset + ($cursor - $segment.PhysicalAddress)
        [System.Array]::Copy($Elf.Bytes, [int]$sourceOffset, $result, [int]$written, [int]$copyCount)
        $cursor += $copyCount
        $written += $copyCount
    }

    return $result
}

function Get-ElfBytesAtVirtualAddress {
    param(
        [Parameter(Mandatory = $true)]
        [object]$Elf,

        [Parameter(Mandatory = $true)]
        [uint64]$Address,

        [Parameter(Mandatory = $true)]
        [uint64]$Count,

        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $end = Get-CheckedEnd $Address $Count $Context
    $matches = @($Elf.LoadSegments | Where-Object {
        ($_.FileSize -gt 0) -and
        ($Address -ge $_.VirtualAddress) -and
        ($end -le ($_.VirtualAddress + $_.FileSize))
    })
    if ($matches.Count -ne 1) {
        throw ('{0} is not covered exactly once by an ELF file-backed LOAD segment at virtual address {1}' -f $Context, (Format-AddressHex $Address))
    }

    $segment = $matches[0]
    $sourceOffset = $segment.FileOffset + ($Address - $segment.VirtualAddress)
    return Copy-ByteRange $Elf.Bytes $sourceOffset $Count $Context
}

function Get-ImageBytesAtAddress {
    param(
        [Parameter()]
        [AllowNull()]
        [byte[]]$RawBytes,

        [Parameter()]
        [AllowNull()]
        [object]$Elf,

        [Parameter(Mandatory = $true)]
        [uint64]$Address,

        [Parameter(Mandatory = $true)]
        [uint64]$Count,

        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if ($null -ne $RawBytes) {
        if ($Address -lt $script:flashBase) {
            throw ('{0} address is below FlexSPI1 base: {1}' -f $Context, (Format-AddressHex $Address))
        }
        $offset = $Address - $script:flashBase
        return Copy-ByteRange $RawBytes $offset $Count $Context
    }

    if ($null -eq $Elf) {
        throw 'Internal validator error: no image source'
    }
    return Get-ElfBytesAtPhysicalAddress $Elf $Address $Count $Context
}

function Test-RangeContained {
    param(
        [Parameter(Mandatory = $true)]
        [uint64]$Start,

        [Parameter(Mandatory = $true)]
        [uint64]$Length,

        [Parameter(Mandatory = $true)]
        [uint64]$RangeStart,

        [Parameter(Mandatory = $true)]
        [uint64]$RangeEnd
    )

    if ($Start -lt $RangeStart) {
        return $false
    }
    $end = Get-CheckedEnd $Start $Length 'address range'
    return $end -le $RangeEnd
}

function Assert-NoOverlaps {
    param(
        [Parameter(Mandatory = $true)]
        [object[]]$Ranges,

        [Parameter(Mandatory = $true)]
        [string]$Kind,

        [Parameter(Mandatory = $true)]
        [string]$StartProperty,

        [Parameter(Mandatory = $true)]
        [string]$EndProperty
    )

    $ordered = @($Ranges | Sort-Object -Property $StartProperty)
    for ($index = 1; $index -lt $ordered.Count; $index++) {
        $previous = $ordered[$index - 1]
        $current = $ordered[$index]
        if ([uint64]$current.$StartProperty -lt [uint64]$previous.$EndProperty) {
            throw ('ELF {0} LOAD segments overlap: LOAD[{1}] and LOAD[{2}]' -f $Kind, $previous.Index, $current.Index)
        }
    }
}

function Assert-WordCopyRelocationGeometry {
    param(
        [Parameter(Mandatory = $true)]
        [object[]]$Segments,

        [Parameter(Mandatory = $true)]
        [uint64]$RegionStart,

        [Parameter(Mandatory = $true)]
        [string]$RegionName
    )

    $initializedSegments = @($Segments | Where-Object { $_.FileSize -gt 0 })
    $haveSourceBase = $false
    $sourceBase = [uint64]0
    foreach ($segment in $initializedSegments) {
        if ((($segment.VirtualAddress -band 3) -ne 0) -or
            (($segment.PhysicalAddress -band 3) -ne 0) -or
            (($segment.FileSize -band 3) -ne 0)) {
            throw ('{0} LOAD[{1}] is not word-aligned for the startup copy loop: vaddr={2}, paddr={3}, filesz={4}' -f `
                $RegionName,
                $segment.Index,
                (Format-AddressHex $segment.VirtualAddress),
                (Format-AddressHex $segment.PhysicalAddress),
                (Format-AddressHex $segment.FileSize))
        }

        $relativeAddress = $segment.VirtualAddress - $RegionStart
        if ($segment.PhysicalAddress -lt $relativeAddress) {
            throw ('{0} LOAD[{1}] has an invalid relocation source mapping' -f $RegionName, $segment.Index)
        }
        $candidateSourceBase = $segment.PhysicalAddress - $relativeAddress
        if (-not $haveSourceBase) {
            $sourceBase = $candidateSourceBase
            $haveSourceBase = $true
            continue
        }
        if ($candidateSourceBase -ne $sourceBase) {
            throw ('{0} LOAD segments do not use one contiguous LMA/VMA mapping: LOAD[{1}] implies source base {2}, expected {3}' -f `
                $RegionName,
                $segment.Index,
                (Format-AddressHex $candidateSourceBase),
                (Format-AddressHex $sourceBase))
        }
    }
}

function Assert-HabPointer {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name,

        [Parameter(Mandatory = $true)]
        [uint64]$Pointer,

        [Parameter(Mandatory = $true)]
        [byte]$ExpectedTag,

        [Parameter(Mandatory = $true)]
        [uint64]$BootStart,

        [Parameter(Mandatory = $true)]
        [uint64]$BootEnd,

        [Parameter()]
        [AllowNull()]
        [byte[]]$RawBytes,

        [Parameter()]
        [AllowNull()]
        [object]$Elf
    )

    if ($Pointer -eq 0) {
        return
    }
    if (($Pointer -band 3) -ne 0) {
        throw ('IVT {0} pointer is not 4-byte aligned: {1}' -f $Name, (Format-AddressHex $Pointer))
    }
    if (($Pointer -lt $BootStart) -or ($Pointer -ge $BootEnd)) {
        throw ('IVT {0} pointer is outside Boot Data range: {1}' -f $Name, (Format-AddressHex $Pointer))
    }

    $header = Get-ImageBytesAtAddress $RawBytes $Elf $Pointer 4 "$Name header"
    if ($header[0] -ne $ExpectedTag) {
        throw ('{0} header tag is invalid at {1}: expected 0x{2:x2}, found 0x{3:x2}' -f $Name, (Format-AddressHex $Pointer), $ExpectedTag, $header[0])
    }
    $length = ([uint64]$header[1] -shl 8) -bor [uint64]$header[2]
    if ($length -lt 4) {
        throw ('{0} header length is invalid: {1}' -f $Name, $length)
    }
    if (($header[3] -lt 0x40) -or ($header[3] -gt 0x43)) {
        throw ('{0} HAB version is invalid: 0x{1:x2}' -f $Name, $header[3])
    }
    $structureEnd = Get-CheckedEnd $Pointer $length $Name
    if ($structureEnd -gt $BootEnd) {
        throw ('{0} extends beyond Boot Data range: end={1}' -f $Name, (Format-AddressHex $structureEnd))
    }
    [void](Get-ImageBytesAtAddress $RawBytes $Elf $Pointer $length $Name)
}

if ([string]::IsNullOrWhiteSpace($ElfPath) -and [string]::IsNullOrWhiteSpace($BinaryPath)) {
    throw 'Specify -ElfPath, -BinaryPath, or both'
}
$minimumFlashSize = [uint64]0x3000
$maximumFlashSize = [uint64]0x01000000
if (($FlashSizeBytes -lt $minimumFlashSize) -or ($FlashSizeBytes -gt $maximumFlashSize)) {
    throw ('FlashSizeBytes must be between {0} and {1}, found {2}' -f `
        (Format-AddressHex $minimumFlashSize),
        (Format-AddressHex $maximumFlashSize),
        (Format-AddressHex $FlashSizeBytes))
}
if (-not (Test-PowerOfTwo $FlashSizeBytes)) {
    throw ('FlashSizeBytes must be a power of two, found {0}' -f (Format-AddressHex $FlashSizeBytes))
}

$flashEnd = Get-CheckedEnd $flashBase $FlashSizeBytes 'FlexSPI1 flash'
$elf = $null
$rawBytes = $null
$resolvedElfPath = $null
$resolvedBinaryPath = $null

if (-not [string]::IsNullOrWhiteSpace($ElfPath)) {
    if (-not (Test-Path -LiteralPath $ElfPath -PathType Leaf)) {
        throw "ELF file not found: $ElfPath"
    }
    $resolvedElfPath = (Resolve-Path -LiteralPath $ElfPath).Path
    $elfBytes = [System.IO.File]::ReadAllBytes($resolvedElfPath)
    $elf = Read-Elf32 $elfBytes $resolvedElfPath
}

if (-not [string]::IsNullOrWhiteSpace($BinaryPath)) {
    if (-not (Test-Path -LiteralPath $BinaryPath -PathType Leaf)) {
        throw "QSPI binary not found: $BinaryPath"
    }
    $resolvedBinaryPath = (Resolve-Path -LiteralPath $BinaryPath).Path
    $rawBytes = [System.IO.File]::ReadAllBytes($resolvedBinaryPath)
    if ([uint64]$rawBytes.LongLength -gt $FlashSizeBytes) {
        throw ('Raw QSPI image exceeds configured flash capacity: image={0}, capacity={1}' -f (Format-AddressHex $rawBytes.LongLength), (Format-AddressHex $FlashSizeBytes))
    }
    if ([uint64]$rawBytes.LongLength -lt 0x2008) {
        throw ('Raw QSPI image is too small to contain the application vector at +0x2000: {0} bytes' -f $rawBytes.LongLength)
    }
}

$fileBackedSegments = @()
$itcmSegments = @()
$dtcmSegments = @()
$flashSegments = @()
$ocramSegments = @()
$elfUsedSpan = [uint64]0

if ($null -ne $elf) {
    $fileBackedSegments = @($elf.LoadSegments | Where-Object { $_.FileSize -gt 0 })
    if ($fileBackedSegments.Count -eq 0) {
        throw 'ELF contains no file-backed PT_LOAD segments'
    }

    foreach ($segment in $fileBackedSegments) {
        if (($segment.PhysicalAddress -lt $flashBase) -or ($segment.PhysicalEnd -gt $flashEnd)) {
            throw ('File-backed LOAD[{0}] is outside FlexSPI1 flash: paddr={1}, filesz={2}, capacity={3}' -f $segment.Index, (Format-AddressHex $segment.PhysicalAddress), (Format-AddressHex $segment.FileSize), (Format-AddressHex $FlashSizeBytes))
        }
        $segmentSpan = $segment.PhysicalEnd - $flashBase
        if ($segmentSpan -gt $elfUsedSpan) {
            $elfUsedSpan = $segmentSpan
        }
    }
    Assert-NoOverlaps $fileBackedSegments 'physical/file-backed' 'PhysicalAddress' 'PhysicalEnd'

    $memorySegments = @($elf.LoadSegments | Where-Object { $_.MemorySize -gt 0 })
    Assert-NoOverlaps $memorySegments 'virtual-memory' 'VirtualAddress' 'VirtualEnd'
    foreach ($segment in $memorySegments) {
        if (Test-RangeContained $segment.VirtualAddress $segment.MemorySize $flashBase $flashEnd) {
            $flashSegments += $segment
            continue
        }
        if (Test-RangeContained $segment.VirtualAddress $segment.MemorySize $itcmStart $itcmEnd) {
            $itcmSegments += $segment
            if (($segment.FileSize -gt 0) -and ($segment.PhysicalAddress -lt ($applicationVectorAddress + 8))) {
                throw ('ITCM LOAD[{0}] relocation source overlaps the boot header/vector area: paddr={1}' -f $segment.Index, (Format-AddressHex $segment.PhysicalAddress))
            }
            continue
        }
        if (Test-RangeContained $segment.VirtualAddress $segment.MemorySize $dtcmStart $dtcmEnd) {
            $dtcmSegments += $segment
            if (($segment.Flags -band 1) -ne 0) {
                throw ('DTCM LOAD[{0}] is unexpectedly executable' -f $segment.Index)
            }
            if (($segment.Flags -band 2) -eq 0) {
                throw ('DTCM LOAD[{0}] is not writable' -f $segment.Index)
            }
            if (($segment.FileSize -gt 0) -and ($segment.PhysicalAddress -lt ($applicationVectorAddress + 8))) {
                throw ('DTCM LOAD[{0}] relocation source overlaps the boot header/vector area: paddr={1}' -f $segment.Index, (Format-AddressHex $segment.PhysicalAddress))
            }
            continue
        }
        if (Test-RangeContained $segment.VirtualAddress $segment.MemorySize $ocramStart $ocramEnd) {
            $ocramSegments += $segment
            continue
        }

        throw ('LOAD[{0}] virtual range is outside FlexSPI1, 256-KiB ITCM/DTCM, and OCRAM: vaddr={1}, memsz={2}' -f $segment.Index, (Format-AddressHex $segment.VirtualAddress), (Format-AddressHex $segment.MemorySize))
    }

    Assert-WordCopyRelocationGeometry $itcmSegments $itcmStart 'ITCM'
    Assert-WordCopyRelocationGeometry $dtcmSegments $dtcmStart 'DTCM'

    if ($flashSegments.Count -eq 0) {
        throw 'ELF has no FlexSPI1-resident PT_LOAD segment for the ROM-visible bootstrap'
    }
    if ($itcmSegments.Count -eq 0) {
        throw 'ELF has no PT_LOAD segment in the configured 256-KiB ITCM range'
    }
    if ($dtcmSegments.Count -eq 0) {
        throw 'ELF has no PT_LOAD segment in the configured 256-KiB DTCM range'
    }

    # Require all ROM-visible structures to be emitted by the flash-linked ELF,
    # even when a raw binary is supplied as the preferred byte source below.
    [void](Get-ElfBytesAtPhysicalAddress $elf $flashBase $fcbSize 'ELF FCB')
    [void](Get-ElfBytesAtPhysicalAddress $elf $ivtAddress 32 'ELF IVT')
    [void](Get-ElfBytesAtPhysicalAddress $elf $bootDataAddress 16 'ELF Boot Data')
    [void](Get-ElfBytesAtPhysicalAddress $elf $applicationVectorAddress 64 'ELF application vector')
}

if (($null -ne $elf) -and ($null -ne $rawBytes)) {
    if ([uint64]$rawBytes.LongLength -ne $elfUsedSpan) {
        throw ('Raw image length does not match the complete ELF LOAD span: raw={0}, ELF={1}' -f `
            (Format-AddressHex $rawBytes.LongLength),
            (Format-AddressHex $elfUsedSpan))
    }

    $gapCursor = [uint64]0
    foreach ($segment in @($fileBackedSegments | Sort-Object PhysicalAddress)) {
        $rawOffset = $segment.PhysicalAddress - $flashBase
        for ($index = $gapCursor; $index -lt $rawOffset; $index++) {
            if ($rawBytes[[int]$index] -ne 0) {
                throw ('Raw byte in ELF LOAD gap is not objcopy zero-fill at flash address {0}: 0x{1:x2}' -f `
                    (Format-AddressHex ($flashBase + $index)),
                    $rawBytes[[int]$index])
            }
        }
        $gapCursor = $rawOffset + $segment.FileSize
    }
    for ($index = $gapCursor; $index -lt [uint64]$rawBytes.LongLength; $index++) {
        if ($rawBytes[[int]$index] -ne 0) {
            throw ('Raw trailing byte outside ELF LOAD data is not objcopy zero-fill at flash address {0}: 0x{1:x2}' -f `
                (Format-AddressHex ($flashBase + $index)),
                $rawBytes[[int]$index])
        }
    }

    foreach ($segment in $fileBackedSegments) {
        $rawOffset = $segment.PhysicalAddress - $flashBase
        Assert-ByteRange $rawBytes $rawOffset $segment.FileSize "raw bytes for LOAD[$($segment.Index)]"
        for ($index = [uint64]0; $index -lt $segment.FileSize; $index++) {
            $elfByte = $elf.Bytes[[int]($segment.FileOffset + $index)]
            $rawByte = $rawBytes[[int]($rawOffset + $index)]
            if ($elfByte -ne $rawByte) {
                $address = $segment.PhysicalAddress + $index
                throw ('Raw/ELF byte mismatch at flash address {0}: ELF=0x{1:x2}, raw=0x{2:x2}' -f (Format-AddressHex $address), $elfByte, $rawByte)
            }
        }
    }
}

$fcb = Get-ImageBytesAtAddress $rawBytes $elf $flashBase $fcbSize 'FlexSPI configuration block'
$fcbTag = Read-U32 $fcb 0 'FCB tag'
$fcbVersion = Read-U32 $fcb 4 'FCB version'
if ($fcbTag -ne $expectedFcbTag) {
    throw ('FCB tag is invalid at flash +0x0000: expected {0}, found {1}' -f (Format-AddressHex $expectedFcbTag), (Format-AddressHex $fcbTag))
}
if ($fcbVersion -ne $expectedFcbVersion) {
    throw ('FCB version is invalid: expected {0} (V1.4.0), found {1}' -f (Format-AddressHex $expectedFcbVersion), (Format-AddressHex $fcbVersion))
}

$deviceType = [uint64]$fcb[0x44]
$padType = [uint64]$fcb[0x45]
$serialClock = [uint64]$fcb[0x46]
$sampleClockSource = [uint64]$fcb[0x0C]
$a1Size = Read-U32 $fcb 0x50 'FCB sflashA1Size'
$a2Size = Read-U32 $fcb 0x54 'FCB sflashA2Size'
$b1Size = Read-U32 $fcb 0x58 'FCB sflashB1Size'
$b2Size = Read-U32 $fcb 0x5C 'FCB sflashB2Size'
$readLutCommandAddress = Read-U32 $fcb 0x80 'FCB read LUT command/address sequence'
$readLutDummyRead = Read-U32 $fcb 0x84 'FCB read LUT dummy/read sequence'
if ($deviceType -ne 1) {
    throw ('FCB deviceType is not Serial NOR: {0}' -f $deviceType)
}
if ($padType -ne 4) {
    throw ('FCB sflashPadType must select four pads for the W25Q32JV quad-read sequence: {0}' -f $padType)
}
if ($serialClock -ne 3) {
    throw ('FCB serialClkFreq must select the validated 60 MHz setting: {0}' -f $serialClock)
}
if ($sampleClockSource -ne 0) {
    throw ('FCB readSampleClkSrc must select internal loopback: {0}' -f $sampleClockSource)
}
if ($a1Size -ne $FlashSizeBytes) {
    throw ('FCB sflashA1Size does not match expected flash capacity: FCB={0}, expected={1}' -f (Format-AddressHex $a1Size), (Format-AddressHex $FlashSizeBytes))
}
if (($a2Size -ne 0) -or ($b1Size -ne 0) -or ($b2Size -ne 0)) {
    throw ('FCB unexpectedly configures additional FlexSPI ports: A2={0}, B1={1}, B2={2}' -f (Format-AddressHex $a2Size), (Format-AddressHex $b1Size), (Format-AddressHex $b2Size))
}
if (($readLutCommandAddress -ne 0x0A1804EB) -or ($readLutDummyRead -ne 0x26043206)) {
    throw ('FCB read LUT must encode EBh/24-bit quad address/6 dummy cycles/quad read: word0={0}, word1={1}' -f `
        (Format-AddressHex $readLutCommandAddress),
        (Format-AddressHex $readLutDummyRead))
}

$ivt = Get-ImageBytesAtAddress $rawBytes $elf $ivtAddress 32 'Image Vector Table'
$ivtLength = ([uint64]$ivt[1] -shl 8) -bor [uint64]$ivt[2]
$ivtVersion = [uint64]$ivt[3]
$ivtEntry = Read-U32 $ivt 4 'IVT entry'
$ivtReserved1 = Read-U32 $ivt 8 'IVT reserved1'
$ivtDcd = Read-U32 $ivt 12 'IVT DCD pointer'
$ivtBootData = Read-U32 $ivt 16 'IVT Boot Data pointer'
$ivtSelf = Read-U32 $ivt 20 'IVT self pointer'
$ivtCsf = Read-U32 $ivt 24 'IVT CSF pointer'
$ivtReserved2 = Read-U32 $ivt 28 'IVT reserved2'

if ($ivt[0] -ne 0xD1) {
    throw ('IVT tag is invalid at flash +0x1000: expected 0xd1, found 0x{0:x2}' -f $ivt[0])
}
if ($ivtLength -ne 0x20) {
    throw ('IVT header length is invalid: expected 0x0020, found {0}' -f (Format-AddressHex $ivtLength 4))
}
if (($ivtVersion -lt 0x40) -or ($ivtVersion -gt 0x43)) {
    throw ('IVT HAB version is invalid: 0x{0:x2}' -f $ivtVersion)
}
if (($ivtReserved1 -ne 0) -or ($ivtReserved2 -ne 0)) {
    throw ('IVT reserved words must be zero: reserved1={0}, reserved2={1}' -f (Format-AddressHex $ivtReserved1), (Format-AddressHex $ivtReserved2))
}
if ($ivtSelf -ne $ivtAddress) {
    throw ('IVT self pointer is invalid: expected {0}, found {1}' -f (Format-AddressHex $ivtAddress), (Format-AddressHex $ivtSelf))
}
if ($ivtBootData -ne $bootDataAddress) {
    throw ('IVT Boot Data pointer is invalid for the RT1061 direct-link layout: expected {0}, found {1}' -f (Format-AddressHex $bootDataAddress), (Format-AddressHex $ivtBootData))
}
if ($ivtEntry -ne $applicationVectorAddress) {
    throw ('IVT entry must point to the application Cortex vector at flash +0x2000: expected {0}, found {1}' -f (Format-AddressHex $applicationVectorAddress), (Format-AddressHex $ivtEntry))
}

$bootData = Get-ImageBytesAtAddress $rawBytes $elf $ivtBootData 16 'Boot Data'
$bootStart = Read-U32 $bootData 0 'Boot Data start'
$bootLength = Read-U32 $bootData 4 'Boot Data length'
$pluginFlag = Read-U32 $bootData 8 'Boot Data plugin flag'
if ($bootStart -ne $flashBase) {
    throw ('Boot Data start is invalid for FlexSPI1: expected {0}, found {1}' -f (Format-AddressHex $flashBase), (Format-AddressHex $bootStart))
}
if ($pluginFlag -ne 0) {
    throw ('Boot Data plugin flag must be zero for the normal image: {0}' -f $pluginFlag)
}
if ($bootLength -lt (($applicationVectorAddress + 8) - $flashBase)) {
    throw ('Boot Data length does not cover the application vector: {0}' -f (Format-AddressHex $bootLength))
}
$bootEnd = Get-CheckedEnd $bootStart $bootLength 'Boot Data image'
if ($bootEnd -gt $flashEnd) {
    throw ('Boot Data image exceeds configured flash capacity: end={0}, flash-end={1}' -f (Format-AddressHex $bootEnd), (Format-AddressHex $flashEnd))
}

Assert-HabPointer 'DCD' $ivtDcd 0xD2 $bootStart $bootEnd $rawBytes $elf
Assert-HabPointer 'CSF' $ivtCsf 0xD4 $bootStart $bootEnd $rawBytes $elf

$applicationVector = Get-ImageBytesAtAddress $rawBytes $elf $applicationVectorAddress 64 'application Cortex vector'
$initialSp = Read-U32 $applicationVector 0 'application initial stack pointer'
$resetVector = Read-U32 $applicationVector 4 'application reset vector'
$resetAddress = $resetVector -band $thumbAddressMask
if (($initialSp -band 7) -ne 0) {
    throw ('Application initial stack pointer is not 8-byte aligned: {0}' -f (Format-AddressHex $initialSp))
}
$spInRomDefaultDtcm = ($initialSp -gt $dtcmStart) -and ($initialSp -le $romDefaultDtcmEnd)
$spInOcram = ($initialSp -gt $ocramStart) -and ($initialSp -le $ocramEnd)
if (-not ($spInRomDefaultDtcm -or $spInOcram)) {
    throw ('Application initial stack pointer is not valid at Boot ROM handoff: {0}' -f (Format-AddressHex $initialSp))
}
if (($resetVector -band 1) -eq 0) {
    throw ('Application reset vector does not have the Thumb bit set: {0}' -f (Format-AddressHex $resetVector))
}
if (($resetAddress -lt ($applicationVectorAddress + 8)) -or ($resetAddress -ge $bootEnd)) {
    throw ('Application reset handler is outside the flash-resident boot image: {0}' -f (Format-AddressHex $resetAddress))
}
[void](Get-ImageBytesAtAddress $rawBytes $elf $resetAddress 2 'application reset handler')

$bootstrapReservedVectors = @(7, 8, 9, 10, 13)
foreach ($vectorIndex in $bootstrapReservedVectors) {
    $vectorValue = Read-U32 $applicationVector ($vectorIndex * 4) "bootstrap reserved vector $vectorIndex"
    if ($vectorValue -ne 0) {
        throw ('Bootstrap reserved vector {0} must be zero: {1}' -f $vectorIndex, (Format-AddressHex $vectorValue))
    }
}

$bootstrapHandlerVectors = @(2, 3, 4, 5, 6, 11, 12, 14, 15)
foreach ($vectorIndex in $bootstrapHandlerVectors) {
    $handlerVector = Read-U32 $applicationVector ($vectorIndex * 4) "bootstrap handler vector $vectorIndex"
    if (($handlerVector -band 1) -eq 0) {
        throw ('Bootstrap handler vector {0} does not have the Thumb bit set: {1}' -f $vectorIndex, (Format-AddressHex $handlerVector))
    }
    $handlerAddress = $handlerVector -band $thumbAddressMask
    if (($handlerAddress -lt ($applicationVectorAddress + 64)) -or ($handlerAddress -ge $bootEnd)) {
        throw ('Bootstrap handler vector {0} is outside the flash-resident boot image: {1}' -f $vectorIndex, (Format-AddressHex $handlerAddress))
    }
    [void](Get-ImageBytesAtAddress $rawBytes $elf $handlerAddress 2 "bootstrap handler vector $vectorIndex")
}

$usedSpan = [uint64]0
if ($null -ne $rawBytes) {
    $usedSpan = [uint64]$rawBytes.LongLength
}
if ($elfUsedSpan -gt $usedSpan) {
    $usedSpan = $elfUsedSpan
}
if ($usedSpan -gt $bootLength) {
    throw ('Boot Data length does not cover the complete programmed image: boot-length={0}, used-span={1}' -f (Format-AddressHex $bootLength), (Format-AddressHex $usedSpan))
}

$runtimeInitialSp = [uint64]0
$runtimeResetVector = [uint64]0
if ($null -ne $elf) {
    $flashResetSegments = @($flashSegments | Where-Object {
        (($_.Flags -band 1) -ne 0) -and
        ($resetAddress -ge $_.VirtualAddress) -and
        ($resetAddress -lt ($_.VirtualAddress + $_.FileSize))
    })
    if ($flashResetSegments.Count -ne 1) {
        throw ('Application reset handler is not covered exactly once by an executable, file-backed FlexSPI1 LOAD segment: {0}' -f (Format-AddressHex $resetAddress))
    }
    if (($elf.Entry -band $thumbAddressMask) -ne $resetAddress) {
        throw ('ELF entry point does not match the application reset vector: e_entry={0}, vector={1}' -f (Format-AddressHex $elf.Entry), (Format-AddressHex $resetVector))
    }

    # RT1061 has 16 Cortex-M vector words followed by 158 external IRQ words.
    # Reset intentionally remains the flash bootstrap, while every handler used
    # after VTOR is switched to zero must execute from the relocated ITCM image.
    $runtimeVectorEntryCount = [uint64]174
    $runtimeVectorSize = $runtimeVectorEntryCount * 4
    $runtimeVector = Get-ElfBytesAtVirtualAddress $elf 0 $runtimeVectorSize 'relocated ITCM vector table'
    $runtimeInitialSp = Read-U32 $runtimeVector 0 'relocated ITCM initial stack pointer'
    $runtimeResetVector = Read-U32 $runtimeVector 4 'relocated ITCM reset vector'
    $runtimeResetAddress = $runtimeResetVector -band $thumbAddressMask
    if (($runtimeInitialSp -band 7) -ne 0) {
        throw ('Relocated ITCM initial stack pointer is not 8-byte aligned: {0}' -f (Format-AddressHex $runtimeInitialSp))
    }
    if (($runtimeInitialSp -le $dtcmStart) -or ($runtimeInitialSp -gt $dtcmEnd)) {
        throw ('Relocated ITCM vector stack pointer is outside configured 256-KiB DTCM: {0}' -f (Format-AddressHex $runtimeInitialSp))
    }
    if (($runtimeResetVector -band 1) -eq 0) {
        throw ('Relocated ITCM reset vector does not have the Thumb bit set: {0}' -f (Format-AddressHex $runtimeResetVector))
    }

    if ($runtimeResetVector -ne $resetVector) {
        $runtimeResetSegments = @($itcmSegments | Where-Object {
            (($_.Flags -band 1) -ne 0) -and
            ($runtimeResetAddress -ge $_.VirtualAddress) -and
            ($runtimeResetAddress -lt ($_.VirtualAddress + $_.FileSize))
        })
        if ($runtimeResetSegments.Count -ne 1) {
            throw ('Relocated Reset vector must match the flash bootstrap Reset vector or target executable, file-backed ITCM: {0}' -f (Format-AddressHex $runtimeResetVector))
        }
    }

    $reservedCoreIndices = @(7, 8, 9, 10, 13)
    foreach ($vectorIndex in $reservedCoreIndices) {
        $reservedValue = Read-U32 $runtimeVector ([uint64]$vectorIndex * 4) "relocated ITCM reserved vector $vectorIndex"
        if ($reservedValue -ne 0) {
            throw ('Relocated ITCM reserved vector {0} must be zero, found {1}' -f $vectorIndex, (Format-AddressHex $reservedValue))
        }
    }

    $coreHandlerNames = @{
        2 = 'NMI'
        3 = 'HardFault'
        4 = 'MemManage'
        5 = 'BusFault'
        6 = 'UsageFault'
        11 = 'SVCall'
        12 = 'DebugMonitor'
        14 = 'PendSV'
        15 = 'SysTick'
    }
    $handlerVectorIndices = @($coreHandlerNames.Keys | ForEach-Object { [int]$_ } | Sort-Object)
    $handlerVectorIndices += 16..173
    foreach ($vectorIndex in $handlerVectorIndices) {
        $handlerName = if ($vectorIndex -lt 16) {
            [string]$coreHandlerNames[$vectorIndex]
        } else {
            'IRQ{0}' -f ($vectorIndex - 16)
        }
        $handlerVector = Read-U32 $runtimeVector ([uint64]$vectorIndex * 4) "relocated ITCM vector $handlerName"
        if (($handlerVector -band 1) -eq 0) {
            throw ('Relocated ITCM vector {0} does not have the Thumb bit set: {1}' -f $handlerName, (Format-AddressHex $handlerVector))
        }
        $handlerAddress = $handlerVector -band $thumbAddressMask
        $handlerSegments = @($itcmSegments | Where-Object {
            (($_.Flags -band 1) -ne 0) -and
            ($handlerAddress -ge $_.VirtualAddress) -and
            ($handlerAddress -lt ($_.VirtualAddress + $_.FileSize))
        })
        if ($handlerSegments.Count -ne 1) {
            throw ('Relocated ITCM vector {0} is not covered exactly once by executable, file-backed ITCM: {1}' -f $handlerName, (Format-AddressHex $handlerVector))
        }
    }
}

$sourceDescription = if (($null -ne $elf) -and ($null -ne $rawBytes)) {
    'ELF+raw'
} elseif ($null -ne $elf) {
    'ELF'
} else {
    'raw'
}

$loadCount = if ($null -ne $elf) { $elf.LoadSegments.Count } else { 0 }
Write-Host ('QSPI image valid: source={0}, used={1}, capacity={2}, FCB={3}/{4}, IVT={5}, SP={6}, Reset={7}, LOAD segments={8}' -f `
    $sourceDescription,
    (Format-AddressHex $usedSpan),
    (Format-AddressHex $FlashSizeBytes),
    (Format-AddressHex $fcbTag),
    (Format-AddressHex $fcbVersion),
    (Format-AddressHex $ivtAddress),
    (Format-AddressHex $initialSp),
    (Format-AddressHex $resetVector),
    $loadCount)

if ($null -eq $elf) {
    Write-Host 'ELF relocation geometry was not checked because no ELF was supplied.'
} else {
    Write-Host ('Relocation geometry valid: ITCM vector SP={0}, Reset={1}; ITCM LOADs={2}, DTCM LOADs={3}' -f `
        (Format-AddressHex $runtimeInitialSp),
        (Format-AddressHex $runtimeResetVector),
        $itcmSegments.Count,
        $dtcmSegments.Count)
}
