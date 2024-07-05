-- Define a module table
local user = {}

function input(prompt)
    io.write(prompt)
    local answer = io.read()
    return answer
end

function inputs(prompt)
    io.write(prompt)
    local full_answer = ""
    local answer = ""
    while true do
        answer = io.read()
        if answer == "" then
            break
        end
        full_answer = full_answer .. "\n" .. answer
    end
    return full_answer
end

user.input = input
user.inputs = inputs

-- Export the module
return user