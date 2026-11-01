local function add_mappings()
    for _, entry in ipairs(psc.ls("/dev/mapper") or {}) do
        if entry.name ~= "control" then
            psc.add({ name = entry.name })
        end
    end
end

psc.on({
    { command = "loopaesClose" },
    { command = "resize" },
    { command = "status" },
    { command = "refresh" },
    { command = "luksSuspend" },
    { command = "luksResume" },
    { option = "--active-name" },
}, add_mappings)
