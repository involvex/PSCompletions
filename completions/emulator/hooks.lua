local function load_help_options()
    local options = {}
    local current_opt = nil
    local current_desc = {}

    for _, line in ipairs(psc.run({ "emulator", "--help" }) or {}) do
        -- Match option lines: two leading spaces, flag, optional value, two+ spaces, description
        local opt, desc = line:match("^  (%-%-?[%w%-]+).-%s%s+(.+)$")
        if opt then
            if current_opt then
                options[current_opt] = table.concat(current_desc, " ")
            end
            current_opt = opt
            current_desc = { psc.trim(desc) }
        else
            -- Continuation lines: exactly four leading spaces
            local cont = line:match("^    (.+)$")
            if cont and current_opt then
                current_desc[#current_desc + 1] = psc.trim(cont)
            else
                if current_opt then
                    options[current_opt] = table.concat(current_desc, " ")
                end
                current_opt = nil
                current_desc = {}
            end
        end
    end
    if current_opt then
        options[current_opt] = table.concat(current_desc, " ")
    end

    return options
end

local function add_options()
    local typing = psc.typing
    if not typing or typing.input:sub(1, 1) ~= "-" then return end

    local prefix = typing.input
    local options = load_help_options()
    local seen = {}
    for opt, desc in pairs(options) do
        if opt:sub(1, #prefix) == prefix then
            local short = opt:gsub("^%-%-", "-")
            if not seen[short] then
                seen[short] = true
                psc.add({ name = short, tip = desc, repeat_count = 99 })
            end
        end
    end
end

psc.on({}, add_options)
