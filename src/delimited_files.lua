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

-- Reads a delimited file into a table, assums correct format, loads all data as string
local function readdlm(filename, delimiter, header)
    local file = io.open(filename, "r")
    if not file then
        print("Error opening file: " .. filename)
        return
    end

    local data = {}
    local cols = {}
    local line_count = 1

    for line in file:lines() do
        -- Remove trailing '\r' character from line end
        line = string.gsub(line, "\r$", "")

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

-- local function readdlm(filename, delimiter, header)
--     local file = io.open(filename, "r")
--     if not file then
--         print("Error opening file: " .. filename)
--         return
--     end

--     local data = {}
--     local cols = {}
--     local line_count = 1

--     for line in file:lines() do
--         -- Remove trailing '\r' character from line end
--         line = replace_string(line, "\r$", "")

--         local fields = dlm_split(line, delimiter)
--         local entry = {}

--         if header then
--             if line_count == 1 then
--                 cols = copy(fields)
--             else
--                 for i, col in ipairs(cols) do
--                     local value = fields[i]
--                     local num_value = tonumber(value)
--                     entry[col] = num_value or value
--                 end
--             end
--         else
--             for _, value in ipairs(fields) do
--                 num_value = tonumber(value)
--                 table.insert(entry, num_value or value)
--             end
--         end

--         table.insert(data, entry)
--         line_count = line_count + 1
--     end

--     file:close()
--     return data
-- end


-- Writes a delimited file from a table
local function writedlm(filename, delimiter, data, header, append, column_order)
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

    -- Determine the column order (use the first row's keys if not provided)
    if not column_order then
        -- Get the keys from the first row to determine the column order
        column_order = keys(data[1])
    end

    -- Write header line if header is true
    if header then
        local header_line = table.concat(column_order, delimiter)
        file:write(header_line .. "\n")
    end

    -- Write data lines
    for i, row in ipairs(data) do
        local line_parts = {}
        -- Ensure the values are written in the same order as column_order
        for _, col in ipairs(column_order) do
            table.insert(line_parts, row[col])
        end
        local line = table.concat(line_parts, delimiter)
        file:write(line .. "\n")
    end

    file:close()
end

delimited_files.dlm_split = dlm_split
delimited_files.readdlm = readdlm
delimited_files.writedlm = writedlm

-- Export the module
return delimited_files
