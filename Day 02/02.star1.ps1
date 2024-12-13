$file = Get-Content $PSScriptRoot\input.txt

$counter = 0
foreach ($line in $file) {
    $line = $line -split "\s"
    if (($line | Sort-Object -Unique).Count -ne $line.Count) {continue}
    
    $predecessor = $null
    $direction = $null
    $safe = $true
    foreach ($number in $line) {
        $number = [int]$number
        if (-not $predecessor) {$predecessor = $number; continue}

        if ($predecessor -eq $number) {$safe = $false; break}

        if ($predecessor -lt $number) {
            if (-not $direction) {$direction = "asc"}
            elseif ($direction -eq "desc") {$safe = $false; break}
        }
        else {
            if (-not $direction) {$direction = "desc"}
            elseif ($direction -eq "asc") {$safe = $false; break}
        }

        if ([Math]::Abs($predecessor - $number) -notin (1..3)) {$safe = $false; break}
        
        $predecessor = $number
    }
    
    if ($safe) {$counter += 1}
}
return $counter