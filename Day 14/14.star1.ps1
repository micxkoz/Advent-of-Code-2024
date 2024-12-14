using namespace System.Collections.Generic
$input_file = Get-Content $PSScriptRoot\input.txt

function Get-RobotsDataFromFile ($File) {
    $robots_data = [List[array]]::new()

    foreach ($line in $File) {
        $robot_specification = [List[int]]::new()

        $values_from_line = (Select-String -InputObject $line -Pattern "p=(\d+),(\d+) v=([-]?\d+),([-]?\d+)").Matches.Groups.Value
        
        $robot_specification.Add([int]$values_from_line[2])
        $robot_specification.Add([int]$values_from_line[1])
        $robot_specification.Add([int]$values_from_line[4])
        $robot_specification.Add([int]$values_from_line[3])
    
        $robots_data.Add($robot_specification)
    }

    return $robots_data
}

function Get-BlankMap ([int]$MapHeight, [int]$MapWidth) {
    $blank_map = [List[array]]::new()
    for ($row = 0; $row -lt $MapHeight; $row++) {
        $blank_map.Add(@("0") * $MapWidth)
    }
    return $blank_map
}

function Get-MapWithRobotsPositions([object]$Map, [object]$RobotsData) {
    foreach ($robot in $RobotsData) {
        [int]$Map[$($robot[0])][$($robot[1])] += 1
    }
    return $Map
}

function Get-RobotsPositionsAfterSeconds([object]$RobotsData, [int]$MapHeight, [int]$MapWidth, [int]$Seconds) {
    
    for ($number = 0; $number -lt $RobotsData.Count; $number++) {
        $RobotsData[$number][0] = ([int]$RobotsData[$number][0] + [int]$RobotsData[$number][2] * $Seconds) % $MapHeight
        if ($RobotsData[$number][0] -lt 0) {$RobotsData[$number][0] = $MapHeight + $RobotsData[$number][0]}

        $RobotsData[$number][1] = ([int]$RobotsData[$number][1] + [int]$RobotsData[$number][3] * $Seconds) % $MapWidth
        if ($RobotsData[$number][1] -lt 0) {$RobotsData[$number][1] = $MapWidth + $RobotsData[$number][1]}
    }
    return $RobotsData
}

function Get-SafetyFactor([object]$RobotsData, [int]$MapHeight, [int]$MapWidth) {
    $up_left, $up_right, $down_left, $down_right = 0

    for ($number = 0; $number -lt $RobotsData.Count; $number++) {
        if ($RobotsData[$number][0] -lt [Math]::Floor($MapHeight / 2) -and $RobotsData[$number][1] -lt [Math]::Floor($MapWidth / 2)) {$up_left++}
        if ($RobotsData[$number][0] -lt [Math]::Floor($MapHeight / 2) -and $RobotsData[$number][1] -ge [Math]::Ceiling($MapWidth / 2)) {$up_right++}
        if ($RobotsData[$number][0] -ge [Math]::Ceiling($MapHeight / 2) -and $RobotsData[$number][1] -lt [Math]::Floor($MapWidth / 2)) {$down_left++}
        if ($RobotsData[$number][0] -ge [Math]::Ceiling($MapHeight / 2) -and $RobotsData[$number][1] -ge [Math]::Ceiling($MapWidth / 2)) {$down_right++}
    }
    
    return $up_left * $up_right * $down_left * $down_right
}

$height = 103
$width = 101

$robots_data = Get-RobotsDataFromFile $input_file

$blank_map = Get-BlankMap $height $width

$robots_positions = Get-RobotsPositionsAfterSeconds $robots_data $height $width 100

#$map_with_robots = Get-MapWithRobotsPositions $blank_map $robots_positions
#$map_with_robots | ForEach-Object {$_ -replace "0", "." -join ""}

Get-SafetyFactor $robots_positions $height $width