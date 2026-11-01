local function add_commands()
    local seen = {}
    for _, line in ipairs(psc.run({ "ps", "-e", "-o", "comm=" }) or {}) do
        local name = line:match("^%s*(%S+)")
        if name and not seen[name] then
            seen[name] = true
            psc.add({ name = name })
        end
    end
end

psc.on({}, add_commands)
