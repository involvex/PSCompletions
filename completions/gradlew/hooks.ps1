function handleCompletions($completions) {
    $list = @()

    $input_arr = $PSCompletions.input_arr
    $filter_input_arr = $PSCompletions.filter_input_arr
    $first_item = $filter_input_arr[0]
    $last_item = $filter_input_arr[-1]

    # Check if we're in a gradle project directory
    $gradlewExists = Test-Path ".\gradlew" -PathType Leaf
    $gradlewBatExists = Test-Path ".\gradlew.bat" -PathType Leaf

    if ($gradlewExists -or $gradlewBatExists) {
        # Determine which gradlew script to use
        $gradlewCmd = if ($gradlewBatExists) { ".\gradlew.bat" } else { ".\gradlew" }

        # Only process if last item is not an option
        if ($last_item -notlike '-*') {
            try {
                # Run gradlew tasks --all and capture output
                $taskOutput = & $gradlewCmd tasks --all 2>$null

                if ($taskOutput) {
                    $taskList = @()

                    foreach ($line in $taskOutput) {
                        # Match task lines: "taskName - description"
                        if ($line -match '^(\S+)\s+-\s+(.+)$') {
                            $taskName = $matches[1].Trim()
                            $taskDesc = $matches[2].Trim()

                            # Skip header lines
                            if ($taskName -and $taskName -notmatch '^Tasks?|^[-]+|^$') {
                                $taskList += [PSCustomObject]@{
                                    Name = $taskName
                                    Description = $taskDesc
                                }
                            }
                        }
                    }

                    # Add tasks to completions if not already present
                    foreach ($task in $taskList) {
                        $exists = $false
                        foreach ($comp in $completions) {
                            if ($comp.name -eq $task.Name) {
                                $exists = $true
                                break
                            }
                        }
                        if (-not $exists) {
                            $list += $PSCompletions.return_completion($task.Name, $task.Description)
                        }
                    }
                }
            }
            catch {
                # Silently fail - use static completions only
            }
        }
    }

    return $list + $completions
}
