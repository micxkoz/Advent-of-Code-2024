using namespace System.Collections.Generic
$input_file = Get-Content $PSScriptRoot\input.txt

function Get-ParsedFile($File) {
    $antennas_ids = @()

    $prepared_map = [List[array]]::new()
    foreach ($line in $File) {
        $prepared_map.Add([char[]]$line)
        $antennas_ids += (Select-String -InputObject $line -Pattern "[^\.]" -AllMatches -CaseSensitive).Matches.Value
    }
    $antennas_ids = $antennas_ids | Sort-Object -Unique -CaseSensitive

    return $prepared_map, $antennas_ids
}

function Find-AllAntennas($Map, $AntennaID) {
    $found_positions = @()
    for ($y = 0; $y -lt $Map.Count; $y++) {
        if ($Map[$y] -ccontains $AntennaID) {
            for ($x = 0; $x -lt $Map[$y].Count; $x++) {
                if ($Map[$y][$x] -ceq $AntennaID) {
                    $found_positions += , @($y, $x)
                }
            }
        }
    }
    return $found_positions
}

function Find-Antinodes($AntennasGridPositions, $GridHeight, $GridWidth) {
    $found_antinodes = @()
    for ($first = 0; $first -lt $AntennasGridPositions.Count; $first++) {
        for ($second = $first+1; $second -lt $AntennasGridPositions.Count; $second++) {
            $delta_y = $AntennasGridPositions[$first][0] - $AntennasGridPositions[$second][0]
            $delta_x = $AntennasGridPositions[$first][1] - $AntennasGridPositions[$second][1]

            $first_y = $($AntennasGridPositions[$first][0] + $delta_y)
            $first_x = $($AntennasGridPositions[$first][1] + $delta_x)
            $second_y = $($AntennasGridPositions[$second][0] - $delta_y)
            $second_x = $($AntennasGridPositions[$second][1] - $delta_x)

            if ($first_y -ge 0 -and $first_y -lt $GridHeight `
                -and $first_x -ge 0 -and $first_x -lt $GridWidth) {
                    $found_antinodes += [string]$first_y+"."+$first_x
                }
            
            if ($second_y -ge 0 -and $second_y -lt $GridHeight `
                -and $second_x -ge 0 -and $second_x -lt $GridWidth) {
                    $found_antinodes += [string]$second_y+"."+$second_x
                }
        }
    }
    return $found_antinodes
}

$map, $all_antennas_ids = Get-ParsedFile $input_file

$all_antennas_ids | Sort-Object

# #Tvz
# $all_x = Find-AllAntennas $map "v"
# Find-Antinodes $all_x $($map.Count-1) $($map[0].Count-1) | Sort-Object -Unique

$all_antinodes_positions = @()
foreach ($antenna_id in $all_antennas_ids) { 
    $all_antennas_positions = Find-AllAntennas $map $antenna_id
    Write-Host $all_antennas_positions $antenna_id
    $all_antinodes_positions += Find-Antinodes $all_antennas_positions $($map.Count) $($map[0].Count)
}
($all_antinodes_positions | Sort-Object -Unique).Count