function Get-FigFont {
    [CmdletBinding()]
    param(
        [string]$Name = "*",

        [string]$FontFolder
    )

    if(!$FontFolder) {
        $FontFolder = "$PSScriptRoot\fonts","$PSScriptRoot\..\fonts",".\fonts" | Where { Test-Path $_ }
    }
    Write-Verbose "Searching for a font matching '$Name' in $FontFolder"
    Get-ChildItem $FontFolder -Recurse -Filter *.flf -Include "$Name*.flf" |
        Select FullName -ExpandProperty BaseName |
        Sort
}