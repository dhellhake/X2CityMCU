param(
    [Parameter(Mandatory = $true)]
    [string]$ElfPath,

    [Parameter(Mandatory = $true)]
    [string]$BinaryPath
)

$ErrorActionPreference = 'Stop'

$ocramStart = [uint64]0x20200000
$ocramEnd = [uint64]0x20280000

if (-not (Test-Path -LiteralPath $ElfPath -PathType Leaf)) {
    throw "ELF file not found: $ElfPath"
}

if (-not (Test-Path -LiteralPath $BinaryPath -PathType Leaf)) {
    throw "RAM image not found: $BinaryPath"
}

$image = [System.IO.File]::ReadAllBytes((Resolve-Path -LiteralPath $BinaryPath))
if ($image.Length -lt 8) {
    throw "RAM image is too small to contain a vector table: $($image.Length) bytes"
}

if ([uint64]$image.Length -gt ($ocramEnd - $ocramStart)) {
    throw ('RAM image is larger than fixed OCRAM: 0x{0:x} bytes' -f $image.Length)
}

$initialSp = [uint64][System.BitConverter]::ToUInt32($image, 0)
$resetVector = [uint64][System.BitConverter]::ToUInt32($image, 4)
$resetAddress = $resetVector -band ([uint64]4294967294)

if (($initialSp -band 7) -ne 0) {
    throw ('Initial stack pointer is not 8-byte aligned: 0x{0:x8}' -f $initialSp)
}

if (($initialSp -le $ocramStart) -or ($initialSp -gt $ocramEnd)) {
    throw ('Initial stack pointer is outside fixed OCRAM: 0x{0:x8}' -f $initialSp)
}

if (($resetVector -band 1) -eq 0) {
    throw ('Reset vector does not have the Thumb bit set: 0x{0:x8}' -f $resetVector)
}

if (($resetAddress -lt $ocramStart) -or ($resetAddress -ge $ocramEnd)) {
    throw ('Reset handler is outside fixed OCRAM: 0x{0:x8}' -f $resetAddress)
}

$readElf = Get-Command 'arm-none-eabi-readelf' -ErrorAction Stop
$programHeaders = & $readElf.Source '-lW' $ElfPath
if ($LASTEXITCODE -ne 0) {
    throw "arm-none-eabi-readelf failed for $ElfPath"
}

$fileBackedLoadCount = 0
$lowestLoadAddress = [uint64]::MaxValue
$highestLoadEnd = [uint64]0
foreach ($line in $programHeaders) {
    if ($line -match '^\s*LOAD\s+(0x[0-9a-fA-F]+)\s+(0x[0-9a-fA-F]+)\s+(0x[0-9a-fA-F]+)\s+(0x[0-9a-fA-F]+)\s+(0x[0-9a-fA-F]+)') {
        $physicalAddress = [Convert]::ToUInt64($Matches[3].Substring(2), 16)
        $fileSize = [Convert]::ToUInt64($Matches[4].Substring(2), 16)

        if ($fileSize -eq 0) {
            continue
        }

        $fileBackedLoadCount++
        $physicalEnd = $physicalAddress + $fileSize
        if (($physicalAddress -lt $ocramStart) -or ($physicalEnd -gt $ocramEnd)) {
            throw ('File-backed LOAD segment is outside fixed OCRAM: paddr=0x{0:x8}, size=0x{1:x}' -f $physicalAddress, $fileSize)
        }

        if ($physicalAddress -lt $lowestLoadAddress) {
            $lowestLoadAddress = $physicalAddress
        }
        if ($physicalEnd -gt $highestLoadEnd) {
            $highestLoadEnd = $physicalEnd
        }
    }
}

if ($fileBackedLoadCount -eq 0) {
    throw 'No file-backed LOAD segments were found in the ELF program headers'
}

if ($lowestLoadAddress -ne $ocramStart) {
    throw ('First file-backed LOAD does not start at fixed OCRAM: 0x{0:x8}' -f $lowestLoadAddress)
}

$loadSpan = $highestLoadEnd - $ocramStart
if ([uint64]$image.Length -ne $loadSpan) {
    throw ('Binary length (0x{0:x}) does not match the ELF LOAD span (0x{1:x})' -f $image.Length, $loadSpan)
}

Write-Host ('RAM image valid: {0} bytes, SP=0x{1:x8}, Reset=0x{2:x8}, LOAD segments={3}' -f $image.Length, $initialSp, $resetVector, $fileBackedLoadCount)
