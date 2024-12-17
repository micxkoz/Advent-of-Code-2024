using namespace System.Collections.Generic
$input_file = Get-Content $PSScriptRoot\sample2.txt

function Get-DebbugerDataFromFile ($File) {
    $register_A = [int](Select-String -InputObject $input_file -Pattern "Register A: (\d+)").Matches.Groups[1].Value
    $register_B = [int](Select-String -InputObject $input_file -Pattern "Register B: (\d+)").Matches.Groups[1].Value
    $register_C = [int](Select-String -InputObject $input_file -Pattern "Register C: (\d+)").Matches.Groups[1].Value

    $program = (Select-String -InputObject $input_file -Pattern "Program: ([0-9,]+)").Matches.Groups[1].Value -split ","

    return $register_A, $register_B, $register_C, $program
}

function Get-ProgramOutput ([int]$RegA, [int]$RegB, [int]$RegC, [string[]]$Program) {
    $pointer = 0
    [List[int]]$output = @()
    $checker = 0

    while ($pointer -lt $Program.Count) {
        $opcode = $Program[$pointer]
        $operand = $Program[$pointer+1]


        $literal = $operand
        if ($operand -ge 0 -and $operand -le 3) {$combo = $operand}
        elseif ($operand -eq 4) {$combo = $RegA}
        elseif ($operand -eq 5) {$combo = $RegB}
        elseif ($operand -eq 6) {$combo = $RegC}
        elseif ($operand -eq 7) {Write-Host "RESERVED - NOT VALID PROGRAM"}


        if ($opcode -eq 0) {$RegA = [int][Math]::floor($RegA / [Math]::Pow(2, $combo))}
        elseif ($opcode -eq 1) {$RegB = $RegB -bxor $literal}
        elseif ($opcode -eq 2) {$RegB = $combo % 8}
        elseif ($opcode -eq 3) {if ($RegA -ne 0) {$pointer = [int]$literal; continue}}
        elseif ($opcode -eq 4) {$RegB = $RegB -bxor $RegC}
        elseif ($opcode -eq 5) {$output.Add($combo % 8)}
        elseif ($opcode -eq 6) {$RegB = [int][Math]::floor($RegA / [Math]::Pow(2, $combo))}
        elseif ($opcode -eq 7) {$RegC = [int][Math]::floor($RegA / [Math]::Pow(2, $combo))}
        $pointer += 2

        $checker = $output.Count
        if ($checker -gt 0) {
            if ($Program[$checker-1] -eq $output[$checker-1]) {continue}
            else {return $false}
        }
    }
    return $($output -join ",") -eq $($Program -join ",")
    Write-Host "HALT"
}

$registerA, $registerB, $registerC, $program = Get-DebbugerDataFromFile $input_file

$program -join "," | Write-Host
Write-Host

$registerA = [int]$program[0]
while (-not $(Get-ProgramOutput $registerA $registerB $registerC $program)) {
    $registerA = $registerA + 8
}
$registerA