$file = Get-Content $PSScriptRoot\input.txt

$mul_instructions = (Select-String -InputObject $file -Pattern "mul\((\d{1,3}),(\d{1,3})\)" -AllMatches).Matches

$mul_instructions | ForEach-Object `
    -Begin {$result = 0} `
    -Process {$result += [int]$_.Groups[1].Value * [int]$_.Groups[2].Value} `
    -End {return $result}
     