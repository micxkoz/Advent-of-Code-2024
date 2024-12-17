using namespace System.Collections.Generic
$input_file = Get-Content $PSScriptRoot\input.txt

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

    while ($pointer -lt $Program.Count) {
        $opcode = $Program[$pointer]
        $operand = $Program[$pointer+1]


        $literal = $operand
        if ($operand -ge 0 -and $operand -le 3) {$combo = $operand}
        elseif ($operand -eq 4) {$combo = $RegA}
        elseif ($operand -eq 5) {$combo = $RegB}
        elseif ($operand -eq 6) {$combo = $RegC}
        elseif ($operand -eq 7) {Write-Host "RESERVED - NOT VALID PROGRAM"}


        if ($opcode -eq 0) {
            Write-Host "adv: $combo"
            $RegA = [int][Math]::floor($RegA / [Math]::Pow(2, $combo))
        }
        elseif ($opcode -eq 1) {
            Write-Host "bxl: $literal"
            $RegB = $RegB -bxor $literal
        }
        elseif ($opcode -eq 2) {
            Write-Host "bst: $combo"
            $RegB = $combo % 8
        }
        elseif ($opcode -eq 3) {
            Write-Host "jnz: $literal"
            if ($RegA -ne 0) {$pointer = [int]$literal; continue}
        }
        elseif ($opcode -eq 4) {
            Write-Host "bxc"
            $RegB = $RegB -bxor $RegC
        }
        elseif ($opcode -eq 5) {
            Write-Host "out: $combo"
            $output.Add($combo % 8)
        }
        elseif ($opcode -eq 6) {
            Write-Host "bdv: $combo"
            $RegB = [int][Math]::floor($RegA / [Math]::Pow(2, $combo))
        }
        elseif ($opcode -eq 7) {
            Write-Host "cdv: $combo"
            $RegC = [int][Math]::floor($RegA / [Math]::Pow(2, $combo))
        }
        

        $pointer += 2
    }
    $output -join "," | Write-Host
    Write-Host $RegA, $RegB, $RegC
    Write-Host "HALT"
}

$registerA, $registerB, $registerC, $program = Get-DebbugerDataFromFile $input_file

$program -join "," | Write-Host
Write-Host

Get-ProgramOutput $registerA $registerB $registerC $program