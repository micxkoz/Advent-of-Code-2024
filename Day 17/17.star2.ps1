using namespace System.Collections.Generic
$input_file = Get-Content $PSScriptRoot\input.txt

function Get-DebbugerDataFromFile ($File) {
    $register_A = [long](Select-String -InputObject $input_file -Pattern "Register A: (\d+)").Matches.Groups[1].Value
    $register_B = [long](Select-String -InputObject $input_file -Pattern "Register B: (\d+)").Matches.Groups[1].Value
    $register_C = [long](Select-String -InputObject $input_file -Pattern "Register C: (\d+)").Matches.Groups[1].Value

    $program = (Select-String -InputObject $input_file -Pattern "Program: ([0-9,]+)").Matches.Groups[1].Value -split ","

    return $register_A, $register_B, $register_C, $program
}

function Get-ProgramOutput ([long]$RegA, [long]$RegB, [long]$RegC, [string[]]$Program) {
    $pointer = 0
    [List[int]]$output = @()

    while ($pointer -lt $Program.Count) {
        $opcode = $Program[$pointer]
        $operand = $Program[$pointer+1]


        $literal = $operand
        if ($operand -ge 0 -and $operand -le 3) {$combo = $operand}
        elseif ($operand -eq 4) {$combo = $RegA}
        elseif ($operand -eq 5) {$combo = $RegB}
        elseif ($operand -eq 6) {$combo = $RegC}
        elseif ($operand -eq 7) {Write-Host "RESERVED - NOT VALID PROGRAM"}


        if ($opcode -eq 0) {$RegA = [long][Math]::floor($RegA / [Math]::Pow(2, $combo))}
        elseif ($opcode -eq 1) {$RegB = $RegB -bxor $literal}
        elseif ($opcode -eq 2) {$RegB = $combo % 8}
        elseif ($opcode -eq 3) {if ($RegA -ne 0) {$pointer = [long]$literal; continue}}
        elseif ($opcode -eq 4) {$RegB = $RegB -bxor $RegC}
        elseif ($opcode -eq 5) {$output.Add($combo % 8)}
        elseif ($opcode -eq 6) {$RegB = [long][Math]::floor($RegA / [Math]::Pow(2, $combo))}
        elseif ($opcode -eq 7) {$RegC = [long][Math]::floor($RegA / [Math]::Pow(2, $combo))}
        

        $pointer += 2
        
    }
    return $output
}


$registerA, $registerB, $registerC, $program = Get-DebbugerDataFromFile $input_file

$registerA = [Math]::Pow(8, $program.Count-1) + 1

while ($true) {
    $output = Get-ProgramOutput $registerA $registerB $registerC $program

    #Write-Host $($output -join ",")
    #Write-Host $($program -join ",")

    if ($($output -join ",") -eq $($program -join ",")) {return $registerA}
    
    foreach ($i in $($output.Count-1)..0) {
        if ($output[$i] -ne $program[$i]) {$registerA += [Math]::Pow(8, $i); break}
    }
}

# $program -join "," | Write-Host
# $output = Get-ProgramOutput $registerA $registerB $registerC $program
# $output -join "," | Write-Host