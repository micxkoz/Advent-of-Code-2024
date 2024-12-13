$input_file = Get-Content $PSScriptRoot\input.txt

function Parse-File($File) {
    $calibrations_dict = [ordered]@{}

    foreach ($line in $File) {
        $splitted_line = $line.Split(":")
        $equation = $splitted_line[1].Trim().Split(" ") | ForEach-Object -Begin {$equation_array = @()} -Process {$equation_array += [int]$_} -End {return $equation_array}
        $calibrations_dict.Add([long]$splitted_line[0], $equation)
    }
    return $calibrations_dict
}

function Generate-Permutations($StringLength) {
    Write-Host "Generating"
    $permutations_array = @()
    foreach ($i in 0..2) {
        if ($StringLength -gt 1) {$permutations_array += Generate-Permutations($StringLength - 1) | ForEach-Object {[string]$i + $_}}
        else {$permutations_array += $i}
    }
    return $permutations_array
}

function Check-Equation($Result, $Equation) {    
    $all_permutations = Generate-Permutations $($Equation.Count - 1)
    Write-Host "Checking"
    foreach ($permutation in $all_permutations) {

        [long]$permutation_result = $Equation[0]
        
        for ($i = 0; $i -lt $permutation.Length; $i++) {
            if ($permutation[$i] -eq "0") {$permutation_result += $Equation[$i+1]}
            elseif ($permutation[$i] -eq "1") {$permutation_result *= $Equation[$i+1]}
            else {[long]$permutation_result = [string]$permutation_result + $Equation[$i+1]}
        }
        if ($permutation_result -eq $Result) {return $true}
    }
    return $false
}

$calibrations = Parse-File($input_file)
# Check-Equation $calibrations.Keys[3] $calibrations[3]


[long]$sum = 0
for ($index = 0; $index -lt $calibrations.Count; $index++) {
    Write-Host $index
    if (Check-Equation $calibrations.Keys[$index] $calibrations[$index]) {$sum += $calibrations.Keys[$index]}
}
return $sum