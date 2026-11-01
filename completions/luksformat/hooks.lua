local function add_fstypes()
    local seen = {}
    for _, dir in ipairs({ "/usr/sbin", "/usr/bin", "/sbin", "/bin" }) do
        for _, entry in ipairs(psc.ls(dir) or {}) do
            local fs = entry.name:match("^mkfs%.(.+)$")
            if fs and not seen[fs] then
                seen[fs] = true
                psc.add({ name = fs })
            end
        end
    end
end

psc.on({ option = "--type" }, add_fstypes)
