$file = Get-Content $PSScriptRoot\input.txt

$left = @()
$right = @()
foreach($line in $file) {
    $line = $line -split "\s+"
    $left += $line[0]
    $right += $line[1]
}
$left = $left | Sort-Object
$right = $right | Sort-Object

$distance = 0
for ($i = 0; $i -lt $left.Length; $i++) {
    $distance += [Math]::Abs($left[$i] - $right[$i])
}
return $distance