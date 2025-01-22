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

$sequence_value = @{}

foreach ($secret_number in $secret_numbers) {        
    $secret_number = $secret_number -as [long]
    $prev_price = $secret_number % 10
    $price = $null
    $price_change = $null
    $sequence = $null
    $buyer_sequences = @{}
        
    for ($id = 1; $id -le 2000; $id++) {
            $secret_number = (($secret_number * 64) -bxor $secret_number) % 16777216
            $secret_number = ([math]::floor($secret_number / 32) -bxor $secret_number) % 16777216
            $secret_number = (($secret_number * 2048) -bxor $secret_number) % 16777216

            $price = $secret_number % 10

            $price_change = $price - $prev_price
            $price_change = $price_change -as [string]
            if ($price_change -ge 0) {$price_change = "+" + $price_change}

            $sequence += $price_change
            if ($sequence.Length -gt 8) {$sequence = $sequence.Substring(2)}
            
            if ($sequence.Length -eq 8 -and -not $buyer_sequences.ContainsKey($sequence)) {
                $sequence_value[$sequence] += $price
                $buyer_sequences[$sequence] = $true
            }
            
            $prev_price = $price
    }
}

($sequence_value.Values | Measure-Object -Maximum).Maximum