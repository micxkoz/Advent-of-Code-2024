using namespace System.Collections.Generic
$puzzle_input = Get-Content -Path $PSScriptRoot\input.txt

function Get-SystemDesign ($PuzzleInput) {

    $system = @{}
    foreach ($line in $puzzle_input) {
        if ($line -like "* -> *") {
            $gate_input, $gate_output = $line -split " -> "
            $wire_left, $gate_operator, $wire_right = $gate_input -split " "

            $system[$gate_output] = @{operator=$gate_operator; wires=$wire_left+"-"+$wire_right}
        }
    }
    return $system
}

function Get-SystemOutput ($SystemDesign, $XBinary, $YBinary) {
    $gate_values = @{}

    $counter = 44
    foreach ($bit in $XBinary.ToCharArray()) {
        $gate_values[$("x" + $counter.ToString().PadLeft(2, "0"))] = [bool][int][string]$bit
        $counter--
    }
    $counter = 44
    foreach ($bit in $YBinary.ToCharArray()) {
        $gate_values[$("y" + $counter.ToString().PadLeft(2, "0"))] = [bool][int][string]$bit
        $counter--
    }
    
    $loop_counter = 45 # limit chosen arbitrarily
    do {
        $all_gates_with_value = $true
    
        foreach ($gate in $SystemDesign.GetEnumerator()) {
    
            if ($gate_values.ContainsKey($gate.Key)) {continue}
    
            $wire_1, $wire_2 = $gate.Value["wires"] -split "-"
            
            if ($null -eq $gate_values[$wire_1] -or $null -eq $gate_values[$wire_2]) {
                $all_gates_with_value = $false
                continue
            }
            
            switch -CaseSensitive ($gate.Value["operator"]) {
                "AND" {$gate_values[$gate.Key] = $gate_values[$wire_1] -and $gate_values[$wire_2]}
                "XOR" {$gate_values[$gate.Key] = $gate_values[$wire_1] -xor $gate_values[$wire_2]}
                "OR" {$gate_values[$gate.Key] = $gate_values[$wire_1] -or $gate_values[$wire_2]}
            }
        }
        $loop_counter--
    } until ($all_gates_with_value -or $loop_counter -le 0)

    $system_value = ""
    for ($i = 45; $i -ge 0; $i--) {
        $system_value += [string][int]$gate_values[$("z" + $i.ToString().PadLeft(2, "0"))]
    }
    return $system_value
}

function Get-FaultyZWires ($SystemDesign) {
    $broken_z = @()
    
    for ($i = 0; $i -lt 45; $i++) {
        $power = [math]::Pow(2, $i)
        $zero = 0
        
        $power_binary = [Convert]::ToString($power, 2).PadLeft(45, "0")
        $zero_binary = [Convert]::ToString($zero, 2).PadLeft(45, "0")

        $output_1 = Get-SystemOutput $SystemDesign $power_binary $power_binary
        $output_2 = Get-SystemOutput $SystemDesign $power_binary $zero_binary
        
        if ([Convert]::ToInt64($output_1, 2) -ne ($power + $power)) {$broken_z += $i+1}
        if ([Convert]::ToInt64($output_2, 2) -ne ($power)) {$broken_z += $i+1}
    }
    
    return $broken_z | Sort-Object -Unique
}

function Get-UniqueGatesForZWires ($SystemDesign, $Wires) {
    $unique_gates = @{}
    foreach ($wire in $Wires) {
        $z_wire = "z" + $wire.ToString().PadLeft(2, "0")
        $next_level = [List[string]]@($z_wire)

        do {
            $current_level = [List[string]]::new($next_level.ToArray())
            $next_level.Clear()

            foreach ($gate in $current_level) {
                if ($unique_gates.ContainsKey($gate)) {$unique_gates.Remove($gate)}
                else {$unique_gates[$gate] = $true}
                $SystemDesign[$gate]["wires"] -split "-" | ForEach-Object {if ($_ -cnotmatch "^[xy]") {$next_level.Add($_)}}
            }

        } while ($next_level.Count -gt 0)
    }
    return $unique_gates.Keys
}

