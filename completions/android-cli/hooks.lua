-- Routing table: command chain → completions to offer at that context.
-- Options use `-` prefix; subcommands do not. `args = true` adds a literal "list".
local routes = {
    ["create"] = { options = { "--dry-run", "--verbose", "--name=", "--output=" }, args = { "list" } },
    ["create list"] = {},
    ["describe"] = { options = { "--project_dir=" } },
    ["docs"] = { subcommands = { "search", "fetch" } },
    ["emulator"] = { subcommands = { "create", "list", "start", "stop" } },
    ["emulator create"] = { options = { "--list-profiles", "--profile=" } },
    ["emulator list"] = {},
    ["emulator start"] = {},
    ["emulator stop"] = {},
    ["info"] = {},
    ["init"] = {},
    ["layout"] = { options = { "--pretty", "--output=", "--diff" } },
    ["skills"] = { subcommands = { "add", "find", "list", "remove" } },
    ["skills add"] = { options = { "--all", "--agent=", "--skill=" } },
    ["skills find"] = {},
    ["skills list"] = { options = { "--long" } },
    ["skills remove"] = { options = { "--agent=", "--skill=" } },
    ["screen"] = { subcommands = { "capture", "resolve" } },
    ["screen capture"] = { options = { "--output=", "--annotate" } },
    ["screen resolve"] = { options = { "--screenshot=", "--string=" } },
    ["sdk"] = { subcommands = { "install", "list", "remove", "update" } },
    ["sdk install"] = { options = { "--beta", "--canary", "--force" } },
    ["sdk list"] = { options = { "--all", "--all-versions", "--beta", "--canary" } },
    ["sdk remove"] = {},
    ["sdk update"] = { options = { "--beta", "--canary", "--force" } },
    ["run"] = { options = { "--debug", "--activity=", "--device=", "--type=", "--apks=" } },
    ["update"] = {},
}

local global_options = { "-h", "--help", "--sdk=" }

local top_commands = {
    "create", "describe", "docs", "emulator", "info", "init",
    "layout", "skills", "screen", "sdk", "run", "update",
}

local function is_option(name)
    return name:sub(1, 1) == "-"
end

-- Escape Lua pattern special characters for literal prefix matching.
local function escape_pattern(s)
    return s:gsub("([%(%)%.%%%+%-%*%?%[%]%^%$])", "%%%1")
end

local function add_items(items, word)
    if word == "" then
        for _, item in ipairs(items) do
            psc.add({ name = item })
        end
        return
    end
    local pat = "^" .. escape_pattern(word)
    for _, item in ipairs(items) do
        if psc.contains(item, pat, { pattern = true }) then
            psc.add({ name = item })
        end
    end
end

psc.on({}, function()
    local word = psc.typing.input or ""

    -- Build the command chain from completed tokens.
    local chain_parts = {}
    for _, tok in ipairs(psc.tokens) do
        if not is_option(tok.name) then
            chain_parts[#chain_parts + 1] = tok.name
        end
    end

    -- Root level: offer top-level subcommands and global options.
    if #chain_parts == 0 then
        add_items(top_commands, word)
        add_items(global_options, word)
        return
    end

    -- Look up the current chain in the routing table.
    local chain = table.concat(chain_parts, " ")
    local route = routes[chain]
    if route then
        if route.subcommands then
            add_items(route.subcommands, word)
        end
        if route.options then
            add_items(route.options, word)
        end
        if route.args then
            add_items(route.args, word)
        end
        return
    end

    -- Chain longer than any known route — offer global options at least.
    add_items(global_options, word)
end)
