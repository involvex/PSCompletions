# Refer to: https://pscompletions.abgox.com/completion/hooks
function handleCompletions($completions) {
    $list = @()

    $input_arr = $PSCompletions.input_arr
    $filter_input_arr = $PSCompletions.filter_input_arr
    $first_item = $filter_input_arr[0]
    $last_item = $filter_input_arr[-1]

    $avdmanager = "avdmanager"

    switch ($first_item) {
        { $_ -in @('create', 'move', 'delete') } {
            $second_item = $filter_input_arr[1]
            if ($second_item -eq 'avd') {
                switch ($last_item) {
                    { $_ -in @('-n', '--name') } {
                        $output = & $avdmanager list avd -c 2>$null
                        foreach ($item in $output) {
                            $name = $item.Trim()
                            if ($name -ne '') {
                                $list += $PSCompletions.return_completion($name, "Android Virtual Device: $name")
                            }
                        }
                    }
                    { $_ -in @('-d', '--device') } {
                        $output = & $avdmanager list device -c 2>$null
                        foreach ($item in $output) {
                            $name = $item.Trim()
                            if ($name -ne '') {
                                $list += $PSCompletions.return_completion($name, "Device definition: $name")
                            }
                        }
                    }
                    { $_ -in @('-k', '--package') } {
                        $output = & $avdmanager list target -c 2>$null
                        foreach ($item in $output) {
                            $name = $item.Trim()
                            if ($name -ne '') {
                                $list += $PSCompletions.return_completion($name, "System image target: $name")
                            }
                        }
                    }
                    { $_ -in @('-g', '--tag') } {
                        $list += $PSCompletions.return_completion("default", "Default system image tag")
                        $list += $PSCompletions.return_completion("google_apis", "Google APIs system image tag")
                        $list += $PSCompletions.return_completion("google_apis_playstore", "Google APIs with Play Store tag")
                    }
                }
            }
        }
    }

    return $list + $completions
}