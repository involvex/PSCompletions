-- avdmanager dynamic completions

local function add_name_options()
    local output = psc.run({ "avdmanager", "list", "avd", "-c" }) or {}
    for _, line in ipairs(output) do
        local name = psc.trim(line)
        if name ~= "" then
            psc.add({ name = name, tip = "Android Virtual Device: " .. name })
        end
    end
end

local function add_device_options()
    local output = psc.run({ "avdmanager", "list", "device", "-c" }) or {}
    for _, line in ipairs(output) do
        local name = psc.trim(line)
        if name ~= "" then
            psc.add({ name = name, tip = "Device definition: " .. name })
        end
    end
end

local function add_package_options()
    local output = psc.run({ "avdmanager", "list", "target", "-c" }) or {}
    for _, line in ipairs(output) do
        local name = psc.trim(line)
        if name ~= "" then
            psc.add({ name = name, tip = "System image target: " .. name })
        end
    end
end

local function add_tag_options()
    psc.add({ name = "default", tip = "Default system image tag" })
    psc.add({ name = "google_apis", tip = "Google APIs system image tag" })
    psc.add({ name = "google_apis_playstore", tip = "Google APIs with Play Store tag" })
end

-- create/move/delete avd: option value completions
-- The action is a verb and a direct object, so the chain has two segments; psc.on matches each segment against the canonical name.
-- The option target is the canonical name too: typing `-n` still yields the canonical `--name`.
psc.on({ command = { "create", "avd" }, option = "--name" }, add_name_options)
psc.on({ command = { "create", "avd" }, option = "--device" }, add_device_options)
psc.on({ command = { "create", "avd" }, option = "--package" }, add_package_options)
psc.on({ command = { "create", "avd" }, option = "--tag" }, add_tag_options)

psc.on({ command = { "move", "avd" }, option = "--name" }, add_name_options)

psc.on({ command = { "delete", "avd" }, option = "--name" }, add_name_options)
