-- gradlew dynamic completions: provides Gradle task names from `gradlew tasks --all`

local function add_tasks()
    -- Only offer tasks when not typing an option
    if psc.typing and psc.typing.option_like then
        return
    end

    -- Check if gradlew exists
    local gradlew_cmd
    if psc.exist(psc.path("gradlew.bat")) then
        gradlew_cmd = "gradlew.bat"
    elseif psc.exist(psc.path("gradlew")) then
        gradlew_cmd = "gradlew"
    else
        return
    end

    local output = psc.run({ gradlew_cmd, "tasks", "--all" }) or {}
    local seen = {}

    for _, line in ipairs(output) do
        -- Match task lines: "taskName - description"
        local task_name, task_desc = line:match("^(%S+)%s+-%s+(.+)$")
        if task_name then
            -- Skip header/separator lines
            if not task_name:match("^Tasks?") and not task_name:match("^%-") and task_name ~= "" then
                if not seen[task_name] then
                    seen[task_name] = true
                    psc.add({ name = task_name, tip = task_desc })
                end
            end
        end
    end
end

psc.on({}, add_tasks)
