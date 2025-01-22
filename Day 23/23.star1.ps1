using namespace System.Collections.Generic
$input_file = Get-Content $PSScriptRoot\input.txt

function Get-NetworkMap($File) {
    $map = @{}
    foreach ($line in $File) {
        $left, $right = $line -split "-"
        if (-not $map.ContainsKey($left)) {$map[$left] = @()}
        if (-not $map.ContainsKey($right)) {$map[$right] = @()}
        $map[$left] += @($right)
        $map[$right] += @($left)
    }
    return $map
}

$network_map = Get-NetworkMap $input_file

$result = [List[string]]::new()
foreach ($first_computer in $($network_map.Keys -match "^t")) {
    foreach ($second_computer in $network_map[$first_computer]) {
        foreach ($third_computer in $network_map[$second_computer]) {
            if ($first_computer -in $network_map[$third_computer]) {
                $network_id = $first_computer, $second_computer, $third_computer | Sort-Object | Join-String -Separator ","
                $result.Add($network_id)
            }
        }
    }
    
}
($result | Sort-Object -Unique | Measure-Object).Count