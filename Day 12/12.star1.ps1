using namespace System.Collections.Generic
$input_file = Get-Content $PSScriptRoot\input.txt

function Get-ParsedFile($File) {
    $garden_map = [List[array]]::new()
    
    for ($line_counter = 0; $line_counter -lt $File.Length; $line_counter++) {
            $garden_map.Add($File[$line_counter].ToCharArray())
    }

    return $garden_map
}

function Get-NextRegionToCalculate {
    for ($row_index = 0; $row_index -lt $GardenMap.Count; $row_index++) {
        $column_index = (Select-String -InputObject $($GardenMap[$row_index] -join "") -Pattern "[^\.]").Matches.Index
        if ($null -ne $column_index) {
            return $row_index, $column_index
        }
    }
    return -1, -1
}

function Get-PricePerPlants([int]$Y, [int]$X, [char]$Plant) {
    if ($GardenMap[$Y][$X] -eq $Plant) {

        $map_height = $GardenMap.Count-1
        $map_width = $GardenMap[0].Count-1
        $price_per_plant = 0

        if ($Y-1 -lt 0 -or $GardenMap[$Y-1][$X] -notmatch "[0-4$($Plant)]") {$price_per_plant += 1}
        if ($Y+1 -gt $map_height -or $GardenMap[$Y+1][$X] -notmatch "[0-4$($Plant)]") {$price_per_plant += 1}
        if ($X-1 -lt 0 -or $GardenMap[$Y][$X-1] -notmatch "[0-4$($Plant)]") {$price_per_plant += 1}
        if ($X+1 -gt $map_width -or $GardenMap[$Y][$X+1] -notmatch "[0-4$($Plant)]") {$price_per_plant += 1}        
        $GardenMap[$Y][$X] = [char][string]$price_per_plant

        if ($Y-1 -ge 0) {Get-PricePerPlants $($Y-1) $X $Plant}
        if ($Y+1 -le $map_height) {Get-PricePerPlants $($Y+1) $X $Plant}
        if ($X-1 -ge 0) {Get-PricePerPlants $Y $($X-1) $Plant}
        if ($X+1 -le $map_width) {Get-PricePerPlants $Y $($X+1) $Plant}
    }
}

function Get-RegionValue {
    $area = ($GardenMap | ForEach-Object {$_ -join ""} | Select-String "\d" -AllMatches).Matches.Count
    $perimeter = ($GardenMap | ForEach-Object {$_ -join ""} | Select-String "\d" -AllMatches).Matches.Value `
        | ForEach-Object -Begin {$value = 0} -Process {$value += [int]$_} -End {return $value}
    for ($row = 0; $row -lt $GardenMap.Count; $row++) {$GardenMap[$row] = ($GardenMap[$row] -join "" -replace "\d", ".").ToCharArray()}
    return $area * $perimeter
}

$garden_plots_map = Get-ParsedFile $input_file
New-Variable -Name GardenMap -Scope "Script" -Value $garden_plots_map

$result = 0
while ($true) {
    $region_y, $region_x = Get-NextRegionToCalculate
    if (-1 -eq $region_y -or -1 -eq $region_x) {break}
    
    Get-PricePerPlants $region_y $region_x $GardenMap[$region_y][$region_x]
    #$GardenMap | ForEach-Object {$_ -join ""}
    $result += Get-RegionValue
    #$GardenMap | ForEach-Object {$_ -join ""}
}
Write-Host $result
Remove-Variable -Name GardenMap


