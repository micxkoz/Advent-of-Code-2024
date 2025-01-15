using namespace System.Collections.Generic
$input_file = Get-Content $PSScriptRoot\input.txt

function Get-DoorCodes($File) {
    $door_codes = [List[string]]::new()
    foreach ($line in $File) {
        $door_codes.Add($line)
    }
    return $door_codes
}

function Get-ButtonPressesNumeric($Code) {
    $keypad = @{
        "7" = @{row = 0; col = 0}; "8" = @{row = 0; col = 1}; "9" = @{row = 0; col = 2};
        "4" = @{row = 1; col = 0}; "5" = @{row = 1; col = 1}; "6" = @{row = 1; col = 2};
        "1" = @{row = 2; col = 0}; "2" = @{row = 2; col = 1}; "3" = @{row = 2; col = 2};
                                   "0" = @{row = 3; col = 1}; "A" = @{row = 3; col = 2}
    }
    $button = "A"
    $row = $keypad[$button].row
    $col = $keypad[$button].col

    $button_presses = [Text.StringBuilder]::new()

    foreach ($next_button in $Code.ToCharArray()) {
        $next_row = $keypad["$next_button"].row
        $next_col = $keypad["$next_button"].col
        
        $col_presses = ""
        if ($col - $next_col -gt 0) {$col_presses = "<" * ($col - $next_col)}
        elseif ($col - $next_col -lt 0) {$col_presses = ">" * ($next_col - $col)}

        $row_presses = ""
        if ($row - $next_row -gt 0) {$row_presses = "^" * ($row - $next_row)}
        elseif ($row - $next_row -lt 0) {$row_presses = "v" * ($next_row - $row)}

        if ($row -eq 3 -and $next_col -eq 0) {
            $button_presses.Append($row_presses + $col_presses + "A") | Out-Null
        }
        elseif ($col -eq 0 -and $next_row -eq 3) {
            $button_presses.Append($col_presses + $row_presses + "A") | Out-Null
        }
        elseif ($row_presses -eq "" -or $col_presses -eq "") {
            $button_presses.Append($col_presses + $row_presses + "A") | Out-Null
        }
        else {
            $col_row = Get-ButtonPressesDirectional $($col_presses + $row_presses + "A")
            $row_col = Get-ButtonPressesDirectional $($row_presses + $col_presses + "A")
            while ($col_row.Length -eq $row_col.Length) {
                $col_row = Get-ButtonPressesDirectional $col_row
                $row_col = Get-ButtonPressesDirectional $row_col
            }
            if ($col_row.Length -lt $row_col.Length) {
                $button_presses.Append($col_presses + $row_presses + "A") | Out-Null
            }
            else {
                $button_presses.Append($row_presses + $col_presses + "A") | Out-Null
            }
        }

        $button = $next_button.ToString()
        $row = $next_row
        $col = $next_col
    }
    $button_presses = $button_presses.ToString()
    return $button_presses
}

function Get-ButtonPressesDirectional($Sequence) {
    $keypad = @{
                                   "^" = @{row = 0; col = 1}; "A" = @{row = 0; col = 2};
        "<" = @{row = 1; col = 0}; "v" = @{row = 1; col = 1}; ">" = @{row = 1; col = 2}
    }

    $button = "A"
    $row = $keypad[$button].row
    $col = $keypad[$button].col

    $button_presses = [Text.StringBuilder]::new()

    foreach ($next_button in $Sequence.ToCharArray()) {
        $next_row = $keypad["$next_button"].row
        $next_col = $keypad["$next_button"].col
        
        $col_presses = ""
        if ($col - $next_col -gt 0) {$col_presses = "<" * ($col - $next_col)}
        elseif ($col - $next_col -lt 0) {$col_presses = ">" * ($next_col - $col)}

        $row_presses = ""
        if ($row - $next_row -gt 0) {$row_presses = "^" * ($row - $next_row)}
        elseif ($row - $next_row -lt 0) {$row_presses = "v" * ($next_row - $row)}

       
        if ($row -eq 0 -and $next_col -eq 0) {
            $button_presses.Append($row_presses + $col_presses + "A") | Out-Null
        }
        elseif ($col -eq 0 -and $next_row -eq 0) {
            $button_presses.Append($col_presses + $row_presses + "A") | Out-Null
        }
        elseif ($row_presses -eq "" -or $col_presses -eq "") {
            $button_presses.Append($col_presses + $row_presses + "A") | Out-Null 
        }
        
        #button order determined empirically
        elseif ($col_presses -eq "<" -and $row_presses -eq "v") {
            $button_presses.Append($col_presses + $row_presses + "A") | Out-Null
        }
        elseif ($col_presses -eq ">" -and $row_presses -eq "v") {
            $button_presses.Append($row_presses + $col_presses + "A") | Out-Null
        }
        elseif ($col_presses -eq "<" -and $row_presses -eq "^") {
            $button_presses.Append($col_presses + $row_presses + "A") | Out-Null
        }
        elseif ($col_presses -eq ">" -and $row_presses -eq "^") {
            $button_presses.Append($row_presses + $col_presses + "A") | Out-Null
        }
        else {
            Write-Error "Unexpected case. col_presses: $col_presses; row_presses: $row_presses"
        }

        $button = $next_button.ToString()
        $row = $next_row
        $col = $next_col
    }

    $button_presses = $button_presses.ToString()
    return $button_presses
}

$door_codes = Get-DoorCodes $input_file

[long]$result = 0
foreach ($door_code in $door_codes) {
    $sequence_for_code = Get-ButtonPressesNumeric $door_code
    
    $sequences_dict = @{}
    $sequence_for_code -split "(?<=A)" | Where-Object {$_ -ne ""} | ForEach-Object {$sequences_dict[$_] += 1}

    for ($robots = 25; $robots -gt 0; $robots--) {
        $parent_sequences_dict = @{}

        foreach ($sequence in $sequences_dict.Keys) {
            $parent_sequence = Get-ButtonPressesDirectional $sequence
            $parent_sequence -split "(?<=A)" | Where-Object {$_ -ne ""} | ForEach-Object {$parent_sequences_dict[$_] += $sequences_dict[$sequence]}
        }

        $sequences_dict = $parent_sequences_dict
    }

    foreach ($key in $sequences_dict.Keys) {
        $result += [long]$sequences_dict[$key] * $key.Length * [int]$door_code.TrimEnd("A").TrimStart("0")
    }
}
return $result