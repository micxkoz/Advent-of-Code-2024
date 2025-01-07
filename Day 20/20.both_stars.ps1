using namespace System.Collections.Generic
$input_file = Get-Content $PSScriptRoot\input.txt
function Get-RacetrackFromFile($File) {
    
    $racetrack = [List[string[]]]::new()
    foreach ($line in $File) {
        $racetrack.Add($line.ToCharArray())
    }
    return $racetrack
}

function Get-ShortestPath($Racetrack) {
    $start_y, $start_x = $racetrack | ForEach-Object -Begin {$row = 0} -Process {$index = ($_ -join "").IndexOf("S"); if ($index -ne -1) {return $row, $index}; $row++}
    $end_y, $end_x = $racetrack | ForEach-Object -Begin {$row = 0} -Process {$index = ($_ -join "").IndexOf("E"); if ($index -ne -1) {return $row, $index}; $row++}

    $start = @{x=$start_x; y=$start_y}
    $end = @{x=$end_x; y=$end_y}

    $racetrack_height = $Racetrack.Length
    $racetrack_width = $Racetrack[0].Length

    [Object[]]$queue = @()
    $queue = @($start)
    $path_history = @{}

    $cost_to_reach = @{}
    $estimated_cost = @{}
    
    for ($y = 0; $y -lt $racetrack_height; $y++) {
        for ($x = 0; $x -lt $racetrack_width; $x++) {
            $cost_to_reach["$x,$y"] = -1
            $estimated_cost["$x,$y"] = -1
        }
    }
    
    $directions = @(@{x=0; y=-1}, @{x=0; y=1}, @{x=-1; y=0}, @{x=1; y=0})

    $cost_to_reach["$($start.x),$($start.y)"] = 0
    $estimated_cost["$($start.x),$($start.y)"] = [Math]::Abs(0-$end.x) + [Math]::Abs(0-$end.y)
    
    while ($queue.Count -gt 0) {
        $current = $queue | Sort-Object {$estimated_cost["$($_.x),$($_.y)"]} | Select-Object -First 1
                
        if ($current.x -eq $end.x -and $current.y -eq $end.y) {
            $path = [List[string]]::new()
            $step_coordinates = "$($current.x),$($current.y)"
            while ($path_history.ContainsKey($step_coordinates)) {
                $path.Add($step_coordinates)
                $step_coordinates = $path_history[$step_coordinates]
            }
            $path.Add($step_coordinates)
            return $cost_to_reach["$($current.x),$($current.y)"], $path
        }

        $queue = $queue | Where-Object {$_.x -ne $current.x -or $_.y -ne $current.y}

        foreach ($dir in $directions) {
            $next_x = $current.x + $dir.x
            $next_y = $current.y + $dir.y

            if ($next_x -ge 0 -and $next_x -lt $racetrack_width -and $next_y -ge 0 -and $next_y -lt $racetrack_height -and $Racetrack[$next_y][$next_x] -ne "#") {
                    
                $next_cost = $cost_to_reach["$($current.x),$($current.y)"] + 1                            
                                    
                if ($cost_to_reach["$next_x,$next_y"] -eq -1 -or $next_cost -lt $cost_to_reach["$next_x,$next_y"]) {

                    $path_history["$next_x,$next_y"] = "$($current.x),$($current.y)"
                    $cost_to_reach["$next_x,$next_y"] = $next_cost
                    $estimated_cost["$next_x,$next_y"] = $next_cost + [Math]::Abs($next_x-$end.x) + [Math]::Abs($next_y-$end.y)

                    if (($queue | Where-Object {$_.x -eq $next_x -and $_.y -eq $next_y}).Count -eq 0) {$queue += @{x=$next_x; y=$next_y}}
                }  
            }
        }
    }
    return -1
}

function Get-BestCheats($MaxCheatLength, $StepHistory, $RacetrackWidth, $RacetrackHeight) {
    $cheat_directions = @()
    for ($x = -$MaxCheatLength; $x -le $MaxCheatLength; $x++) {
        for ($y = -$MaxCheatLength; $y -le $MaxCheatLength; $y++) {
            $cheat_length = [Math]::Abs($x) + [Math]::Abs($y)
            if ($cheat_length -le $MaxCheatLength) {$cheat_directions += @{x=$x; y=$y; length=$cheat_length}}
        }
    }

    $counter = 0
    for($step = 0; $step -lt $StepHistory.Count; $step++) {
        $x, $y = $StepHistory[$step] -split ","
        foreach ($dir in $cheat_directions) {
            $next_x = [int]$x + $dir.x
            $next_y = [int]$y + $dir.y
            if ($next_x -ge 0 -and $next_x -lt $RacetrackWidth -and $next_y -ge 0 -and $next_y -lt $RacetrackHeight) {
                $index_of = $StepHistory.IndexOf("$next_x,$next_y")
                if ($index_of -ne -1 -and $index_of -gt $step -and ($index_of - $step) -ne $dir.length) {
                    if ($index_of - $step - $dir.length -ge 100) {$counter++}
                }
            }
        }
    }
    return $counter    
}

$racetrack = Get-RacetrackFromFile $input_file

$racetrack_height = $racetrack.Length
$racetrack_width = $racetrack[0].Length

$cost_without_cheating, $step_history = Get-ShortestPath $racetrack
Write-Host "Cost without cheating: $cost_without_cheating"
$part1 = Get-BestCheats 2 $step_history $racetrack_width $racetrack_height
Write-Host "Part 1: $part1"
$part2 = Get-BestCheats 20 $step_history $racetrack_width $racetrack_height
Write-Host "Part 2: $part2"