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

function Get-RobotsPositionsAfterOneSecond([object]$RobotsData, [int]$MapHeight, [int]$MapWidth) {
    
    for ($number = 0; $number -lt $RobotsData.Count; $number++) {
        $RobotsData[$number][0] = ([int]$RobotsData[$number][0] + [int]$RobotsData[$number][2]) % $MapHeight
        if ($RobotsData[$number][0] -lt 0) {$RobotsData[$number][0] = $MapHeight + $RobotsData[$number][0]}

        $RobotsData[$number][1] = ([int]$RobotsData[$number][1] + [int]$RobotsData[$number][3]) % $MapWidth
        if ($RobotsData[$number][1] -lt 0) {$RobotsData[$number][1] = $MapWidth + $RobotsData[$number][1]}
    }
    
    return $RobotsData
}

function Get-BlankMap ([int]$MapHeight, [int]$MapWidth) {
    $blank_map = [List[array]]::new()
    for ($row = 0; $row -lt $MapHeight; $row++) {
        $blank_map.Add(@(".") * $MapWidth)
    }
    return $blank_map
}

function Get-MapWithRobotsPositions([object]$Map, [object]$RobotsData) {
    foreach ($robot in $RobotsData) {
        [int]$Map[$($robot[0])][$($robot[1])] = 1
    }
    return $Map
}

function Confirm-ChristmasTree([object]$Map, [int]$MapWidth) {

    $map_text = $Map | ForEach-Object {$_ -join ""}
        
    return (Select-String -InputObject $map_text -Pattern "1.{$($MapWidth-1)}111.{$($MapWidth-3)}11111").Matches.Success
}

$height = 103
$width = 101

$robots_data = Get-RobotsDataFromFile $input_file
$blank_map = Get-BlankMap $height $width
#$blank_map | ForEach-Object {$_ -join ""} 

$seconds = 0
while ($true) {
    $robots_data = Get-RobotsPositionsAfterOneSecond $robots_data $height $width
    $seconds++
    
    $blank_map = Get-BlankMap $height $width
    $map_with_robots = Get-MapWithRobotsPositions $blank_map $robots_data
    #$map_with_robots | ForEach-Object {$_ -join ""}
    
    if (Confirm-ChristmasTree $map_with_robots $width) {
        $map_with_robots | ForEach-Object {$_ -join ""}
        return $seconds
    }
}