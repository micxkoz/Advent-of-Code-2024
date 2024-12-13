using namespace System.Collections.Generic
$input_file = Get-Content $PSScriptRoot\input.txt

function Get-ParsedFile($File) {
    $machines_configurations = [List[array]]::new()
        
    $configuration = @()
    for ($line_counter = 0; $line_counter -lt $File.Length; $line_counter++) {
            if ($line_counter % 4 -eq 0) {
                $line_prepared = $File[$line_counter] -replace "Button A: ", "" -split ", "
                $configuration += @([int]($line_prepared[0] -replace "X+", ""), [int]($line_prepared[1] -replace "Y+", ""))
            }
            
            if ($line_counter % 4 -eq 1) {
                $line_prepared = $File[$line_counter] -replace "Button B: ", "" -split ", "
                $configuration += @([int]($line_prepared[0] -replace "X+", ""), [int]($line_prepared[1] -replace "Y+", ""))
            }
            
            if ($line_counter % 4 -eq 2) {
                $line_prepared = $File[$line_counter] -replace "Prize: ", "" -split ", "
                $configuration += @([int]($line_prepared[0] -replace "X=", ""), [int]($line_prepared[1] -replace "Y=", ""))
                $machines_configurations.Add($configuration)
                $configuration = @()
            }
    }

    return $machines_configurations
}

function Get-ButtonPushes([array]$Configuration) {
    $c = $Configuration

    $button_b = (($c[5]*$c[0]) - ($c[1]*$c[4])) / ((-$c[2]*$c[1]) + ($c[3]*$c[0]))
    $button_a = ($c[4] - ($c[2]*$button_b)) / $c[0]

    if ($button_a -is [int] -and $button_b -is [int]) {return $button_a, $button_b}
    else {return $null}
}

$all_machines_configurations = Get-ParsedFile $input_file

$result = 0
foreach ($configuration in $all_machines_configurations) {
    $a, $b = Get-ButtonPushes $configuration
    if ($null -ne $a -and $null -ne $b -and $a -le 100 -and $b -le 100) {$result += (3*$a) + $b}
}
Write-Host $result