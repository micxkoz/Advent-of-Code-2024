using namespace System.Collections.Generic
$puzzle_input = Get-Content -Path $PSScriptRoot\input.txt

$gate_value = @{}
$gates_operations = [List[string]]::new()

foreach ($line in $puzzle_input) {
    if ($line -like "*: *") {
        $wire, $value = $line -split ": "
        $gate_value[$wire] = $([bool][int]$value)
    }
    elseif ($line -like "* -> *") {
        $gates_operations.Add($line)
    }
}

do {
    $all_gates = $true
    
    foreach($gate in $gates_operations) {
        $gate_input, $gate_output = $gate -split " -> "
        $input_left, $input_operator, $input_right = $gate_input -split " "

        if ($gate_value.ContainsKey($gate_output)) {continue}

        if ($null -eq $gate_value[$input_left] -or $null -eq $gate_value[$input_right]) {
            $all_gates = $false
            continue
        }

        if ($input_operator -ceq "AND") {
            $gate_value[$gate_output] = $gate_value[$input_left] -and $gate_value[$input_right]
        }
        elseif ($input_operator -ceq "XOR") {
            $gate_value[$gate_output] = $gate_value[$input_left] -xor $gate_value[$input_right]
        }
        elseif ($input_operator -ceq "OR") {
            $gate_value[$gate_output] = $gate_value[$input_left] -or $gate_value[$input_right]
        }
    }
} 
until ($all_gates)

$z_gates = $gate_value.Keys | Where-Object {$_ -like "z*"} | Sort-Object -Descending

$number = [Text.StringBuilder]::new()

foreach ($gate in $z_gates) {
    $number.Append([int]$gate_value[$gate]) | Out-Null
}

return [Convert]::ToInt64($number.ToString(), 2)