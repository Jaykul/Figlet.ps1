using namespace PoshCode.Pansies
function Get-ColorGradient {
    <#
    .Synopsis
        Get a range of colors from one or more colors
    #>
    [CmdletBinding()]
    param(
        # One or more colors to generate a gradient from
        [Parameter(Mandatory)]
        [Color[]]$Color,

        [int]$Height = $Host.UI.RawUI.WindowSize.Height,

        [int]$Width = $Host.UI.RawUI.WindowSize.Width
    )
    $Colors = new-object Color[][] $Height,$Width
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
        $DH = [Math]::Max(1,$Height-1)
        $DW = [Math]::Max(1,$Width-1)


        # Generate the gradiens with as many steps in it as the size
        $C.($Diff[2].Color) = [int]($Diff[2].Min + ($Diff[2].Abs/2))
        for ($Line = 0; $Line -lt $Height; $Line++) {
            # the height is usually the short side on Windows
            # $Diff[1] is the second biggest color range
            $C.($Diff[1].Color) = [int](($Line * $Diff[1].Diff / $DH) + $Diff[1].First)

            for ($Column = 0; $Column -lt $Width; $Column++) {
                # we need a gradient with as many steps in it as the size
                # the width is usually the long side on Windows
                # $Diff[0] is the biggest color range
                $C.($Diff[0].Color) = [int]((($Column * $Diff[0].Diff) / $DW) + $Diff[0].First )
                #$C.($Diff[2].Color) = [int]((($Column * $Diff[2].Diff) / $DW) + $Diff[2].First )
                $Colors[$Line][$Column] =  [Color]::new($C.R, $C.G, $C.B)
            }
        }
    }

    ,$Colors
}
