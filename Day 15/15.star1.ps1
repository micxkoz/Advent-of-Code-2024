using namespace System.Collections.Generic
$input_file = Get-Content $PSScriptRoot\input.txt

function Get-ParsedDataFromFile($File) {
    $map = [List[array]]::new()
    $line_number = 0
    foreach ($line in $File) {
        if ($line -eq "") {break}
        
        if ((Select-String -InputObject $line -Pattern "@").Matches.Success) {
            $robot_y = $line_number
            $robot_x = (Select-String -InputObject $line -Pattern "@").Matches.Index
        }
        $line_number++
        
        $map.Add($line.ToCharArray())
    }
    $movements = (Select-String -InputObject $File -Pattern "(?s)[v<^>]{1}.*[v<^>]").Matches -replace " ", ""

    return $map, $movements, $robot_y, $robot_x
}

function Get-MapAfterMovement($Map, $Y, $X, $Move) {
    $map_height = $Map.Count-1
    $map_width = $Map[1].Count-1
    $robot_y = $Y
    $robot_x = $X

    if ($Move -eq "left" -and ((0..$X | ForEach-Object {$Map[$Y][$_]} | Join-String | Select-String "O*\.O*@").Matches.Success)) { 
        $next_pos_value = "."
        $pos_value = $null
        
        foreach($pos in $X..0) {
            $pos_value = $Map[$Y][$pos]
            $Map[$Y][$pos] = $next_pos_value
            $next_pos_value = $pos_value
            if ($next_pos_value -eq ".") {break}
        }
        $robot_x--
    }
          
    if ($Move -eq "right" -and (($X..$map_width | ForEach-Object {$Map[$Y][$_]} | Join-String | Select-String "@O*\.O*").Matches.Success)) {
        $next_pos_value = "."
        $pos_value = $null
        
        foreach($pos in $X..$map_width) {
            $pos_value = $Map[$Y][$pos]
            $Map[$Y][$pos] = $next_pos_value
            $next_pos_value = $pos_value
            if ($next_pos_value -eq ".") {break}
        }
        $robot_x++
    }

    if ($Move -eq "up" -and ((0..$Y | ForEach-Object {$Map[$_][$X]} | Join-String | Select-String "O*\.O*@").Matches.Success)) {
        $next_pos_value = "."
        $pos_value = $null
        
        foreach($pos in $Y..0) {
            $pos_value = $Map[$pos][$X]
            $Map[$pos][$X] = $next_pos_value
            $next_pos_value = $pos_value
            if ($next_pos_value -eq ".") {break}
        }
        $robot_y--
    }
    
    if ($Move -eq "down" -and (($Y..$map_height | ForEach-Object {$Map[$_][$X]} | Join-String | Select-String "@O*\.O*").Matches.Success)) {
        $next_pos_value = "."
        $pos_value = $null
        
        foreach($pos in $Y..$map_height) {
            $pos_value = $Map[$pos][$X]
            $Map[$pos][$X] = $next_pos_value
            $next_pos_value = $pos_value
            if ($next_pos_value -eq ".") {break}
        }
        $robot_y++
    }

    return $Map, $robot_y, $robot_x
}

function Get-SumGPSCoordinates($Map) {
    $sum = 0
    for ($y = 0; $y -lt $Map.Count; $y++) {
        for ($x = 0; $x -lt $Map[$y].Count; $x++) {
            if ($Map[$y][$x] -eq "O") { $sum += $y * 100 + $x }
        }
    }
    return $sum
}

$warehouse_map, $list_of_movements, $robot_position_y, $robot_position_x = Get-ParsedDataFromFile $input_file
#$warehouse_map | ForEach-Object {$_ -join ""}

foreach ($move in $list_of_movements.ToCharArray()) {
    if ($move -eq "<") {$next_move = "left"}
    if ($move -eq "v") {$next_move = "down"}
    if ($move -eq ">") {$next_move = "right"}
    if ($move -eq "^") {$next_move = "up"}

    $warehouse_map, $robot_position_y, $robot_position_x = Get-MapAfterMovement $warehouse_map $robot_position_y $robot_position_x $next_move
    #$warehouse_map | ForEach-Object {$_ -join ""}
}
#$warehouse_map | ForEach-Object {$_ -join ""}

Get-SumGPSCoordinates $warehouse_map


