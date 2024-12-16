using namespace System.Collections.Generic
$input_file = Get-Content $PSScriptRoot\input.txt

function Get-MazeMapFromFile($File) {
    $map = [List[array]]::new()

    for ($line_counter = 0; $line_counter -lt $File.Length; $line_counter++) {
            $map.Add($File[$line_counter].ToCharArray())
    }

    return $map
}

$maze_map = Get-MazeMapFromFile $input_file
$start_y, $start_x = $maze_map | ForEach-Object -Begin {$row = 0} -Process {$index = ($_ -join "").IndexOf("S"); if ($index -ne -1) {return $row, $index}; $row++}
$end_y, $end_x = $maze_map | ForEach-Object -Begin {$row = 0} -Process {$index = ($_ -join "").IndexOf("E"); if ($index -ne -1) {return $row, $index}; $row++}


function Get-FindAllPaths($Map, $Y, $X, $EndY, $EndX) {
    $directions = @{
        ">" = @{y=0; x=1}
        "^" = @{y=-1; x=0}
        "<" = @{y=0; x=-1}
        "v" = @{y=1; x=0}
    }

    [Object[]]$queue = @()
    $queue += @{cost = 0; y = $Y; x = $X; direction = ">"; log = ""}
    $visited = @{}
    $all_paths = @()
    
    while ($queue.Count -gt 0) {
        $queue = $queue | Sort-Object cost
        $current = $queue[0]
        $queue = $queue[1..$queue.Count]

        if ($current.y -eq $EndY -and $current.x -eq $EndX) {$all_paths += @{totalcost=$current.cost; log=$current.log+"$($current.y).$($current.x);"}; continue}

        $visited["$($current.y).$($current.x).$($current.direction)"] = $true

        foreach ($dir in $directions.Keys) {
            $new_y = $current.y + $directions[$dir].y
            $new_x = $current.X + $directions[$dir].x

            if ($Map[$new_y][$new_x] -ne "#") {
                $new_cost = $current.cost + 1
                if ($dir -ne $current.direction) {$new_cost += 1000}

                if (-not $visited.ContainsKey("$new_y.$new_x.$dir")) {
                    $queue += @{cost = $new_cost; y = $new_y; x = $new_x; direction = $dir; log = $current.log + "$($current.y).$($current.x);"}
                }
            }
        }
    }

    return $all_paths
}

$all_paths = Get-FindAllPaths $maze_map $start_y $start_x $end_y $end_x

$minimal_cost = ($all_paths | Sort-Object -Top 1)["totalcost"]
$concat_log = $all_paths | Where-Object totalcost -eq $minimal_cost | ForEach-Object -Begin {$concat_log = ""} -Process {$concat_log += $_.log} -End {return $concat_log}
($concat_log.Trim(";") -split ";" | Sort-Object -Unique).Count
