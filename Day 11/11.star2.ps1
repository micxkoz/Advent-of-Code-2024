using namespace System.Collections.Generic
$input_file = Get-Content $PSScriptRoot\input.txt

function Get-ParsedFile($File) {
    [List[int]]$stones_line += $File -split " "
    return $stones_line
}

$Cache = @{}

function Get-StoneAfterBlink([double]$Stone, [int]$BlinkCounter, [int]$BlinkLimit) {
    if ($BlinkCounter -eq $BlinkLimit) {return 1}
    
    $cache_key = "$($Stone):$($BlinkCounter)"
    if ($Cache.ContainsKey($cache_key)) {return $Cache[$cache_key]}

    $number_of_stones = 0
    if ($BlinkCounter -lt $BlinkLimit) {
        $next_blink_counter = $BlinkCounter + 1
        
        if ($Stone -eq 0) {
            $number_of_stones += Get-StoneAfterBlink 1 $next_blink_counter $BlinkLimit
        }
        elseif (([string]$Stone).Length % 2 -eq 0) {
            $divide_index = ([string]$Stone).Length / 2
            $divided_stone_left = [double](([string]$Stone)[0..$($divide_index-1)] -join "")
            $divided_stone_right = [double](([string]$Stone)[$divide_index..([string]$Stone).Length] -join "")

            $number_of_stones += Get-StoneAfterBlink $divided_stone_left $next_blink_counter $BlinkLimit
            $number_of_stones += Get-StoneAfterBlink $divided_stone_right $next_blink_counter $BlinkLimit
        }
        else {
            $new_stone = $Stone * 2024
            $number_of_stones += Get-StoneAfterBlink $new_stone $next_blink_counter $BlinkLimit
        }
    }
    $Cache[$cache_key] = $number_of_stones
    return $number_of_stones
}

$stone_line = Get-ParsedFile $input_file

$result = 0
foreach ($stone in $stone_line) {
    $result += Get-StoneAfterBlink $stone 0 75
}
return $result
