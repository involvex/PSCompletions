# Ionic CLI Completions Hooks
function handleCompletions($completions) {
    $list = @()

    $input_arr = $PSCompletions.input_arr
    $filter_input_arr = $PSCompletions.filter_input_arr
    $first_item = $filter_input_arr[0]
    $last_item = $filter_input_arr[-1]
    $second_last = if ($filter_input_arr.Count -gt 1) { $filter_input_arr[$filter_input_arr.Count - 2] } else { $null }

    switch ($first_item) {
        'start' {
            $templates = @('blank', 'tabs', 'sidemenu', 'list', 'my-first-app', 'conference', 'aws-starter', 'ionic-angular', 'ionic1', 'ionic2', 'ionic-angular-oauth', 'react', 'vue')
            foreach ($tpl in $templates) {
                if ($tpl -notin $filter_input_arr) {
                    $list += $PSCompletions.return_completion($tpl, "Starter template")
                }
            }
        }
        'capacitor' {
            switch ($last_item) {
                'add' {
                    $platforms = @('android', 'ios', 'electron', 'pwa')
                    foreach ($plat in $platforms) {
                        if ($plat -notin $filter_input_arr) {
                            $list += $PSCompletions.return_completion($plat, "Capacitor platform")
                        }
                    }
                }
                'run' {
                    $platforms = @('android', 'ios', 'electron')
                    foreach ($plat in $platforms) {
                        if ($plat -notin $filter_input_arr) {
                            $list += $PSCompletions.return_completion($plat, "Run on platform")
                        }
                    }
                }
                'build' {
                    $platforms = @('android', 'ios', 'electron')
                    foreach ($plat in $platforms) {
                        if ($plat -notin $filter_input_arr) {
                            $list += $PSCompletions.return_completion($plat, "Build for platform")
                        }
                    }
                }
                'open' {
                    $platforms = @('android', 'ios', 'electron')
                    foreach ($plat in $platforms) {
                        if ($plat -notin $filter_input_arr) {
                            $list += $PSCompletions.return_completion($plat, "Open platform project")
                        }
                    }
                }
                'sync' {
                    $platforms = @('android', 'ios', 'electron')
                    foreach ($plat in $platforms) {
                        if ($plat -notin $filter_input_arr) {
                            $list += $PSCompletions.return_completion($plat, "Sync platform")
                        }
                    }
                }
            }
        }
        'cordova' {
            switch ($last_item) {
                'platform' {
                    $actions = @('add', 'remove', 'update', 'ls', 'check', 'save')
                    foreach ($act in $actions) {
                        if ($act -notin $filter_input_arr -and $act -ne 'rm') {
                            $list += $PSCompletions.return_completion($act, "Platform action")
                        }
                    }
                    $platforms = @('android', 'ios', 'browser', 'electron')
                    foreach ($plat in $platforms) {
                        if ($plat -notin $filter_input_arr) {
                            $list += $PSCompletions.return_completion($plat, "Cordova platform")
                        }
                    }
                }
                'plugin' {
                    $actions = @('add', 'remove', 'ls', 'save')
                    foreach ($act in $actions) {
                        if ($act -notin $filter_input_arr -and $act -ne 'rm') {
                            $list += $PSCompletions.return_completion($act, "Plugin action")
                        }
                    }
                }
            }
        }
        'integrations' {
            switch ($last_item) {
                'enable' {
                    $integrations = @('capacitor', 'cordova')
                    foreach ($int in $integrations) {
                        if ($int -notin $filter_input_arr) {
                            $list += $PSCompletions.return_completion($int, "Integration")
                        }
                    }
                }
                'disable' {
                    $integrations = @('capacitor', 'cordova')
                    foreach ($int in $integrations) {
                        if ($int -notin $filter_input_arr) {
                            $list += $PSCompletions.return_completion($int, "Integration")
                        }
                    }
                }
            }
        }
    }

    if ($second_last -eq 'capacitor' -and $last_item -eq 'run') {
        $platforms = @('android', 'ios', 'electron')
        foreach ($plat in $platforms) {
            if ($plat -notin $filter_input_arr) {
                $list += $PSCompletions.return_completion($plat, "Capacitor platform")
            }
        }
    }

    if ($second_last -eq 'cordova' -and $last_item -eq 'platform') {
        $platforms = @('android', 'ios', 'browser', 'electron')
        foreach ($plat in $platforms) {
            if ($plat -notin $filter_input_arr) {
                $list += $PSCompletions.return_completion($plat, "Cordova platform")
            }
        }
    }

    return $list + $completions
}