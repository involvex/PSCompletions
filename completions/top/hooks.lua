local function add_pids()
    for _, line in ipairs(psc.run({ "ps", "-e", "-o", "pid=,comm=" }) or {}) do
        local pid, comm = line:match("^%s*(%d+)%s+(.*)$")
        if pid then
            psc.add({ name = pid, tip = comm ~= "" and comm or nil })
        end
    end
end

psc.on({ option = "--pid" }, add_pids)

local function add_users()
    for _, line in ipairs(psc.split(psc.read("/etc/passwd") or "", "\n")) do
        local name = line:match("^([^:]+):")
        if name then
            psc.add({ name = name })
        end
    end
end

psc.on({
    { option = "--filter-any-user" },
    { option = "--filter-only-euser" },
}, add_users)
