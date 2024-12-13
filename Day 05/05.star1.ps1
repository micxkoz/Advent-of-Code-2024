$file = Get-Content $PSScriptRoot\input.txt

$rules_dictionary = @{}
$result = 0

foreach ($line in $file) {
    
    if ($line -match "\|") {
        $rule = $line -split "\|"
        $rules_dictionary[$rule[0]] += @($rule[1])
    }

    if ($line -match ",") {
        $update_is_correct = $true
        $page_numbers = $line -split ","

        for ($page = 1; $page -lt $page_numbers.Count; $page++) {
            $previous_pages = $page_numbers[0..$($page-1)]
            $forbidden_pages_for_current_page = $rules_dictionary[$page_numbers[$page]]
            
            if ($previous_pages | Where-Object {$_ -in $forbidden_pages_for_current_page}) {$update_is_correct = $false; break}
        }
        if ($update_is_correct) {$result += $page_numbers[($page_numbers.Count - 1) / 2]}
    }
}

return $result