using namespace System.Collections.Generic
$input_file = Get-Content $PSScriptRoot\input.txt
$vertical_range = 71
$horizontal_range = 71
$simulation_length = 1024

function Get-GridFromFile($File, $Height, $Width, $NumOfBytes) {
    $grid = [List[array]]::new()
    1..$Height | ForEach-Object {$grid.Add($("." * $Width).ToCharArray())}

    $byte_counter = 0
    foreach ($line in $File) {
        $x, $y = $line -split ","
        $grid[$y][$x] = "#"

        $byte_counter++
        if ($byte_counter -ge $NumOfBytes) {return $grid}
    }

    Write-Error "NumOfBytes is larger then number of bytes in the file"
}

function Get-ShortestPath([object[][]]$Grid, [int]$Height, [int]$Width) {
    $end = @{x=$Width-1; y=$Height-1}

    [Object[]]$queue = @()
    $queue = @(@{x=0; y=0})

    $cost_to_reach = @{}
    $estimated_cost = @{}
    for ($y = 0; $y -lt $Height; $y++) {
        for ($x = 0; $x -lt $Width; $x++) {
            $cost_to_reach["$x,$y"] = -1
            $estimated_cost["$x,$y"] = -1
        }
    }

    $directions = @(@{x=0;y=-1},@{x=0;y=1},@{x=-1;y=0},@{x=1;y=0})

    $cost_to_reach["0,0"] = 0
    $estimated_cost["0,0"] = [Math]::Abs(0-$end.x) + [Math]::Abs(0-$end.y)
    
    while ($queue.Count -gt 0) {
        $current = $queue | Sort-Object {$estimated_cost["$($_.x),$($_.y)"]} | Select-Object -First 1
                
        if ($current.x -eq $end.x -and $current.y -eq $end.y) {return $cost_to_reach["$($current.x),$($current.y)"]}

        $queue = $queue | Where-Object {$_.x -ne $current.x -or $_.y -ne $current.y}

        foreach ($dir in $directions) {
            $next_x = $current.x + $dir.x
            $next_y = $current.y + $dir.y

            if ($next_x -ge 0 -and $next_x -lt $Width -and $next_y -ge 0 -and $next_y -lt $Height -and $Grid[$next_y][$next_x] -ne "#") {
                $next_cost = $cost_to_reach["$($current.x),$($current.y)"] + 1
                

                if ($cost_to_reach["$next_x,$next_y"] -eq -1 -or $next_cost -lt $cost_to_reach["$next_x,$next_y"]) {
                    $cost_to_reach["$next_x,$next_y"] = $next_cost
                    $estimated_cost["$next_x,$next_y"] = $next_cost + [Math]::Abs($next_x-$end.x) + [Math]::Abs($next_y-$end.y)

                    if (($queue | Where-Object {$_.x -eq $next_x -and $_.y -eq $next_y}).Count -eq 0) {$queue += @{x=$next_x; y=$next_y}}
                }
            }
        }
    }
    return $null
}

$memory_space = Get-GridFromFile $input_file $vertical_range $horizontal_range $simulation_length
#$memory_space | ForEach-Object {$_ -join ""}
Get-ShortestPath $memory_space $vertical_range $horizontal_range