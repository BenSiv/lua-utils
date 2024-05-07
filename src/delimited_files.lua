require("utils").using("utils")

-- Define a module table
local delimited_files = {}

local function dlm_split(str, delimiter)
    local result = {}
    local token = ""
    local pos = 1

    while pos <= length(str) do
        local char = str:sub(pos, pos)
        if char == delimiter then
            table.insert(result, token)
            token = ""
        else
            token = token .. char
        end
        pos = pos + 1
    end

    if token ~= "" then
        table.insert(result, token)
    end

    return result
end

-- reads a delimited file into a table, assums correct format, loads all data as string
function delimited_files.readdlm(filename, delimiter, header)
    local file = io.open(filename, "r")
    if not file then
        print("Error opening file: " .. filename)
        return
    end

    local data = {}
    local cols = {}
    local line_count = 1

    for line in file:lines() do
        local fields = dlm_split(line, delimiter)

        if header and line_count == 1 then
            -- Use the first line as keys
            cols = copy(fields)
        else
            -- If not a header line or header is false, use numeric indices
            local entry = {}
            for i, value in ipairs(fields) do
                -- Check if the value can be converted to a number
                local num_value = tonumber(value)
                if num_value then
                    value = num_value
                end

                if header then
                    entry[cols[i]] = value
                else
                    table.insert(entry, value)
                end
            end
            table.insert(data, entry)
        end

        line_count = line_count + 1
    end

    file:close()
    return data
end

-- writes a delimited file from a table
function delimited_files.writedlm(filename, delimiter, data, header, append)
    local file

    if append then
        file = io.open(filename, "a")
    else
        file = io.open(filename, "w")
    end

    if not file then
        print("Error opening file for writing: " .. filename)
        return
    end

    -- Write header line if header is true
    if header then
        local header_line = table.concat(keys(data[keys(data)[1]]), delimiter)
        file:write(header_line .. "\n")
    end

    -- Write data lines
    for i, row in ipairs(data) do
        local line = table.concat(values(row), delimiter)
        file:write(line .. "\n")
    end

    file:close()
end

-- Export the module
return delimited_files
