using namespace System.Collections.Generic
$input_file = Get-Content $PSScriptRoot\input.txt

function Get-SecretNumbers($File) {
    $secret_numbers = [List[string]]::new()
    foreach ($line in $File) {
        $secret_numbers.Add([int]$line)
    }
    return $secret_numbers
}

$secret_numbers = Get-SecretNumbers $input_file

$result = 0
foreach ($secret_number in $secret_numbers) {        
    $secret_number = [long]$secret_number

    for ($id = 1; $id -le 2000; $id++) {
            $secret_number = (($secret_number * 64) -bxor $secret_number) % 16777216
            $secret_number = ([math]::floor($secret_number / 32) -bxor $secret_number) % 16777216
            $secret_number = (($secret_number * 2048) -bxor $secret_number) % 16777216
    }
    
    $result += $secret_number
}
return $result
