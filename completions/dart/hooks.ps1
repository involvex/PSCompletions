function handleCompletions($completions) {
    $list = @()

    $input_arr = $PSCompletions.input_arr
    $filter_input_arr = $PSCompletions.filter_input_arr
    $first_item = $filter_input_arr[0]
    $last_item = $filter_input_arr[-1]

    switch ($first_item) {
        'run' {
            if ($last_item -notlike '-*' -and $last_item -ne 'run') {
                $dart_files = Get-ChildItem -Path . -Filter "*.dart" -Recurse -File -ErrorAction SilentlyContinue | Where-Object { $_.Name -match '^bin\\|^lib\\|^test\\' } | Select-Object -ExpandProperty FullName
                foreach ($file in $dart_files) {
                    $list += $PSCompletions.return_completion($file, $file)
                }
            }
        }
        'test' {
            if ($last_item -notlike '-*' -and $last_item -ne 'test') {
                $test_files = Get-ChildItem -Path . -Filter "*test*.dart" -Recurse -File -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName
                foreach ($file in $test_files) {
                    $list += $PSCompletions.return_completion($file, $file)
                }
            }
        }
    }

    return $list + $completions
}