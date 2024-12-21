using namespace System.Collections.Generic
$input_file = Get-Content $PSScriptRoot\input.txt

function Get-DoorCodes($File) {
    $door_codes = [List[string]]::new()
    foreach ($line in $File) {
        $door_codes.Add($line)
    }
    return $door_codes
}

function Get-TranslatedNumericCode($Code) {
    $translated_code = [List[int]]::new()
    foreach ($char in $Code.ToCharArray()) {
        switch ($char) {
            "A" {$translated_code.Add("11")}
            "0" {$translated_code.Add("10")}
            "3" {$translated_code.Add("8")}
            "2" {$translated_code.Add("7")}
            "1" {$translated_code.Add("6")}
            "6" {$translated_code.Add("5")}
            "5" {$translated_code.Add("4")}
            "4" {$translated_code.Add("3")}
            "9" {$translated_code.Add("2")}
            "8" {$translated_code.Add("1")}
            "7" {$translated_code.Add("0")}
        }
    }
    return $translated_code
}

function Get-ButtonPressesNumeric($Code) {
    $button_presses = ""
    
    <#
    +---+---+---+
    | 0 | 1 | 2 |
    +---+---+---+
    | 3 | 4 | 5 |
    +---+---+---+
    | 6 | 7 | 8 |
    +---+---+---+
      9 | 10| 11|
        +---+---+
    #>
    
    $button = 11
    $row = [Math]::Floor($button / 3)
    $column = $button % 3
    
    $translated_code = Get-TranslatedNumericCode $Code

    foreach ($next_button in $translated_code) {
        $next_row = [Math]::Floor($next_button / 3)
        $next_column = $next_button % 3
        
        $column_presses = ""
        if ($column - $next_column -gt 0) {$column_presses += $("<" * $($column - $next_column))}
        elseif ($column - $next_column -lt 0) {$column_presses += $(">" * $($next_column - $column))}
    
        $row_presses = ""
        if ($row - $next_row -gt 0) {$row_presses += $("^" * $($row - $next_row))}
        elseif ($row - $next_row -lt 0) {$row_presses += $("v" * $($next_row - $row))}
        
        if ($button -in @(0,3,6) -and $next_button -in @(10, 11)) {
            $button_presses += $column_presses + $row_presses
        }
        elseif ($button -in @(10, 11) -and $next_button -in @(0,3,6)) {
            $button_presses += $row_presses + $column_presses
        }
        else {
            $row_column_score = (Get-ButtonPressesDirectional $(Get-ButtonPressesDirectional $($row_presses + $column_presses + "A"))).Length
            $column_row_score = (Get-ButtonPressesDirectional $(Get-ButtonPressesDirectional $($column_presses + $row_presses + "A"))).Length

            if ($row_column_score -lt $column_row_score) {$button_presses += $row_presses + $column_presses}
            else {$button_presses += $column_presses + $row_presses}
        }

        $button_presses += "A"

        $button = $next_button
        $row = $next_row
        $column = $next_column
    }

    return $button_presses
}

function Get-TranslatedDirectionalCode($Code) {
    $translated_code = [List[int]]::new()
    foreach ($char in $Code.ToCharArray()) {
        switch ($char) {
            "^" {$translated_code.Add("1")}
            "A" {$translated_code.Add("2")}
            "<" {$translated_code.Add("3")}
            "v" {$translated_code.Add("4")}
            ">" {$translated_code.Add("5")}
        }
    }
    return $translated_code
}

function Get-ButtonPressesDirectional($Code) {
    $button_presses = ""
    
    <#
        +---+---+
      0 | 1 | 2 |
    +---+---+---+
    | 3 | 4 | 5 |
    +---+---+---+
    #>

    $starting_button = 2
    $row = [Math]::Floor($starting_button / 3)
    $column = $starting_button % 3

    $translated_code = Get-TranslatedDirectionalCode $Code
    
    foreach ($next_button in $translated_code) {
        $next_row = [Math]::Floor($next_button / 3)
        $next_column = $next_button % 3
        
        $column_presses = ""
        if ($column - $next_column -gt 0) {$column_presses += $("<" * $($column - $next_column))}
        elseif ($column - $next_column -lt 0) {$column_presses += $(">" * $($next_column - $column))}
    
        $row_presses = ""
        if ($row - $next_row -gt 0) {$row_presses += $("^" * $($row - $next_row))}
        elseif ($row - $next_row -lt 0) {$row_presses += $("v" * $($next_row - $row))}
        
        if ($row -eq 0) {$button_presses += $row_presses + $column_presses}
        else {$button_presses += $column_presses + $row_presses}

        $button_presses += "A"

        $row = $next_row
        $column = $next_column
    }

    return $button_presses
}

$door_codes = Get-DoorCodes $input_file

$result = 0
foreach ($door_code in $door_codes) {
    $code_alpha = Get-ButtonPressesNumeric $door_code
    $code_beta = Get-ButtonPressesDirectional $code_alpha
    $code = Get-ButtonPressesDirectional $code_beta
    $result += ([int]$code.Length * [int]$door_code.TrimEnd("A").TrimStart("0"))
}
return $result