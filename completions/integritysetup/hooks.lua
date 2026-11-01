local function add_mappings()
    for _, entry in ipairs(psc.ls("/dev/mapper") or {}) do
        if entry.name ~= "control" then
            psc.add({ name = entry.name })
        end
    end
end

psc.on({
    { command = "close" },
    { command = "status" },
    { command = "resize" },
}, add_mappings)
