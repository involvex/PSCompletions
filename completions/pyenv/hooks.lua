-- pyenv dynamic completions

local shell_names = { "bash", "zsh", "fish", "powershell", "pwsh" }

local python_commands = {
    "python", "python3", "pip", "pip3",
    "ipython", "jupyter", "pytest", "black", "flake8", "mypy",
}

local function get_installed_versions()
    return psc.run({ "pyenv", "versions", "--bare" }) or {}
end

local function get_available_versions()
    return psc.run({ "pyenv", "install", "--list" }) or {}
end

local function get_pyenv_commands()
    return psc.run({ "pyenv", "commands" }) or {}
end

local function add_installed_versions()
    for _, v in ipairs(get_installed_versions()) do
        local name = psc.trim(v)
        if name ~= "" then
            psc.add({ name = name, tip = "Installed version: " .. name })
        end
    end
end

local function add_available_versions()
    for _, v in ipairs(get_available_versions()) do
        local name = psc.trim(v)
        if name ~= "" then
            psc.add({ name = name, tip = "Available version: " .. name })
        end
    end
end

local function add_version_prefixes()
    local seen = {}
    for _, v in ipairs(get_available_versions()) do
        local prefix = v:match("^(%d+%.%d+)")
        if prefix and not seen[prefix] then
            seen[prefix] = true
            psc.add({ name = prefix, tip = "Version prefix: " .. prefix })
        end
    end
end

local function add_pyenv_commands()
    for _, cmd in ipairs(get_pyenv_commands()) do
        local name = psc.trim(cmd)
        if name ~= "" then
            psc.add({ name = name, tip = "Command: " .. name })
        end
    end
end

local function add_shell_names()
    for _, shell in ipairs(shell_names) do
        psc.add({ name = shell, tip = "Shell: " .. shell })
    end
end

local function add_python_commands()
    for _, cmd in ipairs(python_commands) do
        psc.add({ name = cmd, tip = "Python command: " .. cmd })
    end
end

-- Version-dependent subcommands
psc.on({ command = "local", multiple = true }, add_installed_versions)
psc.on({ command = "global", multiple = true }, add_installed_versions)
psc.on({ command = "shell", multiple = true }, add_installed_versions)
psc.on({ command = "uninstall", multiple = true }, add_installed_versions)
psc.on({ command = "prefix", multiple = true }, add_installed_versions)

-- install: available versions (don't offer if --list/--list-all already typed)
psc.on({ command = "install" }, function()
    if not psc.token({ name = "--list" }) and not psc.token({ name = "--list-all" }) then
        add_available_versions()
    end
end)

-- latest: version prefixes
psc.on({ command = "latest" }, add_version_prefixes)

-- hooks/help: pyenv commands
psc.on({ command = "hooks" }, add_pyenv_commands)
psc.on({ command = "help" }, add_pyenv_commands)

-- init/completions: shell names
psc.on({ command = "init" }, add_shell_names)
psc.on({ command = "completions" }, add_shell_names)

-- which/whence/exec: common python commands
psc.on({ command = "which" }, add_python_commands)
psc.on({ command = "whence" }, add_python_commands)
psc.on({ command = "exec" }, add_python_commands)
