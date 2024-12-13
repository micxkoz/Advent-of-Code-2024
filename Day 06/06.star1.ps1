using namespace System.Collections.Generic
$file = Get-Content $PSScriptRoot\input.txt

$map = [List[psobject]]::new()
$y_counter = 0
foreach ($line in $file) {
    $map.Add([char[]]$line)
    if ($line.IndexOf("^") -ge 0) {$pos_y = $y_counter; $pos_x = $line.IndexOf("^")}
    $y_counter++  
}

$y_max = $file.Length
$x_max = $line.Length

<# Direction: [U]p [R]ight [D]own [L]eft #>
$map[$pos_y][$pos_x] = "U"

$inbound = $true
while ($inbound) {
    if ($inbound -and $map[$pos_y][$pos_x] -eq "U") {
        while ($map[$pos_y-1][$pos_x] -ne "#") {
            $pos_y--
            $map[$pos_y][$pos_x] = "U"
            if ($pos_y-1 -lt 0) {$inbound = $false; break}
        }   
        $map[$pos_y][$pos_x] = "R"
    }
    if ($inbound -and $map[$pos_y][$pos_x] -eq "R") {
        while ($map[$pos_y][$pos_x+1] -ne "#") {
            $pos_x++
            $map[$pos_y][$pos_x] = "R"
            if ($pos_x+1 -ge $x_max) {$inbound = $false; break}
        }
        $map[$pos_y][$pos_x] = "D"
    }
    if ($inbound -and $map[$pos_y][$pos_x] -eq "D") {
        while ($map[$pos_y+1][$pos_x] -ne "#") {
            $pos_y++
            $map[$pos_y][$pos_x] = "D"
            if ($pos_y+1 -ge $y_max) {$inbound = $false; break}
        }
        $map[$pos_y][$pos_x] = "L"
    }
    if ($inbound -and $map[$pos_y][$pos_x] -eq "L") {
        while ($map[$pos_y][$pos_x-1] -ne "#") {
            $pos_x--
            $map[$pos_y][$pos_x] = "L"
            if ($pos_x-1 -lt 0) {$inbound = $false; break}
        }
        $map[$pos_y][$pos_x] = "U"
    }
}

#$map | ForEach-Object {$_ -join ""}

$map | ForEach-Object `
    -Begin {$result = 0} `
    -Process {$result += ($_ | Where-Object {$_ -match "[URDL]"}).Count} `
    -End {return $result}
