using namespace System.Collections.Generic
$input_file = Get-Content $PSScriptRoot\sample.txt

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

function Get-LargestNetwork($NetworkMap) {
    $largest_network = @{}

    foreach ($first_computer_in_network in $NetworkMap.Keys) {

        $current_network = @{}
        $current_network[$first_computer_in_network] = $true

        foreach ($computer in $NetworkMap.Keys) {
            if ($computer -eq $first_computer_in_network) {continue}
            $connected_computer = $true

            foreach ($network_member in $current_network.Keys) {
                if ($NetworkMap[$network_member] -notcontains $computer) {
                    $connected_computer = $false
                    break
                }
            }

            if ($connected_computer) {$current_network[$computer] = $true}
        }

        if ($current_network.Count -gt $largest_network.Count) {$largest_network = $current_network}
    }

    return $largest_network.Keys | Sort-Object | Join-String -Separator ","
}

$network_map = Get-NetworkMap $input_file

$password = Get-LargestNetwork $network_map
return $password