function Switch-Gates ($SystemDesign, $FirstGate, $SecondGate) {
    $copy_of_design = $SystemDesign.Clone()
    $swap = $copy_of_design[$FirstGate]
    $copy_of_design[$FirstGate] = $copy_of_design[$SecondGate]
    $copy_of_design[$SecondGate] = $swap

    return $copy_of_design
}

$system_design = Get-SystemDesign $puzzle_input
$faulty_wires = Get-FaultyZWires $system_design

$tangled_faulty_wires = @()
$swap = @($faulty_wires[0])
for ($i = 1; $i -lt $faulty_wires.Count; $i++) {
    if ($faulty_wires[$i-1] + 1 -eq $faulty_wires[$i]) {$swap += $faulty_wires[$i]}
    else {
        $tangled_faulty_wires += , $swap
        $swap = @($faulty_wires[$i])
    }
}
$tangled_faulty_wires += , $swap

$result = @()
:next_group foreach ($group in $tangled_faulty_wires) {
    $suspect_pool = Get-UniqueGatesForZWires $system_design $group
    
    for ($i = 0; $i -lt $suspect_pool.Count; $i++) {
        for ($j = $i+1; $j -lt $suspect_pool.Count; $j++) {
            $proposed_system = Switch-Gates $system_design $suspect_pool[$i] $suspect_pool[$j]

            $zero_binary = [Convert]::ToString(0, 2).PadLeft(45, "0")

            $prev_power = [math]::Pow(2, ($group | Measure-Object -Minimum).Minimum - 1)
            $prev_power_binary = [Convert]::ToString($prev_power, 2).PadLeft(45, "0")

            if ([Convert]::ToInt64($(Get-SystemOutput $proposed_system $prev_power_binary $prev_power_binary), 2) -ne ($prev_power + $prev_power)) {continue}
            if ([Convert]::ToInt64($(Get-SystemOutput $proposed_system $prev_power_binary $zero_binary), 2) -ne ($prev_power)) {continue}
            
            $min_power = [math]::Pow(2, ($group | Measure-Object -Minimum).Minimum)
            $min_power_binary = [Convert]::ToString($min_power, 2).PadLeft(45, "0")
            
            if ([Convert]::ToInt64($(Get-SystemOutput $proposed_system $min_power_binary $min_power_binary), 2) -ne ($min_power + $min_power)) {continue}
            if ([Convert]::ToInt64($(Get-SystemOutput $proposed_system $min_power_binary $zero_binary), 2) -ne ($min_power)) {continue}
            
            if ($group.Count -gt 1) {
                $max_power = [math]::Pow(2, ($group | Measure-Object -Maximum).Maximum)
                $max_power_binary = [Convert]::ToString($max_power, 2).PadLeft(45, "0")
                
                if ([Convert]::ToInt64($(Get-SystemOutput $proposed_system $max_power_binary $max_power_binary), 2) -ne ($max_power + $max_power)) {continue}
                if ([Convert]::ToInt64($(Get-SystemOutput $proposed_system $max_power_binary $zero_binary), 2) -ne ($max_power)) {continue}
            }

            $combined_power = [math]::Pow(2, ($group | Measure-Object -Minimum).Minimum) + $prev_power
            $combined_power_binary = [Convert]::ToString($combined_power, 2).PadLeft(45, "0")
            
            if ([Convert]::ToInt64($(Get-SystemOutput $proposed_system $combined_power_binary $combined_power_binary), 2) -ne ($combined_power + $combined_power)) {continue}
            if ([Convert]::ToInt64($(Get-SystemOutput $proposed_system $combined_power_binary $prev_power_binary), 2) -ne ($combined_power + $prev_power)) {continue}

            $result += @($suspect_pool[$i], $suspect_pool[$j])
            continue next_group
        }
    }
}

$result | Sort-Object |  Join-String -Separator ","