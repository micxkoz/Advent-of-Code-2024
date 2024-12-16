using namespace System.Collections.Generic
$input_file = Get-Content $PSScriptRoot\input.txt

function Get-ParsedDataFromFile($File) {
    $map = [List[array]]::new()
    $if_robot = $false
    $line_number = 0
    foreach ($line in $File) {
        if ($line -eq "") {break}

        $map_row = [List[char]]::new()
        foreach ($char in $line.ToCharArray()) {
            switch ([string]$char) {
                "#" {$map_row.Add("#"); $map_row.Add("#")}
                "O" {$map_row.Add("["); $map_row.Add("]")}
                "." {$map_row.Add("."); $map_row.Add(".")}
                "@" {$map_row.Add("@"); $map_row.Add("."); $if_robot = $true}
            }
        }

        if ($if_robot) {
            $robot_position_y = $line_number
            $robot_position_x = ($map_row -join "" | Select-String "@").Matches.Index
            $if_robot = $false
        }
       
        $line_number++
        
        $map.Add($map_row)
        $map_row.Clear()
    }
    $movements = (Select-String -InputObject $File -Pattern "(?s)[v<^>]{1}.*[v<^>]").Matches -replace " ", ""

    return $map, $movements, $robot_position_y, $robot_position_x
}

function Get-MapAfterMovement($Map, $Y, $X, $direction) {
    if ($direction -eq ">") {
        $patch_map = @{}    
        $patch_map[$X] = "."
        $apply_patch = $true
        for($col = $X+1; $col -lt $Map[$Y].Count; $col++) {
            if ($Map[$Y][$col] -eq "#") {$apply_patch = $false; break}
            $patch_map[$col] = $Map[$Y][$col-1]
            if ($Map[$Y][$col] -eq ".") {break}
        }

        if ($apply_patch) {
            foreach ($key in $patch_map.Keys) {$Map[$Y][$key] = $patch_map[$key]}
            $X++
        }
    }
    elseif ($direction -eq "<") {
        $patch_map = @{}    
        $patch_map[$X] = "."
        $apply_patch = $true
        for($col = $X-1; $col -ge 0; $col--) {
            if ($Map[$Y][$col] -eq "#") {$apply_patch = $false; break}
            $patch_map[$col] = $Map[$Y][$col+1]
            if ($Map[$Y][$col] -eq ".") {break}
        }

        if ($apply_patch) {
            foreach ($key in $patch_map.Keys) {$Map[$Y][$key] = $patch_map[$key]}
            $X--
        }
    }
    elseif ($direction -eq "v") {
        $patch_map = @{} 
        $patch_row = @{}
        $patch_row[$X] = "."
        $patch_map[$Y] = $patch_row
        $apply_patch = $true
        $columns_to_check = [List[int]]::new()
        $columns_to_check.Add($X)

        for ($row = $Y+1; $row -lt $Map.Count; $row++) {
            $columns_to_add = [List[int]]::new()
            $columns_to_remove = [List[int]]::new()
            $patch_row = @{}
            foreach ($col in $columns_to_check) {
                if ($Map[$row][$col] -eq "#") {$apply_patch = $false; break}
                elseif ($Map[$row][$col] -eq "]") {
                    $patch_row[$col] = $Map[$row-1][$col]
                    if ($col-1 -notin $columns_to_check) {$patch_row[$col-1] = "."; $columns_to_add.Add($col-1)}
                }
                elseif ($Map[$row][$col] -eq "[") {
                    $patch_row[$col] = $Map[$row-1][$col]
                    if ($col+1 -notin $columns_to_check) {$patch_row[$col+1] = "."; $columns_to_add.Add($col+1)}
                }
                elseif ($Map[$row][$col] -eq ".") {
                    $patch_row[$col] = $Map[$row-1][$col]
                    $columns_to_remove.Add($col)
                }
            }
            if (-not $apply_patch) {break}
            $patch_map[$row] = $patch_row
            $columns_to_remove | ForEach-Object {$columns_to_check.Remove($_)} | Out-Null
            $columns_to_add | ForEach-Object {$columns_to_check.Add($_)}
            if ($columns_to_check.Count -eq 0) {break}
            
        }
        if ($apply_patch) {
            foreach($row_key in $patch_map.Keys) {
                foreach($column_key in $patch_map[$row_key].Keys) {
                    $Map[$row_key][$column_key] = $patch_map[$row_key][$column_key]
                }
            }
            $Y++
        }
    }
    elseif ($direction -eq "^") {
        $patch_map = @{} 
        $patch_row = @{}
        $patch_row[$X] = "."
        $patch_map[$Y] = $patch_row
        $apply_patch = $true
        $columns_to_check = [List[int]]::new()
        $columns_to_check.Add($X)

        for ($row = $Y-1; $row -ge 0; $row--) {
            $columns_to_add = [List[int]]::new()
            $columns_to_remove = [List[int]]::new()
            $patch_row = @{}
            foreach ($col in $columns_to_check) {
                if ($Map[$row][$col] -eq "#") {$apply_patch = $false; break}
                elseif ($Map[$row][$col] -eq "]") {
                    $patch_row[$col] = $Map[$row+1][$col]
                    if ($col-1 -notin $columns_to_check) {$patch_row[$col-1] = "."; $columns_to_add.Add($col-1)}
                }
                elseif ($Map[$row][$col] -eq "[") {
                    $patch_row[$col] = $Map[$row+1][$col]
                    if ($col+1 -notin $columns_to_check) {$patch_row[$col+1] = "."; $columns_to_add.Add($col+1)}
                }
                elseif ($Map[$row][$col] -eq ".") {
                    $patch_row[$col] = $Map[$row+1][$col]
                    $columns_to_remove.Add($col)
                }
            }
            if (-not $apply_patch) {break}
            $patch_map[$row] = $patch_row
            $columns_to_remove | ForEach-Object {$columns_to_check.Remove($_)} | Out-Null
            $columns_to_add | ForEach-Object {$columns_to_check.Add($_)}
            if ($columns_to_check.Count -eq 0) {break}
            
        }
        if ($apply_patch) {
            foreach($row_key in $patch_map.Keys) {
                foreach($column_key in $patch_map[$row_key].Keys) {
                    $Map[$row_key][$column_key] = $patch_map[$row_key][$column_key]
                }
            }
            $Y--
        }
    }
    return $Map, $Y, $X
}

function Get-SumGPSCoordinates($Map) {
    $sum = 0
    for ($y = 0; $y -lt $Map.Count; $y++) {
        for ($x = 0; $x -lt $Map[$y].Count; $x++) {
            if ($Map[$y][$x] -eq "[") { $sum += $y * 100 + $x }
        }
    }
    return $sum
}

$warehouse_map, $list_of_movements, $robot_y, $robot_x = Get-ParsedDataFromFile $input_file
#$warehouse_map | ForEach-Object {$_ -join ""}
foreach ($move in $list_of_movements.ToCharArray()) {
    #Write-Host $move
    $warehouse_map, $robot_y, $robot_x = Get-MapAfterMovement $warehouse_map $robot_y $robot_x $move
    #$warehouse_map | ForEach-Object {$_ -join ""}
}
#$warehouse_map | ForEach-Object {$_ -join ""}
Get-SumGPSCoordinates $warehouse_map