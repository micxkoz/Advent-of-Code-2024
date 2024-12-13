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

function Get-CompactedBlocks($BlockMap) {
    $compacted_blocks = [List[string]]::new()
    $right_i = $BlockMap.Length-1
    for ($left_i = 0; $left_i -lt $BlockMap.Length -and $left_i -le $right_i; $left_i++) {
        if ($BlockMap[$left_i] -eq ".") {
            for(; $right_i -gt $left_i; $right_i--)
            {
                if ($BlockMap[$right_i] -ne ".") {$compacted_blocks += $BlockMap[$right_i]; $right_i--; break}
            }
        }
        else {$compacted_blocks += $BlockMap[$left_i]}
    }
    return $compacted_blocks
}

function Get-FileSystemChecksum($CompactedBlockMap) {
    [long]$checksum = 0
    for ($i = 0; $i -lt $CompactedBlockMap.Length; $i++) {
        $checksum += [int][string]$CompactedBlockMap[$i] * [int]$i
    }
    return $checksum
}

$block_map = Get-BlocksRepresentation $input_file
$compacted_block_map = Get-CompactedBlocks $block_map
Get-FileSystemChecksum $compacted_block_map
