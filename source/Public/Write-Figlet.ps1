function Write-Figlet {
    <#
    .Synopsis
        Write text using FIGfonts, optionally using colors
    #>
    [CmdletBinding()]
    param(
        # The text to write (this needs to be short)
        [Parameter(Mandatory)]
        [string]$Text,

        # The font to use FIGfont file (*.flf) should exist in a "Fonts" subfolder
        [string]$FontName = "epic",

        [Drawing.Color[]]$Background,

        [Drawing.Color[]]$Foreground
    )

    $Figlet = [Figlet.Net.Figlet]::New()
    if($Font = Get-FigFont $FontName) {
        $Figlet.LoadFont($Font.FullName)
    }

    # Pad the text with a space on all sides
    $Ascii = @("  ") + @($Figlet.ToAsciiArt($Text) -split "[\r\n]+").ForEach{ if($_.Trim()) { " $_ " } } + @("  ")
    $Height = $Ascii.Length
    $Width = [System.Linq.Enumerable]::Max($Ascii.ForEach{ $_.Length })
    # Make sure all the lines are the same length
    $Ascii = $Ascii.ForEach{ $_.PadRight($Width) }

    if($Null -eq $Background -and $Null -eq $Foreground) {
        $Ascii | Write-Host
        return
    }

    if(!(Get-Command Write-HostAnsi)) {
        Write-Warning "Pansies module not available"
        $Ascii | Write-Host
        return
    }

    # Run cycles of colors

    if($Background) { [Drawing.Color[][]]$Background = Get-ColorGradient $Background -Height $Height -Width $Width }
    if($Foreground) { [Drawing.Color[][]]$Foreground = Get-ColorGradient $Foreground -Height $Height -Width $Width }

    Write-Verbose ("" + $Foreground.Count + " of " + $Foreground[0].Count)

    for ($Line = 0; $Line -lt $Height; $Line++) {
        Write-Host -NoNewLine (([char]27)+"[m")
        for ($Column = 0; $Column -lt $Width; $Column++) {

            if($Background -and $Foreground) {
                Write-HostAnsi ($Ascii[$Line][$Column]) -NoNewLine -Background ($Background[$line][$Column]) -Foreground ($Foreground[$line][$Column])
            } elseif($Background) {
                Write-HostAnsi ($Ascii[$Line][$Column]) -NoNewLine -Background ($Background[$line][$Column])
            } elseif($Foreground) {
                Write-HostAnsi ($Ascii[$Line][$Column]) -NoNewLine -Foreground ($Foreground[$line][$Column])
            }
        }
        Write-Host (([char]27)+"[m")
    }

}