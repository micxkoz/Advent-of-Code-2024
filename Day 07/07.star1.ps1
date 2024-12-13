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

function Check-Equation($Result, $Equation) {    
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

$calibrations = Parse-File($input_file)

#Check-Equation $calibrations.Keys[1] $calibrations[1]
#$calibrations[[long]192]

[long]$sum = 0
for ($index = 0; $index -lt $calibrations.Count; $index++) {
    if (Check-Equation $calibrations.Keys[$index] $calibrations[$index]) {$sum += $calibrations.Keys[$index]}
}
return $sum