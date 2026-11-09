local function add_interfaces()
    for _, entry in ipairs(psc.ls("/sys/class/net") or {}) do
        psc.add({ name = entry.name })
    end
end

psc.on({ option = "dev" }, add_interfaces)
