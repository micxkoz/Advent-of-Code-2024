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
function Insert-Obstacle {
    param ([List[psobject]]$Map, [int]$Y, [int]$X, [int]$NumOfSteps)

    $map_height = $Map.Count
    $map_width = ($Map | Select-Object -First 1).Count
      
    <# Direction: [U]p [R]ight [D]own [L]eft #>
    $x_original = $X
    $y_original = $Y
    $Map[$Y][$X] = "U"
    
    $steps = 0
    $in_bound = $true
    while ($in_bound -and ($steps -lt $NumOfSteps)) {
        
        if ($Map[$Y][$X] -eq "U") {
            if ($Y-1 -lt 0) {$in_bound = $false; break}
            if ($Map[$Y-1][$X] -ne "#") {$Y--; $Map[$Y][$X] = "U"; $steps++}
            else {$Map[$Y][$X] = "R"}
        }
        
        if ($Map[$Y][$X] -eq "R") {
            if ($X+1 -ge $map_width) {$in_bound = $false; break}
            if ($Map[$Y][$X+1] -ne "#") {$X++; $Map[$Y][$X] = "R"; $steps++}
            else {$Map[$Y][$X] = "D"}
        }

        if ($Map[$Y][$X] -eq "D") {
            if ($Y+1 -ge $map_height) {$in_bound = $false; break}
            if ($Map[$Y+1][$X] -ne "#") {$Y++; $Map[$Y][$X] = "D"; $steps++}
            else {$Map[$Y][$X] = "L"}
        }

        if ($Map[$Y][$X] -eq "L") {
            if ($X-1 -lt 0) {$in_bound = $false; break}
            if ($Map[$Y][$X-1] -ne "#") {$X--; $Map[$Y][$X] = "L"; $steps++}
            else {$Map[$Y][$X] = "U"}
        }
    }
    $Map[$Y][$X] = "#"
    $Map[$y_original][$x_original] = "^"

    for ($i = 0; $i -lt $map_height; $i++) {
         $Map[$i] = $Map[$i] -replace "[URDL]", "."
    }
    return $Map, $Y, $X
}
function Detect-Loop {
    param ([List[psobject]]$Map, [int]$Y, [int]$X)

    $map_height = $Map.Count
    $map_width = ($Map | Select-Object -First 1).Count
    $max_counter = $map_height * $map_width
    Write-Host $max_counter
    
    <# Direction: [U]p [R]ight [D]own [L]eft #>
    $Map[$Y][$X] = "U"
    
    $in_bound = $true
    $looped = $false
    $counter = 0
    while ($in_bound -and (-not $looped)) {
        
        if ($Map[$Y][$X] -eq "U") {
            if ($Y-1 -lt 0) {$in_bound = $false; break}
            if ($Map[$Y-1][$X] -ne "#") {$Y--; $Map[$Y][$X] = "U"}
            else {
                $Map[$Y][$X] = "R"
                if ($Map[$Y][$X+1] -eq "R") {$looped = $true; break}
                if ($Map[$Y][$X+1] -eq "L" -and $counter -ge $max_counter) {$looped = $true; break}
                if ($Map[$Y][$X] -eq "R" -and $Map[$Y][$X+1] -eq "D" -and $Map[$Y+1][$X+1] -eq "L" -and $Map[$Y+1][$X] -eq "U" `
                -and $Map[$Y-1][$X] -eq "#" -and $Map[$Y][$X+2] -eq "#" -and $Map[$Y+2][$X+1] -eq "#" -and $Map[$Y+1][$X-1] -eq "#" ) {$looped = $true; break}
            }
        }
        
        if ($Map[$Y][$X] -eq "R") {
            if ($X+1 -ge $map_width) {$in_bound = $false; break}
            if ($Map[$Y][$X+1] -ne "#") {$X++; $Map[$Y][$X] = "R"}
            else {
                $Map[$Y][$X] = "D"
                if ($Map[$Y+1][$X] -eq "D") {$looped = $true; break}
                if ($Map[$Y+1][$X] -eq "U" -and $counter -ge $max_counter) {$looped = $true; break}
            }
        }

        if ($Map[$Y][$X] -eq "D") {
            if ($Y+1 -ge $map_height) {$in_bound = $false; break}
            if ($Map[$Y+1][$X] -ne "#") {$Y++; $Map[$Y][$X] = "D"}
            else {
                $Map[$Y][$X] = "L"
                if ($Map[$Y][$X-1] -eq "L") {$looped = $true; break}
                if ($Map[$Y][$X-1] -eq "R" -and $counter -ge $max_counter) {$looped = $true; break}
            }
        }

        if ($Map[$Y][$X] -eq "L") {
            if ($X-1 -lt 0) {$in_bound = $false; break}
            if ($Map[$Y][$X-1] -ne "#") {$X--; $Map[$Y][$X] = "L"}
            else {
                $Map[$Y][$X] = "U"; 
                if ($Map[$Y-1][$X] -eq "U") {$looped = $true; break}
                if ($Map[$Y-1][$X] -eq "D" -and $counter -ge $max_counter) {$looped = $true; break}
            }
        }

        $counter++
    }
    return $looped   
}

$prev_obstacle_y = $null; $prev_obstacle_x = $null
$obstacles = @()

for ($i = 0; $true; $i++) {
      
    $original_map, $start_y, $start_x = Prepare-Map($input_file)
    $map_variant, $obstacle_y, $obstacle_x = Insert-Obstacle $original_map $start_y $start_x $i
    if (Detect-Loop $map_variant $start_y $start_x) {$obstacles += "$obstacle_y,$obstacle_x"}


    if ($obstacle_y -eq $prev_obstacle_y -and $obstacle_x -eq $prev_obstacle_x) {break}
    $prev_obstacle_y = $obstacle_y; $prev_obstacle_x = $obstacle_x
}

($obstacles | Sort-Object -Unique).Count
