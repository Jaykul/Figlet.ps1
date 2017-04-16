
function Write-Gradient {
param([Drawing.Color[]]$Colors = @("Red","Blue"), $w = 10, $h = 1)
    ## $colors =  #| % { $_ } | fw { $_.R, $_.G, $_.B } -col $w
    foreach($row in (Get-ColorGradient $Colors -h $h -w $w)){
        foreach($c in $row) {
            "$(New-Text ("{0,3},{1,3},{2,3}" -f $c.R, $c.G, $c.B) -BackgroundColor $c) "
        }
        write-host
    }
}