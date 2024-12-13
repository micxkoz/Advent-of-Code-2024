$file = Get-Content $PSScriptRoot\input.txt

$counter = 0
foreach ($line in $file) {
    [System.Collections.Generic.List[int]]$splitted = $line -split "\s"
    $permutations = [System.Collections.Generic.List[int[]]]::new()
    for ($i = 0; $i -lt $splitted.Count; $i++) {
        [System.Collections.Generic.List[int]]$redacted_level = $splitted.ToArray()
        $redacted_level.RemoveAt($i)
        $permutations.Add($redacted_level)
    }
    $permutations.Add($splitted)
    
    foreach ($level_permutation in $permutations) {
        $predecessor = $null
        $direction = $null
        $safe = $true

        foreach ($number in $level_permutation) {
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
        if ($safe) {$counter += 1; break}
    }
}

return $counter