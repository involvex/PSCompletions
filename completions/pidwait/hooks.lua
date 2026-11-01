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

local function add_groups()
    for _, line in ipairs(psc.split(psc.read("/etc/group") or "", "\n")) do
        local name = line:match("^([^:]+):")
        if name then
            psc.add({ name = name })
        end
    end
end

local function add_signals()
    for _, line in ipairs(psc.run({ "kill", "-l" }) or {}) do
        for sig in line:gmatch("SIG%u[%u%d+]*") do
            psc.add({ name = sig })
        end
    end
end

psc.on({
    { option = "--euid" },
    { option = "--uid" },
}, add_users)

psc.on({ option = "--group" }, add_groups)

psc.on({
    { option = "--parent" },
    { option = "--ns" },
}, add_pids)

psc.on({ option = "--signal" }, add_signals)
