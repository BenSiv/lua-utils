-- Define a module table
local user = {}

local function input(prompt)
    if not prompt then
        print("Prompt the user for responce!")
        return
    end
    io.write(prompt)
    local answer = io.read()
    -- answer = escape_string(answer)
    return answer
end

local function inputs(prompt)
    if not prompt then
        print("Prompt the user for responce!")
        return
    end
    io.write(prompt)
    local full_answer = {}
    local answer = ""
    while true do
        answer = io.read()
        -- answer = escape_string(answer)
        if answer == "" then
            break
        end
        table.insert(full_answer, answer)
    end
    return full_answer
end

user.input = input
user.inputs = inputs

-- Export the module
return user
