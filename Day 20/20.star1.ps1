using namespace System.Collections.Generic
$input_file = Get-Content $PSScriptRoot\input.txt

function Get-RacetrackFromFile($File) {
    
    $racetrack = [List[string[]]]::new()
    foreach ($line in $File) {
        $racetrack.Add($line.ToCharArray())
    }
    return $racetrack
}


function Get-ShortestPath($Racetrack, $ReturnHistory) {
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
            if ($ReturnHistory) {
                $path = @()
                $step_coordinates = "$($current.x),$($current.y)"
                while ($path_history.ContainsKey($step_coordinates)) {
                    $path += $step_coordinates
                    $step_coordinates = $path_history[$step_coordinates]
                }
                $path += $step_coordinates
                return $cost_to_reach["$($current.x),$($current.y)"], $path
            }
            else {
                return $cost_to_reach["$($current.x),$($current.y)"]
            }
        }

        $queue = $queue | Where-Object {$_.x -ne $current.x -or $_.y -ne $current.y}

        foreach ($dir in $directions) {
            $next_x = $current.x + $dir.x
            $next_y = $current.y + $dir.y

            if ($next_x -ge 0 -and $next_x -lt $racetrack_width -and $next_y -ge 0 -and $next_y -lt $racetrack_height -and $Racetrack[$next_y][$next_x] -ne "#") {
                    
                $next_cost = $cost_to_reach["$($current.x),$($current.y)"] + 1                            
                                    
                if ($cost_to_reach["$next_x,$next_y"] -eq -1 -or $next_cost -lt $cost_to_reach["$next_x,$next_y"]) {

                    if ($ReturnHistory) {$path_history["$next_x,$next_y"] = "$($current.x),$($current.y)"}
                    $cost_to_reach["$next_x,$next_y"] = $next_cost
                    $estimated_cost["$next_x,$next_y"] = $next_cost + [Math]::Abs($next_x-$end.x) + [Math]::Abs($next_y-$end.y)

                    if (($queue | Where-Object {$_.x -eq $next_x -and $_.y -eq $next_y}).Count -eq 0) {$queue += @{x=$next_x; y=$next_y}}
                }  
            }
        }
    }
    return -1
}

$racetrack = Get-RacetrackFromFile $input_file

$cost_without_cheating, $step_history = Get-ShortestPath $racetrack $true
$cheats_to_try = @()
$costs_with_cheating = @()

foreach ($step in $step_history) {
    [int]$x, [int]$y = $step -split ","
    if ($racetrack[$y-1][$x] -eq "#") {$cheats_to_try += "$x,$($y-1)"}
    if ($racetrack[$y+1][$x] -eq "#") {$cheats_to_try += "$x,$($y+1)"}
    if ($racetrack[$y][$x-1] -eq "#") {$cheats_to_try += "$($x-1),$y"}
    if ($racetrack[$y][$x+1] -eq "#") {$cheats_to_try += "$($x+1),$y"}
}

$cheats_to_try = $cheats_to_try | Sort-Object -Unique

$cheats_to_try.Count
$counter = 1
foreach ($cheat in $cheats_to_try) {
    Write-Host "$counter/$($cheats_to_try.Count)"
    $counter++
    
    [int]$x, [int]$y = $cheat -split ","
    $racetrack_copy = Get-RacetrackFromFile $input_file
    $racetrack_copy[$y][$x] = "."
    $cost = Get-ShortestPath $racetrack_copy $false
    if ($cost -ne -1) {$costs_with_cheating += $cost} 
}

#($costs_with_cheating | Where-Object {$_ -ne $cost_without_cheating}).Count
($costs_with_cheating | Where-Object {$($cost_without_cheating - $_) -ge 100}).Count
