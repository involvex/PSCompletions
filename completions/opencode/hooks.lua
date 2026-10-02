local function add_models()
    psc.add(psc.items(psc.run({ "opencode", "models" }, { timeout = 8000 }) or {}))
end

local function add_agents()
    local agents = psc.run({ "opencode", "debug", "agents" }, { format = "json", timeout = 8000 })
    if not agents then
        return
    end
    for _, agent in ipairs(agents) do
        if agent.id and not agent.hidden then
            psc.add({ name = agent.id, tip = agent.description or agent.name or "" })
        end
    end
end

local function add_sessions()
    local sessions = psc.run({ "opencode", "session", "list", "--format", "json", "-n", "50" },
        { format = "json", timeout = 8000 })
    if not sessions then
        return
    end
    for _, session in ipairs(sessions) do
        if session.id then
            psc.add({ name = session.id, tip = session.title or "" })
        end
    end
end

local function add_integrations()
    local integrations = psc.run({ "opencode", "auth", "list", "--format", "json" },
        { format = "json", timeout = 8000 })
    if not integrations then
        return
    end
    local seen = {}
    for _, integration in ipairs(integrations) do
        if integration.name and not seen[integration.name] then
            seen[integration.name] = true
            psc.add({ name = integration.name, tip = integration.id or "integration" })
        end
    end
end

local function add_mcp_servers()
    -- rows are "<glyph> <name> <padding> <status>"; multi-line diagnostics fail the
    -- two-space gap that separates name from status, so only real rows match
    for _, line in ipairs(psc.run({ "opencode", "mcp", "list" }, { timeout = 8000 }) or {}) do
        local _, name, status = line:match("^(%S+)%s+(%S+)%s%s(.*)$")
        if name then
            psc.add({ name = name, tip = psc.trim(status) })
        end
    end
end

local function add_plugin_targets()
    -- last column is the configured package specifier; skip the header row
    for _, line in ipairs(psc.run({ "opencode", "plugin", "list" }, { timeout = 8000 }) or {}) do
        local source = not line:match("^ID%s") and line:match("^%S+%s+%S+%s+(%S+)%s*$")
        if source then
            psc.add({ name = source })
        end
    end
end

psc.on({
    { command = { "session", "delete" } },
    { command = { "session", "export" } },
    { option = "--session" }
}, add_sessions)

psc.on({
    { command = { "auth", "export" } },
    { command = { "auth", "login" } },
    { command = { "auth", "logout" } },
    { command = { "auth", "switch" } }
}, add_integrations)

psc.on({
    { command = { "mcp", "auth" } },
    { command = { "mcp", "logout" } }
}, add_mcp_servers)

psc.on({
    { command = { "plugin", "check" } },
    { command = { "plugin", "remove" } },
    { command = { "plugin", "update" } }
}, add_plugin_targets)

psc.on({ option = "--agent" }, add_agents)

psc.on({ option = "--model" }, add_models)