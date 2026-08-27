# wrangler completion hook
# Self-contained fallback completions for the wrangler CLI.
# No external processes are called.
#
# References:
#   https://developers.cloudflare.com/workers/wrangler/commands/general/index.md
#   https://developers.cloudflare.com/workers/wrangler/commands/workers/index.md
#   https://developers.cloudflare.com/workers/wrangler/commands/kv/index.md

function handleCompletions($completions) {
    $list = @()

    $input_arr = $PSCompletions.input_arr
    $filter_input_arr = $PSCompletions.filter_input_arr
    $word = $input_arr[-1]

    if ($word -like '-*') {
        return $list + $completions
    }

    $ci = [System.StringComparison]::CurrentCultureIgnoreCase

    $rootCommands = @(
        'docs', 'complete', 'email', 'auth', 'login', 'logout', 'whoami',
        'agent-memory', 'ai', 'ai-search', 'browser', 'containers', 'delete',
        'deploy', 'deployments', 'dev', 'dispatch-namespace', 'flagship', 'init',
        'pages', 'preview', 'queues', 'rollback', 'secret', 'setup', 'tail',
        'triggers', 'types', 'versions', 'vpc', 'websearch', 'workflows',
        'artifacts', 'd1', 'hyperdrive', 'kv', 'pipelines', 'r2',
        'secrets-store', 'vectorize', 'cert', 'mtls-certificate', 'tunnel', 'turnstile'
    )

    $subCommands = @{
        'auth'       = @('token', 'create', 'activate', 'deactivate', 'list', 'delete')
        'pages'      = @('dev', 'deploy', 'project', 'deployment')
        'kv'         = @('namespace', 'key', 'bulk')
        'r2'         = @('bucket', 'object')
        'd1'         = @('create', 'list', 'delete', 'execute', 'migrations', 'info', 'export')
        'secret'     = @('put', 'delete', 'list', 'bulk')
        'queues'     = @('create', 'delete', 'list', 'consumer')
        'ai'         = @('models', 'run')
        'versions'   = @('upload', 'deploy', 'list', 'view')
        'deployments' = @('list', 'status')
        'triggers'   = @('deploy')
        'telemetry'  = @('disable', 'enable', 'status')
    }

    $subSubCommands = @{
        'kv namespace'   = @('create', 'list', 'delete', 'rename')
        'kv key'         = @('put', 'list', 'get', 'delete')
        'kv bulk'        = @('get', 'put', 'delete')
        'r2 bucket'      = @('create', 'list', 'delete', 'upload', 'download')
        'r2 object'      = @('get', 'put', 'delete', 'list')
        'versions secret' = @('put', 'delete', 'bulk')
    }

    if ($filter_input_arr.Count -eq 0) {
        foreach ($cmd in $rootCommands) {
            if ($cmd.StartsWith($word, $ci)) {
                $list += $PSCompletions.return_completion($cmd, "")
            }
        }
        return $list + $completions
    }

    if ($filter_input_arr.Count -eq 1) {
        $main = $filter_input_arr[0]
        if ($subCommands.ContainsKey($main)) {
            foreach ($cmd in $subCommands[$main]) {
                if ($cmd.StartsWith($word, $ci)) {
                    $list += $PSCompletions.return_completion($cmd, "")
                }
            }
        }
        return $list + $completions
    }

    if ($filter_input_arr.Count -eq 2) {
        $main = $filter_input_arr[0]
        $sub = $filter_input_arr[1]
        $key = "$main $sub"
        if ($subSubCommands.ContainsKey($key)) {
            foreach ($cmd in $subSubCommands[$key]) {
                if ($cmd.StartsWith($word, $ci)) {
                    $list += $PSCompletions.return_completion($cmd, "")
                }
            }
        }
        return $list + $completions
    }

    return $list + $completions
}