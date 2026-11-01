local function add_pvs()
    for _, line in ipairs(psc.run({ "pvs", "--noheadings", "-o", "pv_name" }) or {}) do
        local name = line:match("^%s*(/%S+)%s*$")
        if name then
            psc.add({ name = name })
        end
    end
end

psc.on({ option = "--devices" }, add_pvs)
