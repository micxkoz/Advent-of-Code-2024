using namespace System.Collections.Generic
$input_file = Get-Content $PSScriptRoot\input.txt

function Get-ParsedFile($File) {
    [List[int]]$stones_line += $File -split " "
    return $stones_line
}

function Get-StonesAfterBlink([List[double]]$StonesLine) {
    for ($i = 0; $i -lt $StonesLine.Count; $i++) {
        # $StonesLine -join " . "
        # $StonesLine[$i]
        if ($StonesLine[$i] -eq 0) {$StonesLine[$i] = 1; continue}
        
        if (([string]$StonesLine[$i]).Length % 2 -eq 0) {
            $cut = ([string]$StonesLine[$i]).Length / 2
            $StonesLine.Insert($i, [double](([string]$StonesLine[$i])[0..$($cut-1)] -join ""))
            $i++
            $StonesLine[$i] = [double](([string]$StonesLine[$i])[$cut..([string]$StonesLine[$i]).Length] -join "")
            continue
        }
        
        $StonesLine[$i] = $StonesLine[$i] * 2024
    }
    return $StonesLine

        
}

$stones = Get-ParsedFile $input_file
#$stones -join " . "
for ($blink = 1; $blink -le 75; $blink++) {
    Write-Host $blink
    $stones = Get-StonesAfterBlink $stones
    #$stones -join " . "
    Write-Host "    $($stones.Count)"
}
$stones.Count