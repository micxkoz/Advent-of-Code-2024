using namespace System.Collections.Generic
$input_file = Get-Content $PSScriptRoot\sample.txt

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
    $score = 0

    # if ($height -eq 8) {
    #     $height.GetType().Name | Write-Host
    #     $map_height.GetType().Name | Write-Host
    #     $map_width.GetType().Name | Write-Host
    #     $score.GetType().Name | Write-Host
    #     $Y.GetType().Name | Write-Host
    #     $X.GetType().Name | Write-Host
    #     $Map.GetType().Name | Write-Host
    #     $Map[$Y][$X].GetType().Name | Write-Host
    # }
    
    $height, $Y, $X -join " " | Write-Host

    if ($Y-1 -ge 0 -and [int][string]$Map[$Y-1][$X] -eq $height+1) {
        #"up" | Write-Host
        if ($height -eq 8) {$score += 1}
        else {$score += Get-TrailheadScore $Map $($Y-1) $X}
    }
    if ($X+1 -le $map_width -and [int][string]$Map[$Y][$X+1] -eq $height+1) {
        #"right" | Write-Host
        if ($height -eq 8) {$score += 1}
        else {$score += Get-TrailheadScore $Map $Y $($X+1)}
    }
    if ($Y+1 -le $map_height -and [int][string]$Map[$Y+1][$X] -eq $height+1) {
        #"down" | Write-Host
        if ($height -eq 8) {$score += 1}
        else {$score += Get-TrailheadScore $Map $($Y+1) $X}
    }
    if ($X-1 -ge 0 -and [int][string]$Map[$Y][$X-1] -eq $height+1) {
        #"left" | Write-Host
        if ($height -eq 8) {$score += 1}
        else {$score += Get-TrailheadScore $Map $Y $($X-1)}
    }
    
    return $score
}

$topographic_map, $all_starting_positions = Get-ParsedFile $input_file

#foreach ($i in $all_starting_positions) {$i -join "." | Write-Host}
foreach ($i in 0..$($topographic_map.Count-1)) {$topographic_map[$i] -join "" | Write-Host}

$result = 0
foreach ($trailhead_start in $all_starting_positions) {
    $result += Get-TrailheadScore $topographic_map $trailhead_start[0] $trailhead_start[1]
}
Write-Host $result
