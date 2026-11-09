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

psc.on({
    { command = "pvchange" },
    { command = "pvck" },
    { command = "pvdisplay" },
    { command = "pvmove" },
    { command = "pvremove" },
    { command = "pvresize" },
    { command = "pvs" },
    { command = "vgimportclone" },
    { option = "--devices" },
}, add_pvs)

psc.on({
    { command = "lvcreate" },
    { command = "vgcfgbackup" },
    { command = "vgcfgrestore" },
    { command = "vgchange" },
    { command = "vgck" },
    { command = "vgconvert" },
    { command = "vgdisplay" },
    { command = "vgexport" },
    { command = "vgextend" },
    { command = "vgimport" },
    { command = "vgmerge" },
    { command = "vgmknodes" },
    { command = "vgreduce" },
    { command = "vgremove" },
    { command = "vgrename" },
    { command = "vgs" },
    { command = "vgsplit" },
}, add_vgs)

psc.on({
    { command = "lvchange" },
    { command = "lvconvert" },
    { command = "lvdisplay" },
    { command = "lvextend" },
    { command = "lvreduce" },
    { command = "lvremove" },
    { command = "lvrename" },
    { command = "lvresize" },
    { command = "lvs" },
}, add_vgs)

psc.on({
    { command = "lvchange" },
    { command = "lvconvert" },
    { command = "lvdisplay" },
    { command = "lvextend" },
    { command = "lvreduce" },
    { command = "lvremove" },
    { command = "lvrename" },
    { command = "lvresize" },
    { command = "lvs" },
}, add_lvs)

psc.on({ command = "help" }, function()
    psc.add(psc.mount_items({ "next" }))
end)
