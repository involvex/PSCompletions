local function add_keys()
    for _, line in ipairs(psc.run({ "sysctl", "-aN" }) or {}) do
        local name = line:match("^%s*(%S+)")
        if name then
            psc.add({ name = name })
        end
    end
end

psc.on({ multiple = true }, add_keys)
