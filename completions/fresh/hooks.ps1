# Refer to: https://pscompletions.abgox.com/completion/hooks
function handleCompletions($completions) {
    $list = @()

    $input_arr = $PSCompletions.input_arr
    $filter_input_arr = $PSCompletions.filter_input_arr # Exclude option parameters

    $last_item = $filter_input_arr[-1]

    function return_daemon_verbs {
        $verbs = @()
        $verbs += $PSCompletions.return_completion('list', 'List active daemons')
        $verbs += $PSCompletions.return_completion('attach', 'Attach to a daemon (NAME or the current directory)')
        $verbs += $PSCompletions.return_completion('new', 'Start a new named daemon')
        $verbs += $PSCompletions.return_completion('kill', 'Terminate a daemon')
        $verbs += $PSCompletions.return_completion('info', 'Show information about a daemon')
        $verbs += $PSCompletions.return_completion('open-file', 'Open files in a daemon (--wait blocks until done)')
        return $verbs
    }

    function return_daemon_names {
        # `fresh --cmd daemon list` prints names as single indented tokens between header lines.
        $names = @()
        # Skip aliases (e.g. the auto-created 'fresh' -> 'fresh-editor' trigger alias) and find the real executable
        if (Get-Command fresh -CommandType ExternalScript, Application -ErrorAction SilentlyContinue) {
            try {
                fresh --cmd daemon list 2>$null | ForEach-Object {
                    if ($_ -match '^\s+([^\s:]+)\s*$') {
                        $names += $PSCompletions.return_completion($Matches[1], 'daemon')
                    }
                }
            }
            catch {}
        }
        return $names
    }

    if ('--cmd' -cin $input_arr) {
        switch ($last_item) {
            { $_ -in 'daemon', 'session' } {
                $list += return_daemon_verbs
            }
            { $_ -in 'attach', 'kill', 'open-file' } {
                $list += return_daemon_names
            }
            'config' {
                $list += $PSCompletions.return_completion('show', 'Print the effective configuration')
                $list += $PSCompletions.return_completion('paths', 'Show the directories used by Fresh')
            }
            'grammar' {
                $list += $PSCompletions.return_completion('list', 'List all available grammars (with source info)')
            }
            'init' {
                $list += $PSCompletions.return_completion('check', 'Syntax-check ~/.config/fresh/init.ts without running it')
                $list += $PSCompletions.return_completion('reload', 'Re-read and run init.ts in the running editor')
            }
            'command' {
                $list += $PSCompletions.return_completion('run', 'Run a registered command by its command-palette name')
                $list += $PSCompletions.return_completion('list', 'List registered commands (built-in + plugin)')
            }
            'script' {
                $list += $PSCompletions.return_completion('api', 'Search the API by name or description')
                $list += $PSCompletions.return_completion('check', 'Parse + check editor.* names, without running')
                $list += $PSCompletions.return_completion('run', 'Evaluate against this workspace (default: stdin)')
                $list += $PSCompletions.return_completion('types', 'Print paths of the API declaration files')
            }
            'help' {
                $list += $PSCompletions.return_completion('tour', 'Guided code tours (fresh and VS Code CodeTour formats)')
                $list += $PSCompletions.return_completion('script', 'Drive a running editor with TypeScript')
                $list += $PSCompletions.return_completion('plugin', 'Write init.ts / a plugin')
            }
        }
    }

    if ($input_arr[-1] -cin '-a', '--attach') {
        $list += return_daemon_names
    }

    return $list + $completions
}
