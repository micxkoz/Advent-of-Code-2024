$file = Get-Content $PSScriptRoot\input.txt

$left = @()
$right = @()
foreach($line in $file) {
    $line = $line -split "\s+"
    $left += $line[0]
    $right += $line[1]
}

$similarity = 0
foreach ($number in $left) {
    $similarity += ([int]$number * ($right | Where-Object {$_ -eq $number}).Count)
}
return $similarity