local function add_modules()
    local release = (psc.read("/proc/sys/kernel/osrelease") or ""):gsub("%s+$", "")
    if release == "" then
        return
    end
    local data = psc.read("/lib/modules/" .. release .. "/modules.dep") or ""
    for _, line in ipairs(psc.split(data, "\n")) do
        local path = line:match("^([^:]+):")
        if path then
            local name = path:match("([^/]+)%.ko[^/]*$")
            if name then
                psc.add({ name = name })
            end
        end
    end
end

psc.on({ multiple = true }, add_modules)
