using namespace System.Collections.Generic
$input_file = Get-Content $PSScriptRoot\input.txt

function Get-DataFromOnsen($File) {
    [List[string]]$patterns = $File[0] -split ", "
    
    $designs = [List[string]]::new()
    for ($line = 2; $line -lt $File.Count; $line++) {$designs.Add($File[$line])}
    
    return $patterns, $designs
}

function Get-NumberOfPossibleArrangements($Design, $AvailablePatterns) {
    if ($arrangements_per_design.ContainsKey($Design)) {return $arrangements_per_design[$Design]}

    $number_of_arrangements = 0
    foreach ($pattern in $AvailablePatterns) {
        if ($Design -match "^$($pattern)") {
            if ($Design -eq $pattern) {$number_of_arrangements += 1}
            else {
                $rest_of_design = $Design[$pattern.Length..$($Design.Length-1)] -join ""
                $number_of_arrangements += Get-NumberOfPossibleArrangements $rest_of_design $AvailablePatterns
            }
        }
    }
    $arrangements_per_design[$Design] = $number_of_arrangements
    return $number_of_arrangements
}
$towel_patterns, $desired_designs = Get-DataFromOnsen $input_file

$arrangements_per_design = @{}
[long]$result = 0
foreach ($design in $desired_designs) {$result += Get-NumberOfPossibleArrangements $design $towel_patterns}
return $result