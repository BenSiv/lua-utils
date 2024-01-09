local split = require("utils").split

-- Define a module table
local delimited_files = {}

function delimited_files.readdlm(filename, delimiter, header)
    local file = io.open(filename, "r")
    if not file then
        print("Error opening file: " .. filename)
        return
    end

    local data = {}
    local line_count = 1

    for line in file:lines() do
        local fields = split(line, delimiter)

        if header and line_count == 1 then
            -- Use the first line as keys
            keys = fields
        else
            -- If not a header line or header is false, use numeric indices
            local entry = {}
            for i, value in ipairs(fields) do
                if header then
                    entry[keys[i]] = value
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

-- Export the module
return delimited_files
