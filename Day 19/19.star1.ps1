using namespace System.Collections.Generic
$input_file = Get-Content $PSScriptRoot\input.txt

function Get-OnsenData($File) {
    [List[string]]$patterns = $File[0] -split ", "
    
    $designs = [List[string]]::new()
    for ($line = 2; $line -lt $File.Count; $line++) {$designs.Add($File[$line])}
    
    return $patterns, $designs
}

function Get-DesignPossibility ($Design, $AvailablePatterns) {
    if ($impossible_designs.ContainsKey($Design)) {return $false}

    foreach ($pattern in $AvailablePatterns) {
        if ($Design -match "^$($pattern)") {
            if ($Design -eq $pattern) {return $true}
            
            $new_design = $Design[$pattern.Length..$($Design.Length-1)] -join ""
            if (Get-DesignPossibility $new_design $towel_patterns) {return $true}
        }
    }
    $impossible_designs[$Design] = $true
    return $false
}

$towel_patterns, $desired_designs = Get-OnsenData $input_file

$impossible_designs = @{}
$result = 0
foreach ($design in $desired_designs) {
    if (Get-DesignPossibility $design $towel_patterns) {$result++}
}
return $result