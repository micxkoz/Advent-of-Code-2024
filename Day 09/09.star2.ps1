using namespace System.Collections.Generic
$input_file = Get-Content $PSScriptRoot\input.txt

function Get-BlocksRepresentation($DiskMap) {
    $blocks = [List[string]]::new()
    $if_file = $true
    $file_id = 0
    for ($map_i = 0; $map_i -lt $DiskMap.Length; $map_i++) {
        if ($if_file) {
            for ($block_length = 1; $block_length -le [string]$DiskMap[$map_i]; $block_length++) {
                $blocks += [string]$file_id
            }
            $file_id++
            $if_file = $false
        }
        else {
            for ($block_length = 1; $block_length -le [string]$DiskMap[$map_i]; $block_length++) {
                $blocks += "."
            }
            $if_file = $true
        }
    }
    return $blocks
}

function Get-CompactedBlocksNew($BlockMap) {
    $max_file_id = $null
    for ($right_i = $BlockMap.Length-1; $right_i -ge 0; $right_i--) {
        Write-Host $right_i
        if ($BlockMap[$right_i] -eq ".") {continue}
            
        $data_block_size = 0
        for ($temp_right_i = $right_i; $temp_right_i -ge 0; $temp_right_i--) {
            if ($BlockMap[$right_i] -eq $BlockMap[$temp_right_i]) {$data_block_size++}
        }            

        if ($right_i -lt $data_block_size) {break}

        if (-not $max_file_id -or ([int]$BlockMap[$right_i] -lt [int]$max_file_id)) {$max_file_id = $BlockMap[$right_i]}
        else {$right_i = $right_i - $data_block_size + 1; continue}

        
        $gap_index = ($BlockMap[0..$($right_i-$data_block_size)] -replace "\d+", "0" -join "" | Select-String "[.]{$($data_block_size)}").Matches.Index
        if (-not $gap_index) {continue}
        else {
            while ($data_block_size -gt 0) {
                $BlockMap[$gap_index] = $BlockMap[$right_i]
                $BlockMap[$right_i] = "."
                $data_block_size--
                $gap_index++
                $right_i--
            }
        }
        $right_i = $right_i - $data_block_size + 1
    }
    
    return $BlockMap
}

function Get-FileSystemChecksum($CompactedBlockMap) {
    [long]$checksum = 0
    for ($i = 0; $i -lt $CompactedBlockMap.Length; $i++) {
        if ($CompactedBlockMap[$i] -ne ".") {
            $checksum += [int][string]$CompactedBlockMap[$i] * [int]$i
        }
    }
    return $checksum
}

# $block_map = Get-BlocksRepresentation $input_file
# $block_map -join "" | Write-Host
# Write-Host "--"
# $foo = Get-CompactedBlocks $block_map
# Write-Host
# $block_map = Get-BlocksRepresentation $input_file
# $foo = Get-CompactedBlocksNew $block_map

# $block_map = Get-BlocksRepresentation $input_file
# Measure-Command {$foo = Get-CompactedBlocks $block_map} | Format-List TotalMilliseconds
# #$foo -join ""
# $block_map = Get-BlocksRepresentation $input_file
# Measure-Command {$bar = Get-CompactedBlocksNew $block_map} | Format-List TotalMilliseconds
# #$bar -join ""
# $($foo -join "") -eq $($bar -join "")


$block_map = Get-BlocksRepresentation $input_file
$compacted_block_map = Get-CompactedBlocksNew $block_map
Get-FileSystemChecksum $compacted_block_map