$file = Get-Content $PSScriptRoot\input.txt

$rules_dictionary = @{}
$result = 0

foreach ($line in $file) {
    
    if ($line -match "\|") {
        $rule = $line -split "\|"
        $rules_dictionary[$rule[0]] += @($rule[1])
    }

    if ($line -match ",") {
        [System.Collections.Generic.List[string]]$page_numbers = $line -split ","

        for ($page = 1; $page -lt $page_numbers.Count; $page++) {
            
            $previous_pages = $page_numbers[0..$($page-1)]
            $forbidden_pages_for_current_page = $rules_dictionary[$page_numbers[$page]]

            if ($previous_pages | Where-Object {$_ -in $forbidden_pages_for_current_page}) {
                
                $corrected_update = @()

                for ($pages_in_rule_target = $page_numbers.Count-1; $pages_in_rule_target -ge 0 ; $pages_in_rule_target--) {
                   
                    for ($page_and_its_rule_to_check = 0; $page_and_its_rule_to_check -lt $page_numbers.Count; $page_and_its_rule_to_check++) {
                        
                        [System.Collections.Generic.List[string]]$page_numbers_without_one_page = $page_numbers.ToArray()
                        $page_numbers_without_one_page.Remove($page_numbers[$page_and_its_rule_to_check]) | Out-Null
        
                        $rule_for_checked_page = $rules_dictionary[$page_numbers[$page_and_its_rule_to_check]]
                        $intersection_cardinality = ($page_numbers_without_one_page | Where-Object {$_ -in $rule_for_checked_page}).Count

                        if ($intersection_cardinality -eq $pages_in_rule_target) {$corrected_update += $page_numbers[$page_and_its_rule_to_check]; break}
                    }
                }
            
                $result += $corrected_update[($corrected_update.Count - 1) / 2]
                break
            }
        }
    }

}

return $result