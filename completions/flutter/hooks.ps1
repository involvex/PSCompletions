function handleCompletions($completions) {
    $list = @()

    $input_arr = $PSCompletions.input_arr
    $filter_input_arr = $PSCompletions.filter_input_arr
    $first_item = $filter_input_arr[0]
    $last_item = $filter_input_arr[-1]

    switch ($first_item) {
        { 'devices' -in $input_arr -or 'emulators' -in $input_arr } {
            if ($last_item -notlike '-*') {
                $device_list = @(flutter devices --machine 2>$null | ConvertFrom-Json)
                foreach ($device in $device_list) {
                    $info = "$($device.id) - $($device.name)"
                    $list += $PSCompletions.return_completion($device.id, $info)
                }
            }
        }
        'run' {
            if ($last_item -in @('-d', '--device-id')) {
                $device_list = @(flutter devices --machine 2>$null | ConvertFrom-Json)
                foreach ($device in $device_list) {
                    $info = "$($device.id) - $($device.name)"
                    $list += $PSCompletions.return_completion($device.id, $info)
                }
            }
        }
        'attach' {
            if ($last_item -in @('-d', '--debug-port')) {
                $device_list = @(flutter devices --machine 2>$null | ConvertFrom-Json)
                foreach ($device in $device_list) {
                    if ($device.supportsDebugging) {
                        $info = "$($device.id) - $($device.name)"
                        $list += $PSCompletions.return_completion($device.id, $info)
                    }
                }
            }
        }
        'build' {
            if ($last_item -in @('apk', 'appbundle', 'ios', 'ipad', 'iphone', 'macos')) {
                $device_list = @(flutter devices --machine 2>$null | ConvertFrom-Json)
                foreach ($device in $device_list) {
                    $info = "$($device.id) - $($device.name)"
                    $list += $PSCompletions.return_completion($device.id, $info)
                }
            }
        }
        'emulators' {
            if ($last_item -in @('launch', 'l')) {
                $emulator_list = @(flutter emulators 2>$null)
                $started = $false
                foreach ($line in $emulator_list) {
                    if ($line -match '^\d+') {
                        $parts = $line -split '\s+'
                        if ($parts.Count -ge 3) {
                            $id = $parts[1].TrimEnd(':')
                            $name = ($parts[2..($parts.Count - 1)] -join ' ')
                            $list += $PSCompletions.return_completion($id, $name)
                        }
                    }
                }
            }
        }
    }

    return $list + $completions
}