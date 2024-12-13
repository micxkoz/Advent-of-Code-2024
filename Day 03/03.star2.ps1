$file = Get-Content $PSScriptRoot\input.txt

$enabled = $true
$result = 0

$valid_instructions = (Select-String -InputObject $file -Pattern "don't\(\)|do\(\)|mul\((\d{1,3}),(\d{1,3})\)" -AllMatches).Matches
foreach ($instruction in $valid_instructions) {
    if ($instruction -like "do()") {$enabled = $true; continue}
    if ($instruction -like "don't()") {$enabled = $false; continue}
    if ($enabled) {$result += [int]$instruction.Groups[1].Value * [int]$instruction.Groups[2].Value}
}
return $result