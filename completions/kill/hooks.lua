local function add_pids()
    for _, line in ipairs(psc.run({ "ps", "-e", "-o", "pid=,comm=" }) or {}) do
        local pid, comm = line:match("^%s*(%d+)%s+(.*)$")
        if pid then
            psc.add({ name = pid, tip = comm ~= "" and comm or nil })
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

psc.on({ multiple = true }, add_pids)

psc.on({ option = "--signal" }, add_signals)
