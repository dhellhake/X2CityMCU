[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string[]]$ElfPath
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$objdump = Get-Command 'arm-none-eabi-objdump' -ErrorAction Stop

function Get-SymbolBody {
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string[]]$Lines,

        [Parameter(Mandatory = $true)]
        [string]$SymbolSuffix
    )

    $start = -1
    for ($index = 0; $index -lt $Lines.Count; $index++) {
        if ($Lines[$index] -match ([regex]::Escape($SymbolSuffix) + '>:$')) {
            $start = $index
            break
        }
    }

    if ($start -lt 0) {
        throw "Required symbol was not found in disassembly: $SymbolSuffix"
    }

    $end = $Lines.Count
    for ($index = $start + 1; $index -lt $Lines.Count; $index++) {
        if ($Lines[$index] -match '^\s*[0-9a-fA-F]+\s+<.+>:$') {
            $end = $index
            break
        }
    }

    return ($Lines[$start..($end - 1)] -join "`n")
}

function Assert-Matches {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Text,

        [Parameter(Mandatory = $true)]
        [string]$Pattern,

        [Parameter(Mandatory = $true)]
        [string]$FailureMessage
    )

    if ($Text -notmatch $Pattern) {
        throw $FailureMessage
    }
}

foreach ($path in $ElfPath) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "ELF file not found: $path"
    }

    $resolvedPath = (Resolve-Path -LiteralPath $path).Path
    $lines = @(& $objdump.Source '-d' '-C' $resolvedPath)
    if ($LASTEXITCODE -ne 0) {
        throw "arm-none-eabi-objdump failed for $resolvedPath"
    }
    $configure = Get-SymbolBody $lines 'Rtwdog>::ConfigureProtected'
    $refresh = Get-SymbolBody $lines 'Rtwdog>::RefreshProtected'

    if (($configure -match '\bbl(?:\.w)?\b') -or ($refresh -match '\bbl(?:\.w)?\b')) {
        throw "RTWDOG protected function contains a call instruction: $resolvedPath"
    }

    Assert-Matches $configure '#50464\s+@\s+0xc520' "RTWDOG update-key low half is missing: $resolvedPath"
    Assert-Matches $configure '#55592\s+@\s+0xd928' "RTWDOG update-key high half is missing: $resolvedPath"
    Assert-Matches $refresh '#42498\s+@\s+0xa602' "RTWDOG refresh-key low half is missing: $resolvedPath"
    Assert-Matches $refresh '#46208\s+@\s+0xb480' "RTWDOG refresh-key high half is missing: $resolvedPath"

    $adjacentHalfwords = 'strh(?:\.w)?[^\n]*#4\][^\n]*\n[^\n]*strh(?:\.w)?[^\n]*#4\]'
    Assert-Matches $configure $adjacentHalfwords "RTWDOG 16-bit unlock stores are not adjacent: $resolvedPath"
    Assert-Matches $refresh $adjacentHalfwords "RTWDOG 16-bit refresh stores are not adjacent: $resolvedPath"

    $adjacentConfiguration = 'str(?:\.w)?[^\n]*#12\][^\n]*\n[^\n]*str(?:\.w)?[^\n]*#8\][^\n]*\n[^\n]*str(?:\.w)?[^\n]*,\s*\[[^\],]+\]'
    Assert-Matches $configure $adjacentConfiguration "RTWDOG WIN/TOVAL/CS stores are not adjacent: $resolvedPath"

    Write-Host "RTWDOG protected codegen valid: $resolvedPath"
}
