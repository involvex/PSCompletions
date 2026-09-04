-- fresh dynamic completions

local function add_daemon_verbs()
    psc.add({ name = "list", tip = "List active daemons" })
    psc.add({ name = "attach", tip = "Attach to a daemon (NAME or the current directory)" })
    psc.add({ name = "new", tip = "Start a new named daemon" })
    psc.add({ name = "kill", tip = "Terminate a daemon" })
    psc.add({ name = "info", tip = "Show information about a daemon" })
    psc.add({ name = "open-file", tip = "Open files in a daemon (--wait blocks until done)" })
end

local function add_daemon_names()
    local output = psc.run({ "fresh", "--cmd", "daemon", "list" }) or {}
    for _, line in ipairs(output) do
        local name = line:match("^%s+([^%s:]+)%s*$")
        if name then
            psc.add({ name = name, tip = "daemon" })
        end
    end
end

-- --cmd daemon/session subcommands
psc.on({ command = { "", "daemon" } }, add_daemon_verbs)
psc.on({ command = { "", "session" } }, add_daemon_verbs)

-- --cmd attach/kill/open-file: daemon name completions
psc.on({ command = { "", "attach" } }, add_daemon_names)
psc.on({ command = { "", "kill" } }, add_daemon_names)
psc.on({ command = { "", "open-file" } }, add_daemon_names)

-- --cmd config subcommands
psc.on({ command = { "", "config" } }, function()
    psc.add({ name = "show", tip = "Print the effective configuration" })
    psc.add({ name = "paths", tip = "Show the directories used by Fresh" })
end)

-- --cmd grammar subcommands
psc.on({ command = { "", "grammar" } }, function()
    psc.add({ name = "list", tip = "List all available grammars (with source info)" })
end)

-- --cmd init subcommands
psc.on({ command = { "", "init" } }, function()
    psc.add({ name = "check", tip = "Syntax-check ~/.config/fresh/init.ts without running it" })
    psc.add({ name = "reload", tip = "Re-read and run init.ts in the running editor" })
end)

-- --cmd command subcommands
psc.on({ command = { "", "command" } }, function()
    psc.add({ name = "run", tip = "Run a registered command by its command-palette name" })
    psc.add({ name = "list", tip = "List registered commands (built-in + plugin)" })
end)

-- --cmd script subcommands
psc.on({ command = { "", "script" } }, function()
    psc.add({ name = "api", tip = "Search the API by name or description" })
    psc.add({ name = "check", tip = "Parse + check editor.* names, without running" })
    psc.add({ name = "run", tip = "Evaluate against this workspace (default: stdin)" })
    psc.add({ name = "types", tip = "Print paths of the API declaration files" })
end)

-- --cmd help subcommands
psc.on({ command = { "", "help" } }, function()
    psc.add({ name = "tour", tip = "Guided code tours (fresh and VS Code CodeTour formats)" })
    psc.add({ name = "script", tip = "Drive a running editor with TypeScript" })
    psc.add({ name = "plugin", tip = "Write init.ts / a plugin" })
end)

-- -a/--attach option: daemon name completions
psc.on({ option = "-a" }, add_daemon_names)
psc.on({ option = "--attach" }, add_daemon_names)
