# Refer to: https://pscompletions.abgox.com/completion/hooks
function handleCompletions($completions) {
    $list = @()

    $input_arr = $PSCompletions.input_arr
    $filter_input_arr = $PSCompletions.filter_input_arr
    $first_item = $filter_input_arr[0]
    $last_item = $filter_input_arr[-1]
    $word = $PSCompletions.word

    $sdkmanager = "sdkmanager"

    function Get-InstalledPackages {
        $output = & $sdkmanager --list_installed 2>$null
        $packages = @()
        $in_table = $false
        foreach ($line in $output) {
            if ($line -match '^\s*Path\s*\|') {
                $in_table = $true
                continue
            }
            if ($in_table -and $line -match '^\s*[-]+\s*\|') {
                continue
            }
            if ($in_table -and $line -match '^\s*(\S+)\s*\|') {
                $pkg = $matches[1].Trim()
                if ($pkg -ne '') {
                    $packages += $pkg
                }
            }
        }
        return $packages
    }

    $common_prefixes = @(
        "build-tools;",
        "platforms;",
        "platform-tools",
        "ndk;",
        "cmake;",
        "emulator",
        "cmdline-tools;",
        "extras;",
        "system-images;"
    )

    $is_package_arg = ($last_item -notmatch '^-') -and ($last_item -ne 'sdkmanager')

    if ($is_package_arg) {
        $installed = Get-InstalledPackages
        foreach ($pkg in $installed) {
            $list += $PSCompletions.return_completion($pkg, "Installed SDK package: $pkg")
        }
        foreach ($prefix in $common_prefixes) {
            $list += $PSCompletions.return_completion($prefix, "SDK package category prefix")
        }
    }

    return $list + $completions
}