# android-cli completion

function handleCompletions($completions) {
    $list = @()

    $input_arr = $PSCompletions.input_arr
    $filter_input_arr = $PSCompletions.filter_input_arr
    $word = $PSCompletions.word
    $command = $PSCompletions.command

    $commandArgs = @{
        create = @{
            options = @('--dry-run', '--verbose', '--name=', '--output=')
            args = @('list')
        }
        'create list' = @{
            direct = @()
        }
        describe = @{
            options = @('--project_dir=')
        }
        docs = @{
            subcommands = @('search', 'fetch')
        }
        emulator = @{
            subcommands = @('create', 'list', 'start', 'stop')
        }
        'emulator create' = @{
            options = @('--list-profiles', '--profile=')
        }
        'emulator list' = @{ direct = @() }
        'emulator start' = @{ options = @() }
        'emulator stop' = @{ options = @() }
        info = @{ direct = @() }
        init = @{ direct = @() }
        layout = @{
            options = @('--pretty', '--output=', '--diff')
        }
        skills = @{
            subcommands = @('add', 'find', 'list', 'remove')
        }
        'skills add' = @{
            options = @('--all', '--agent=', '--skill=')
        }
        'skills find' = @{ options = @() }
        'skills list' = @{
            options = @('--long')
        }
        'skills remove' = @{
            options = @('--agent=', '--skill=')
        }
        screen = @{
            subcommands = @('capture', 'resolve')
        }
        'screen capture' = @{
            options = @('--output=', '--annotate')
        }
        'screen resolve' = @{
            options = @('--screenshot=', '--string=')
        }
        sdk = @{
            subcommands = @('install', 'list', 'remove', 'update')
        }
        'sdk install' = @{
            options = @('--beta', '--canary', '--force')
        }
        'sdk list' = @{
            options = @('--all', '--all-versions', '--beta', '--canary')
        }
        'sdk remove' = @{ options = @() }
        'sdk update' = @{
            options = @('--beta', '--canary', '--force')
        }
        run = @{
            options = @('--debug', '--activity=', '--device=', '--type=', '--apks=')
        }
        update = @{ direct = @() }
    }

    $globalOptions = @('-h', '--help', '--sdk=')

    $first = $filter_input_arr[0]
    $second = $filter_input_arr[1]
    $third = $filter_input_arr[2]

    if ($filter_input_arr.Count -le 1) {
        $subcommands = @('create', 'describe', 'docs', 'emulator', 'info', 'init', 'layout', 'skills', 'screen', 'sdk', 'run', 'update')
        foreach ($cmd in $subcommands) {
            if ($cmd.StartsWith($word, [StringComparison]::CurrentCultureIgnoreCase)) {
                $list += $PSCompletions.return_completion($cmd, "")
            }
        }
        foreach ($opt in $globalOptions) {
            if ($opt.StartsWith($word, [StringComparison]::CurrentCultureIgnoreCase)) {
                $list += $PSCompletions.return_completion($opt, "")
            }
        }
        return $list + $completions
    }

    $fullCmd = $first
    if ($second) {
        $fullCmd = "$first $second"
    }

    if ($commandArgs.ContainsKey($fullCmd)) {
        $cmdData = $commandArgs[$fullCmd]

        if ($cmdData.subcommands) {
            foreach ($sub in $cmdData.subcommands) {
                if ($sub.StartsWith($word, [StringComparison]::CurrentCultureIgnoreCase)) {
                    $list += $PSCompletions.return_completion($sub, "")
                }
            }
            return $list + $completions
        }

        if ($cmdData.options) {
            foreach ($opt in $cmdData.options) {
                if ($opt.StartsWith($word, [StringComparison]::CurrentCultureIgnoreCase)) {
                    $list += $PSCompletions.return_completion($opt, "")
                }
            }
            return $list + $completions
        }

        if ($cmdData.args -contains 'list') {
            $list += $PSCompletions.return_completion('list', "")
            return $list + $completions
        }
    }

    return $list + $completions
}