local function add_pids()
    for _, line in ipairs(psc.run({ "ps", "-e", "-o", "pid=,comm=" }) or {}) do
        local pid, comm = line:match("^%s*(%d+)%s+(.*)$")
        if pid then
            psc.add({ name = pid, tip = comm ~= "" and comm or nil })
        end
    end
end

psc.on({ multiple = true }, add_pids)
