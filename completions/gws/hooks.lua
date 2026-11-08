-- dynamic: schema path prefixes from cached API discovery files

local function add_schema_prefixes()
    local cfg = psc.env("GOOGLE_WORKSPACE_CLI_CONFIG_DIR")
    if not cfg or cfg == "" then
        local home = psc.env("HOME") or psc.env("USERPROFILE") or ""
        if home ~= "" then
            cfg = psc.path(home, ".config", "gws")
        end
    end
    if not cfg or cfg == "" then return end

    local cache = psc.path(cfg, "cache")
    local entries = psc.ls(cache) or {}
    local seen = {}
    for _, e in ipairs(entries) do
        local svc = e.name:match("^([%w_]+)_v%d+%.json$")
        if svc and not seen[svc] then
            seen[svc] = true
            local cli = svc:gsub("_", "-")
            psc.add({ name = cli .. ".", tip = "cached service schema" })
        end
    end
end

psc.on({ command = "schema" }, add_schema_prefixes)
