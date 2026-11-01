local function add_names()
    for _, line in ipairs(psc.split(psc.read("/etc/crypttab") or "", "\n")) do
        local name = line:match("^%s*([^#%s]+)")
        if name then
            psc.add({ name = name })
        end
    end
end

psc.on({ multiple = true }, add_names)
