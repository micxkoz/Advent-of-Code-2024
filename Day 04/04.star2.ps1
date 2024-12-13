$file = Get-Content $PSScriptRoot\input.txt

$ll = ($file | Select-Object -First 1).Length

$result = 0

$result += (Select-String -InputObject $file -Pattern "(?s)(?=M.M.{$($ll-1)}A.{$($ll-1)}S.S)" -AllMatches).Matches.Count
$result += (Select-String -InputObject $file -Pattern "(?s)(?=M.S.{$($ll-1)}A.{$($ll-1)}M.S)" -AllMatches).Matches.Count
$result += (Select-String -InputObject $file -Pattern "(?s)(?=S.M.{$($ll-1)}A.{$($ll-1)}S.M)" -AllMatches).Matches.Count
$result += (Select-String -InputObject $file -Pattern "(?s)(?=S.S.{$($ll-1)}A.{$($ll-1)}M.M)" -AllMatches).Matches.Count

return $result