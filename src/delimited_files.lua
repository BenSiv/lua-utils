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

-- Reads a delimited file into a table, assumes correct format, loads all data as string
local function readdlm(filename, delimiter, header)
    local file = io.open(filename, "r")
    if not file then
        print("Error opening file: " .. filename)
        return
    end

    local data = {}
    local cols = {}
    local line_count = 1
    local num_cols = 0

    for line in file:lines() do
        -- Remove trailing '\r' character from line end
        line = string.gsub(line, "\r$", "")

        local fields = dlm_split(line, delimiter)

        if header and line_count == 1 then
            -- Use the first line as keys
            cols = copy(fields)
            num_cols = length(cols)

        else
            -- Create a new table for each row
            local entry = {}

            if header then
                -- Initialize all keys with empty strings
                for _, col in ipairs(cols) do
                    entry[col] = ""
                end

                -- Populate values
                for i, value in ipairs(fields) do
                    local num_value = tonumber(value)
                    entry[cols[i]] = num_value or value or ""
                end
            else
                -- For rows without a header, fill missing values with empty strings
                for i = 1, num_cols do
                    local value = fields[i] or ""
                    local num_value = tonumber(value)
                    table.insert(entry, num_value or value)
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
local function writedlm(filename, delimiter, data, header, append)
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

delimited_files.dlm_split = dlm_split
delimited_files.readdlm = readdlm
delimited_files.writedlm = writedlm

-- Export the module
return delimited_files
