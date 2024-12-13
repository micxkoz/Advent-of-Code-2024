$file = Get-Content $PSScriptRoot\input.txt

$ll = ($file | Select-Object -First 1).Length
$result = 0

$result += (Select-String -InputObject $file -Pattern "(?=XMAS|SAMX)" -AllMatches).Matches.Count

foreach ($i in $($ll-1)..$($ll+1)) {
    $result += (Select-String -InputObject $file -Pattern "(?s)(?=X.{$i}M.{$i}A.{$i}S)" -AllMatches).Matches.Count
    $result += (Select-String -InputObject $file -Pattern "(?s)(?=S.{$i}A.{$i}M.{$i}X)" -AllMatches).Matches.Count
}

return $result