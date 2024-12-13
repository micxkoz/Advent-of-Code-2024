$input_file = Get-Content $PSScriptRoot\sample.txt

function Parse-File($File) {
    $calibrations_dict = [ordered]@{}

    foreach ($line in $File) {
        $splitted_line = $line.Split(":")
        $equation = $splitted_line[1].Trim().Split(" ") | ForEach-Object -Begin {$equation_array = @()} -Process {$equation_array += [int]$_} -End {return $equation_array}
        $calibrations_dict.Add([long]$splitted_line[0], $equation)
    }
    return $calibrations_dict
}

function Check-Equation_AddMul($Result, $Equation) {
    $max_permutations = [Math]::Pow(2, $($Equation.Count - 1))
    for ($permutation_number = 0; $permutation_number -lt $max_permutations; $permutation_number++) {
        $pattern = [convert]::ToString($permutation_number, 2).PadLeft($($Equation.Count - 1),"0")
        
        [long]$permutation_result = $Equation[0]
        
        for ($i = 0; $i -lt $pattern.Length; $i++) {
            if ($pattern[$i] -eq "0") {$permutation_result += $Equation[$i+1]}
            else {$permutation_result *= $Equation[$i+1]}
        }
        
        if ($permutation_result -eq $Result) {return $true}
    }
    return $false
}

function Permutate-Equation($Equation) {
    $all_permutations = @()
    $max_permutations = [Math]::Pow(2, $($Equation.Count - 1))
    for ($permutation_number = 0; $permutation_number -lt $max_permutations; $permutation_number++) {
        $pattern = [convert]::ToString($permutation_number, 2).PadLeft($($Equation.Count - 1),"0")

        $new_permutation = @()
        [string]$number = $Equation[0]
        for ($i = 0; $i -lt $pattern.Length; $i++) {
            if ($pattern[$i] -eq "1") {$number += $Equation[$i+1]}
            else {$new_permutation += $number; $number = $Equation[$i+1]}
        }
        $new_permutation += $number
        $all_permutations += ,$new_permutation
    }
    return $all_permutations
}

$calibrations = Parse-File($input_file)


$permutated_equations = Permutate-Equation $calibrations[4]
foreach ($variant in $permutated_equations) {
    Write-Host $variant
    Write-Host "--"
    Check-Equation_AddMul $calibrations.Keys[4] $variant
}




#$calibrations[[long]192]

# [long]$sum = 0
# for ($index = 0; $index -lt $calibrations.Count; $index++) {
#     #if (Check-Equation $calibrations.Keys[$index] $calibrations[$index]) {$sum += $calibrations.Keys[$index]}
#     $permutations = Permutate-Equation $calibrations[0]

#     $found = $false
#     foreach ($variant in $permutations) {
#         if (Check-Equation_AddMul $calibrations.Keys[0] $variant) {Write-Host $calibrations[$i]; Write-Host $variant; $found = $true; break}
#     }
#     if ($found) {$sum += $calibrations.Keys[$index]}
# }
# return $sum