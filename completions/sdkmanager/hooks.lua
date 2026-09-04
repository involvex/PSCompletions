-- sdkmanager dynamic completions: installed SDK packages + category prefixes

local common_prefixes = {
    "build-tools;",
    "platforms;",
    "platform-tools",
    "ndk;",
    "cmake;",
    "emulator",
    "cmdline-tools;",
    "extras;",
    "system-images;",
}

local function get_installed_packages()
    local output = psc.run({ "sdkmanager", "--list_installed" }) or {}
    local packages = {}
    local in_table = false

    for _, line in ipairs(output) do
        if line:match("^%s*Path%s*|") then
            in_table = true
        elseif in_table and line:match("^%s*%-+%s*|") then
            -- separator line, skip
        elseif in_table then
            local pkg = line:match("^%s*(%S+)%s*|")
            if pkg and pkg ~= "" then
                table.insert(packages, pkg)
            end
        end
    end

    return packages
end

local function add_package_completions()
    -- Don't offer when typing an option
    if psc.typing and psc.typing.option_like then
        return
    end

    local installed = get_installed_packages()
    for _, pkg in ipairs(installed) do
        psc.add({ name = pkg, tip = "Installed SDK package: " .. pkg })
    end

    for _, prefix in ipairs(common_prefixes) do
        psc.add({ name = prefix, tip = "SDK package category prefix" })
    end
end

psc.on({}, add_package_completions)
