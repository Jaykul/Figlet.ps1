function Get-ColorGradient {
    <#
    .Synopsis
        Get a range of colors from one or more colors
    #>
    [CmdletBinding()]
    param(
        # One or more colors to generate a gradient from
        [Parameter(Mandatory)]
        [Drawing.Color[]]$Color,

        [int]$Height = $Host.UI.RawUI.WindowSize.Height,

        [int]$Width = $Host.UI.RawUI.WindowSize.Width
    )
    $Colors = new-object Drawing.Color[][] $Height,$Width
    $C = [PSCustomObject]@{R = 0; G = 0; B = 0}
    # If we're not doing a color scale, we can return immediately:
    if($Color.Count -eq 1) {
        for($r=0;$r-lt$Height;$r++){
            for($c=0;$c-lt$Width;$c++){
                $Colors[$r][$c] = $Color[0]
            }
        }
    } else {
        $Diff = @(
            [PSCustomObject]@{ Color="R"
                Abs = [Math]::Abs($Color[0].R - $Color[-1].R)
                Min = [Math]::Min($Color[0].R, $Color[-1].R)
                Diff = $Color[-1].R - $Color[0].R
                First = $Color[0].R
            }
            [PSCustomObject]@{ Color="G"
                Abs = [Math]::Abs($Color[0].G - $Color[-1].G)
                Min = [Math]::Min($Color[0].G, $Color[-1].G)
                Diff = $Color[-1].G - $Color[0].G
                First = $Color[0].G
            }
            [PSCustomObject]@{ Color="B"
                Abs = [Math]::Abs($Color[0].B - $Color[-1].B)
                Min = [Math]::Min($Color[0].B, $Color[-1].B)
                Diff = $Color[-1].B - $Color[0].B
                First = $Color[0].B
            }
        ) | Sort-Object Abs -Descending

        Write-Verbose ($Diff| Out-String)

        # Generate colors
        $C.($Diff[2].Color) = [int]($Diff[2].Min + ($Diff[2].Abs/2))
        for ($Line = 0; $Line -lt $Height; $Line++) {
            $C.($Diff[1].Color) = [int](($Line * $Diff[1].Diff / ($Height-1)) + $Diff[1].First)

            for ($Column = 0; $Column -lt $Width; $Column++) {
                # we need a gradient with as many steps in it as there are characters in buffer size
                $C.($Diff[0].Color) = [int]((($Column * $Diff[0].Diff) / ($Width-1)) + $Diff[0].First )
                $Colors[$Line][$Column] =  "{0},{1},{2}" -f $C.R, $C.G, $C.B
            }
        }
    }

    ,$Colors
}
