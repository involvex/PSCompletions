local function add_commands()
    local seen = {}
    for _, line in ipairs(psc.run({ "ps", "-e", "-o", "comm=" }) or {}) do
        local name = line:match("^%s*(%S+)")
        if name and not seen[name] then
            seen[name] = true
            psc.add({ name = name })
        end
    end
end

local function add_users()
    for _, line in ipairs(psc.split(psc.read("/etc/passwd") or "", "\n")) do
        local name = line:match("^([^:]+):")
        if name then
            psc.add({ name = name })
        end
    end
end

psc.on({ multiple = true }, add_commands)

psc.on({ option = "--user" }, add_users)
