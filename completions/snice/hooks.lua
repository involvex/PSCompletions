local function add_pids()
    for _, line in ipairs(psc.run({ "ps", "-e", "-o", "pid=,comm=" }) or {}) do
        local pid, comm = line:match("^%s*(%d+)%s+(.*)$")
        if pid then
            psc.add({ name = pid, tip = comm ~= "" and comm or nil })
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

psc.on({
    { option = "--pid" },
    { option = "--ns" },
}, add_pids)

psc.on({ option = "--user" }, add_users)

psc.on({ option = "--command" }, add_commands)
