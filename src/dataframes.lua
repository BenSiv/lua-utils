require("utils").using("utils")

-- Define a module table
local dataframes = {}

-- validate if a table is a DataFrame
function is_dataframe(tbl)
    if type(tbl) ~= "table" then
        return false
    end

    if length(tbl) == 0 then
        return false
    end

    local num_columns = nil
    for _, row in ipairs(tbl) do
        if type(row) ~= "table" then
            return false
        end

        local current_num_columns = 0
        for _, _ in pairs(row) do
            current_num_columns = current_num_columns + 1
        end

        if num_columns == nil then
            num_columns = current_num_columns
        elseif num_columns ~= current_num_columns then
            return false
        end
    end

    return true
end

function string_keys(obj)
    if type(obj) ~= "table" then
        return obj
    end

    local new_table = {}
    for key, value in pairs(obj) do
        if type(key) ~= "string" then
            key = tostring(key)
        end

        if type(value) == "table" then
            value = string_keys(value)
        end

        new_table[key] = value
    end

    return new_table
end

-- pretty print a dataframe
function view(data_table)
    if not is_dataframe(data_table) then
        print("Not a valid dataframe.")
        return
    end

    -- Find the maximum width of each column
    local column_widths = {}
    for _, row in ipairs(data_table) do
        for key, value in pairs(row) do
            local width = length(tostring(value))
            if not column_widths[key] or width > column_widths[key] then
                column_widths[key] = width
            end
        end
    end

    -- Print the header
    for key, col_width in pairs(column_widths) do
        io.write("\27[1m" .. string.format("%-" .. col_width .. "s", key) .. "\27[0m\t")
    end
    io.write("\n")

    -- Print the data
    for _, row in ipairs(data_table) do
        for key, col_width in pairs(column_widths) do
            local value = tostring(row[key]) or ""
            io.write(string.format("%-" .. col_width .. "s", value) .. "\t")
        end
        io.write("\n")
    end
end

-- transposes a dataframe
function transpose(data_table)
    if not is_dataframe(data_table) then
        print("Not a valid dataframe.")
        return
    end

    local transposed_table = {}

    -- Transpose the table
    for col_index, col_data in pairs(data_table[keys(data_table)[1]]) do
        transposed_table[col_index] = {}
        for row_index, row_data in pairs(data_table) do
            transposed_table[col_index][row_index] = row_data[col_index]
        end
    end

    return transposed_table
end

dataframes.is_dataframe = is_dataframe
dataframes.view = view
dataframes.transpose = transpose

-- Export the module
return dataframes