# Refer to: https://pscompletions.abgox.com/completion/hooks
function handleCompletions($completions) {
    $list = @()

    $input_arr = $PSCompletions.input_arr
    $filter_input_arr = $PSCompletions.filter_input_arr
    $first_item = $filter_input_arr[0]
    $last_item = $filter_input_arr[-1]

    $emulator = "emulator"

    # Cache key for emulator help output
    $cacheKey = "emulator_help_options"
    $cacheDuration = 3600

    # Get help text (cached for performance)
    if ($null -eq $PSCompletions.cache) {
        $PSCompletions.cache = @{}
    }

    if ($PSCompletions.cache[$cacheKey]) {
        $helpText = $PSCompletions.cache[$cacheKey]
    } else {
        $helpText = & $emulator --help 2>$null | Out-String
        $PSCompletions.cache[$cacheKey] = $helpText
    }

    # Parse options from help text
    $options = @{}
    $currentOpt = $null
    $currentDesc = @()

    $lines = $helpText -split "`n"
    foreach ($line in $lines) {
        # Match option lines like: "  -option <value>    description"
        if ($line -match '^\s{2}(-[\w-]+)(?:\s+<[^>]+>)?\s{2,}(.+)$') {
            if ($currentOpt) {
                $options[$currentOpt] = $currentDesc -join " "
            }
            $currentOpt = $matches[1]
            $currentDesc = @($matches[2])
        } elseif ($line -match '^\s{4}(.+)$' -and $currentOpt) {
            # Continuation line
            $currentDesc += $matches[1].Trim()
        } else {
            if ($currentOpt) {
                $options[$currentOpt] = $currentDesc -join " "
            }
            $currentOpt = $null
            $currentDesc = @()
        }
    }
    if ($currentOpt) {
        $options[$currentOpt] = $currentDesc -join " "
    }

    # Build option list for the last token
    if ($last_item -like '-*') {
        $seen = @{}
        foreach ($opt in $options.Keys) {
            if ($opt -like "$last_item*") {
                $alias = $opt -replace '^--', '-'
                $displayOpt = $alias
                if ($seen[$displayOpt]) { continue }
                $seen[$displayOpt] = $true

                $desc = $options[$opt]
                $list += $PSCompletions.return_completion($displayOpt, $desc)
            }
        }
    }

    return $list + $completions
}