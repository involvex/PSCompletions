local function add_pvs()
    for _, line in ipairs(psc.run({ "pvs", "--noheadings", "-o", "pv_name" }) or {}) do
        local name = line:match("^%s*(/%S+)%s*$")
        if name then
            psc.add({ name = name })
        end
    end
end

local function add_vgs()
    for _, line in ipairs(psc.run({ "vgs", "--noheadings", "-o", "vg_name" }) or {}) do
        local name = line:match("^%s*(%S+)%s*$")
        if name then
            psc.add({ name = name })
        end
    end
end

local function add_lvs()
    for _, line in ipairs(psc.run({ "lvs", "--noheadings", "-o", "vg_name,lv_name" }) or {}) do
        local vg, lv = line:match("^%s*(%S+)%s+(%S+)%s*$")
        if vg and lv then
            psc.add({ name = vg .. "/" .. lv })
        end
    end
end

psc.on({}, add_vgs)

psc.on({}, add_lvs)

psc.on({ option = "--devices" }, add_pvs)
