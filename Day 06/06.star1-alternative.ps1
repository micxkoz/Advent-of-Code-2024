using namespace System.Collections.Generic
$input_file = Get-Content $PSScriptRoot\input.txt

function Prepare-Map {
    param ($File)

    $map = [List[psobject]]::new()
    $y_counter = 0
    foreach ($line in $File) {
        $map.Add([char[]]$line)
        if ($line.IndexOf("^") -ge 0) {$pos_y = $y_counter; $pos_x = $line.IndexOf("^")}
        $y_counter++  
    }

    return $map, $pos_y, $pos_x
}

function Trace-Route {
    [CmdletBinding()]
    param ([List[psobject]]$Map, [int]$Y, [int]$X)

    $y_max = $Map.Count
    $x_max = ($Map | Select-Object -First 1).Count
        
    <# Direction: [U]p [R]ight [D]own [L]eft #>
    $Map[$Y][$X] = "U"
    
    $inbound = $true
    while ($inbound) {
        if ($inbound -and $Map[$Y][$X] -eq "U") {
            while ($Map[$Y-1][$X] -ne "#") {
                $Y--
                $Map[$Y][$X] = "U"
                if ($Y-1 -lt 0) {$inbound = $false; break}
            }   
            $Map[$Y][$X] = "R"
        }
        if ($inbound -and $Map[$Y][$X] -eq "R") {
            while ($Map[$Y][$X+1] -ne "#") {
                $X++
                $Map[$Y][$X] = "R"
                if ($X+1 -ge $x_max) {$inbound = $false; break}
            }
            $Map[$Y][$X] = "D"
        }
        if ($inbound -and $Map[$Y][$X] -eq "D") {
            while ($Map[$Y+1][$X] -ne "#") {
                $Y++
                $Map[$Y][$X] = "D"
                if ($Y+1 -ge $y_max) {$inbound = $false; break}
            }
            $Map[$Y][$X] = "L"
        }
        if ($inbound -and $Map[$Y][$X] -eq "L") {
            while ($Map[$Y][$X-1] -ne "#") {
                $X--
                $Map[$Y][$X] = "L"
                if ($X-1 -lt 0) {$inbound = $false; break}
            }
            $Map[$Y][$X] = "U"
        }
    }

    return $Map
}

$original_map, $start_y, $start_x = Prepare-Map($input_file)

$traced_map = Trace-Route -Map $original_map -Y $start_y -X $start_x

$traced_map | ForEach-Object {$_ -join ""}

$traced_map | ForEach-Object `
    -Begin {$result = 0} `
    -Process {$result += ($_ | Where-Object {$_ -match "[URDL]"}).Count} `
    -End {return $result}