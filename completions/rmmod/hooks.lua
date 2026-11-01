local function add_loaded()
    for _, line in ipairs(psc.run({ "lsmod" }) or {}) do
        local name = line:match("^(%S+)")
        if name and name ~= "Module" then
            psc.add({ name = name })
        end
    end
end

psc.on({ multiple = true }, add_loaded)
