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


function Get-FindPath($Map, $Y, $X, $EndY, $EndX) {
    $directions = @{
        ">" = @{y=0; x=1}
        "^" = @{y=-1; x=0}
        "<" = @{y=0; x=-1}
        "v" = @{y=1; x=0}
    }

    [Object[]]$queue = @()
    $queue += @{cost = 0; y = $Y; x = $X; direction = ">"}
    $visited = @{}
    $costs = @()
    
    while ($queue.Count -gt 0) {
        $queue = $queue | Sort-Object cost
        $current = $queue[0]
        $queue = $queue[1..$queue.Count]

        if ($current.y -eq $EndY -and $current.x -eq $EndX) {$costs += $current.Cost; continue}

        $visited["$($current.y).$($current.x)"] = $true

        foreach ($dir in $directions.Keys) {
            $new_y = $current.y + $directions[$dir].y
            $new_x = $current.X + $directions[$dir].x

            if ($Map[$new_y][$new_x] -ne "#") {
                $new_cost = $current.cost + 1
                if ($dir -ne $current.direction) {$new_cost += 1000}

                if (-not $visited.ContainsKey("$new_y.$new_x")) {
                    $queue += @{cost = $new_cost; y = $new_y; x = $new_x; direction = $dir}
                }
            }
        }
    }

    return $costs | Sort-Object | Select-Object -First 1
}

Get-FindPath $maze_map $start_y $start_x $end_y $end_x
