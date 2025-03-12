using namespace System.Collections.Generic
$puzzle_input = Get-Content -Path $PSScriptRoot\input.txt
$puzzle_input += "`n"

$all_schematics = [List[List[string]]]::new()
$schematic = [List[string]]::new()

foreach ($line in $puzzle_input) {
    if ($line -match "^$") {
        $all_schematics.Add($schematic)
        $schematic = [List[string]]::new()
    }
    else {$schematic.Add($line)}
}

$keys = [List[List[int]]]::new()
$locks = [List[List[int]]]::new()

foreach ($schematic in $all_schematics) {
    $heights = [ordered]@{1=0;2=0;3=0;4=0;5=0}
    
    for ($i = 1; $i -le $schematic.Count-2; $i++) {
        for ($j = 0; $j -le 4; $j++) {
            if ($schematic[$i][$j] -eq "#") {$heights[$j] += 1}
        }
    }
    
    if ($schematic[0] -match "#{5}") {$locks.Add(@($heights.Values))}
    if ($schematic[0] -match "\.{5}") {$keys.Add(@($heights.Values))}
}

$result = 0
foreach ($lock in $locks) {
    :next_key foreach ($key in $keys) {
        for ($i = 0; $i -le 4; $i++) {
            if ($lock[$i] + $key[$i] -gt 5) {continue next_key}
        }
        $result += 1
    }
}
return $result