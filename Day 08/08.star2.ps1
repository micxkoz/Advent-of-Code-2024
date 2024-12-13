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

function Find-ManyAntinodes($AntennasGridPositions, $GridHeight, $GridWidth) {
    $found_antinodes = @()
    foreach ($first_antenna in $AntennasGridPositions) {
        foreach ($second_antenna in $AntennasGridPositions) {
            if ($first_antenna[0] -ne $second_antenna[0] -or $first_antenna[1] -ne $second_antenna[1]) {
                $first_y = $first_antenna[0]
                $first_x = $first_antenna[1] 
                $second_y = $second_antenna[0]
                $second_x = $second_antenna[1]
                $diff_y = $first_y - $second_y
                $diff_x = $first_x - $second_x
                
                $found_antinodes += [string]$first_y+"."+$first_x
                $in_grid = $true
                while ($in_grid) {
                    $first_y = $first_y + $diff_y
                    $first_x = $first_x + $diff_x
                    if ($first_y -in 0..$GridHeight -and $first_x -in 0..$GridWidth) {
                            $found_antinodes += [string]$first_y+"."+$first_x
                        }
                    else {$in_grid = $false}
                }

                $in_grid = $true
                while ($in_grid) {
                    $second_y = $second_y - $diff_y
                    $second_x = $second_x - $diff_x
                    if ($second_y -in 0..$GridHeight -and $second_x -in 0..$GridWidth) {
                            $found_antinodes += [string]$second_y+"."+$second_x
                        }
                    else {$in_grid = $false}
                }

            }
        }
    }
    return $found_antinodes
}

$map, $all_antennas_ids = Get-ParsedFile $input_file

# #Tvz
# $all_x = Find-AllAntennas $map "v"
# Find-Antinodes $all_x $($map.Count-1) $($map[0].Count-1) | Sort-Object -Unique

$all_antinodes_positions = @()
foreach ($antenna_id in $all_antennas_ids) { 
    $all_antennas_positions = Find-AllAntennas $map $antenna_id
    $all_antinodes_positions += Find-ManyAntinodes $all_antennas_positions $($map.Count-1) $($map[0].Count-1)
}
($all_antinodes_positions | Sort-Object -Unique).Count