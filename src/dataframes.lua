require("utils").using("utils")

-- Define a module table
local dataframes = {}

-- dataframe definition:
-- 2 dimentional and rectangular table (same number of columns in each row)
-- first keys are rows of type integer
-- second keys are columns of type string

-- Validate if a table is a DataFrame
function is_dataframe(tbl)
    if type(tbl) ~= "table" then
        return false
    end

    if length(tbl) == 0 then
        return false
    end

    local num_columns = nil
    for index, row in pairs(tbl) do
        local valid_row_content = type(row) == "table"
        local valid_row_index = type(index) == "number"
        if not valid_row_content and not valid_row_index then
            return false
        end

        local current_num_columns = 0
        for col_name, col_value in pairs(row) do
            local valid_col_name = type(col_name) == "string"
            local valid_col_value = type(col_value) == "number" or type(col_value) == "string"
            if not valid_col_name and not valid_col_value then
                return false
            end
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

-- Converts all keys to a string type
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

-- Pretty print a dataframe
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

-- Transposes a dataframe
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

-- Function to group data by a specified key
function groupby(data, key)
    local groups = {}
    for _, entry in ipairs(data) do
        local group_key = entry[key]
        if not groups[group_key] then
            groups[group_key] = {}
        end
        table.insert(groups[group_key], entry)
    end
    return groups
end

-- Function to sum values in a table
function sum_values(data, key)
    local total = 0
    for _, entry in ipairs(data) do
        total = total + entry[key]
    end
    return total
end

-- Function to compute the mean of values in a table
function mean_values(data, key)
    local total = 0
    local count = 0
    for _, entry in ipairs(data) do
        total = total + entry[key]
        count = count + 1
    end
    if count > 0 then
        return total / count
    else
        return 0
    end
end

-- Function to sort a table by the values of a specific column
local function sort_by(tbl, col)
    local to_sort = {}
    for _, row in pairs(tbl) do
        local value = row[col]
        table.insert(to_sort, value)
    end

    local indices = get_sorted_indices(to_sort)
    local sorted_table = {}
    for _, row_index in pairs(indices) do
        table.insert(sorted_table, tbl[row_index])
    end
    return sorted_table
end

-- Function to sort a table based on input arguments
-- function sort(tbl, keys)
--     if type(keys) == "string" then
--         -- If keys is a string, perform single-key sort
--         sort_table_by_key(tbl, keys)
--     elseif type(keys) == "table" then
--         -- If keys is a table, perform multiple-key sort
--         sort_table_by_multiple_keys(tbl, keys)
--     else
--         print("Invalid keys argument")
--     end
-- end

dataframes.is_dataframe = is_dataframe
dataframes.view = view
dataframes.transpose = transpose
dataframes.groupby = groupby
dataframes.sum_values = sum_values
dataframes.mean_values = mean_values
dataframes.sort_by = sort_by

-- Export the module
return dataframes