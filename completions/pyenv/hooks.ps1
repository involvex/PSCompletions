# Refer to: https://pscompletions.abgox.com/completion/hooks
function handleCompletions($completions) {
    $list = @()

    $input_arr = $PSCompletions.input_arr
    $filter_input_arr = $PSCompletions.filter_input_arr # Exclude option parameters
    $first_item = $filter_input_arr[0] # The first subcommand
    $last_item = $filter_input_arr[-1] # The last subcommand

    # Function to get installed Python versions
    function Get-InstalledVersions {
        $versions = pyenv versions --bare 2>$null
        if ($versions) {
            return $versions
        }
        return @()
    }

    # Function to get available Python versions for installation
    function Get-AvailableVersions {
        $versions = pyenv install --list 2>$null
        if ($versions) {
            return $versions
        }
        return @()
    }

    # Function to get pyenv commands
    function Get-PyenvCommands {
        $commands = pyenv commands 2>$null
        if ($commands) {
            return $commands
        }
        return @()
    }

    # Function to get shell names for init/completions
    function Get-ShellNames {
        return @('bash', 'zsh', 'fish', 'powershell', 'pwsh')
    }

    # Handle commands that need version completion
    switch ($last_item) {
        'local' {
            $installed_versions = Get-InstalledVersions
            foreach ($version in $installed_versions) {
                $list += $PSCompletions.return_completion($version, "Installed version: $version")
            }
        }
        'global' {
            $installed_versions = Get-InstalledVersions
            foreach ($version in $installed_versions) {
                $list += $PSCompletions.return_completion($version, "Installed version: $version")
            }
        }
        'shell' {
            $installed_versions = Get-InstalledVersions
            foreach ($version in $installed_versions) {
                $list += $PSCompletions.return_completion($version, "Installed version: $version")
            }
        }
        'uninstall' {
            $installed_versions = Get-InstalledVersions
            foreach ($version in $installed_versions) {
                $list += $PSCompletions.return_completion($version, "Installed version: $version")
            }
        }
        'install' {
            # Check if --list or --list-all is already in the input
            if ('--list' -notin $input_arr -and '--list-all' -notin $input_arr) {
                $available_versions = Get-AvailableVersions
                foreach ($version in $available_versions) {
                    $list += $PSCompletions.return_completion($version, "Available version: $version")
                }
            }
        }
        'prefix' {
            $installed_versions = Get-InstalledVersions
            foreach ($version in $installed_versions) {
                $list += $PSCompletions.return_completion($version, "Installed version: $version")
            }
        }
        'latest' {
            # Show version prefixes like 3.11, 3.12, etc.
            $available_versions = Get-AvailableVersions
            $version_prefixes = @()
            foreach ($version in $available_versions) {
                if ($version -match '^(\d+\.\d+)') {
                    $prefix = $matches[1]
                    if ($prefix -notin $version_prefixes) {
                        $version_prefixes += $prefix
                    }
                }
            }
            foreach ($prefix in $version_prefixes) {
                $list += $PSCompletions.return_completion($prefix, "Version prefix: $prefix")
            }
        }
        'hooks' {
            $commands = Get-PyenvCommands
            foreach ($command in $commands) {
                $list += $PSCompletions.return_completion($command, "Command: $command")
            }
        }
        'init' {
            $shell_names = Get-ShellNames
            foreach ($shell in $shell_names) {
                $list += $PSCompletions.return_completion($shell, "Shell: $shell")
            }
        }
        'completions' {
            $shell_names = Get-ShellNames
            foreach ($shell in $shell_names) {
                $list += $PSCompletions.return_completion($shell, "Shell: $shell")
            }
        }
        'which' {
            # Get common Python commands
            $installed_versions = Get-InstalledVersions
            if ($installed_versions) {
                $commands = @('python', 'python3', 'pip', 'pip3', 'ipython', 'jupyter', 'pytest', 'black', 'flake8', 'mypy')
                foreach ($command in $commands) {
                    $list += $PSCompletions.return_completion($command, "Python command: $command")
                }
            }
        }
        'whence' {
            # Get common Python commands
            $commands = @('python', 'python3', 'pip', 'pip3', 'ipython', 'jupyter', 'pytest', 'black', 'flake8', 'mypy')
            foreach ($command in $commands) {
                $list += $PSCompletions.return_completion($command, "Python command: $command")
            }
        }
        'exec' {
            # Get common Python commands
            $commands = @('python', 'python3', 'pip', 'pip3', 'ipython', 'jupyter', 'pytest', 'black', 'flake8', 'mypy')
            foreach ($command in $commands) {
                $list += $PSCompletions.return_completion($command, "Python command: $command")
            }
        }
        'help' {
            $commands = Get-PyenvCommands
            foreach ($command in $commands) {
                $list += $PSCompletions.return_completion($command, "Command: $command")
            }
        }
    }

    return $list + $completions
}
