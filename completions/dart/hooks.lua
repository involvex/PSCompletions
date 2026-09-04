local function add_run_files()
    if psc.typing.option_like or psc.eq(psc.typing.input, "run") then
        return
    end
    for _, path in ipairs(psc.glob("**/*.dart") or {}) do
        if psc.contains(path, "^(bin/|lib/|test/)", { pattern = true }) then
            psc.add({ name = path, tip = path })
        end
    end
end

local function add_test_files()
    if psc.typing.option_like or psc.eq(psc.typing.input, "test") then
        return
    end
    for _, path in ipairs(psc.glob("**/*test*.dart") or {}) do
        psc.add({ name = path, tip = path })
    end
end

psc.on({ command = "run" }, add_run_files)
psc.on({ command = "test" }, add_test_files)
