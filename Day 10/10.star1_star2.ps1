using namespace System.Collections.Generic
$input_file = Get-Content $PSScriptRoot\input.txt

function Get-ParsedFile($File) {
    $prepared_map = [List[array]]::new()
    $trails_start_positions = [List[array]]::new()
    
    for ($line_counter = 0; $line_counter -lt $File.Length; $line_counter++) {
        (Select-String -InputObject $File[$line_counter] -Pattern "[0]" -AllMatches).Matches.Index `
            | ForEach-Object {if ($null -ne $_) {$trails_start_positions.Add(@($line_counter, $_))}}
        
            $prepared_map.Add($File[$line_counter].ToCharArray())
    }

    return $prepared_map, $trails_start_positions
}

function Get-TrailheadScore([array]$Map, [int]$Y, [int]$X) {
    $height = [int][string]$Map[$Y][$X]
    $map_height = $Map.Count-1
    $map_width = $Map[0].Count-1
    $reachable_9s = [List[string]]::new()

    if ($Y-1 -ge 0 -and [int][string]$Map[$Y-1][$X] -eq $height+1) {
        #up
        if ($height+1 -eq 9) {$reachable_9s += "$($Y-1).$X"}
        else {$reachable_9s += Get-TrailheadScore $Map $($Y-1) $X}
    }
    if ($X+1 -le $map_width -and [int][string]$Map[$Y][$X+1] -eq $height+1) {
        #right
        if ($height+1 -eq 9) {$reachable_9s += "$Y.$($X+1)"}
        else {$reachable_9s += Get-TrailheadScore $Map $Y $($X+1)}
    }
    if ($Y+1 -le $map_height -and [int][string]$Map[$Y+1][$X] -eq $height+1) {
        #down
        if ($height+1 -eq 9) {$reachable_9s += "$($Y+1).$X"}
        else {$reachable_9s += Get-TrailheadScore $Map $($Y+1) $X}
    }
    if ($X-1 -ge 0 -and [int][string]$Map[$Y][$X-1] -eq $height+1) {
        #left
        if ($height+1 -eq 9) {$reachable_9s += "$Y.$($X-1)"}
        else {$reachable_9s += Get-TrailheadScore $Map $Y $($X-1)}
    }
    
    return $reachable_9s
}

$topographic_map, $all_starting_positions = Get-ParsedFile $input_file

#foreach ($i in $all_starting_positions) {$i -join "." | Write-Host}
#foreach ($i in 0..$($topographic_map.Count-1)) {$topographic_map[$i] -join "" | Write-Host}

$result_1, $result_2 = 0
foreach ($trailhead_start in $all_starting_positions) {
    $trailheads = Get-TrailheadScore $topographic_map $trailhead_start[0] $trailhead_start[1]
    $result_1 += ($trailheads | Sort-Object -Unique).Count
    $result_2 += ($trailheads).Count
}
Write-Host $result_1, $result_2