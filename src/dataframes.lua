require("utils").using("utils")

-- Define a module table
local dataframes = {}

-- checks if a table has rectagular shape 
function is_dataframe(data_table)
    if type(data_table) ~= "table" then
        return false
    end

    local num_columns = nil

    for _, row in ipairs(data_table) do
        if type(row) ~= "table" then
            return false
        end

        local current_num_columns = #row

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

    data_table = string_keys(data_table)

    local column_names = {}
    local max_col_width = {}

    for _, row in ipairs(data_table) do
        for col_name, col_value in pairs(row) do
            if column_names[col_name] == nil then
                column_names[col_name] = true
                max_col_width[col_name] = length(col_name)
            end

            local col_value_length = length(tostring(col_value)) 
            max_col_width[col_name] = math.max(max_col_width[col_name], col_value_length)
        end
    end

    -- Calculate the number of '-' characters per column
    local num_dashes_per_column = 5

    -- Print column names
    for col_name, _ in pairs(column_names) do
        io.write(col_name .. string.rep(" ", max_col_width[col_name] - length(col_name) + num_dashes_per_column))
    end
    print("\n" .. string.rep("-", num_dashes_per_column * length(column_names)))

    -- Print data
    for i, row in ipairs(data_table) do
        for col_name, _ in pairs(column_names) do
            local value = row[col_name] or ""
            io.write(tostring(value) .. string.rep(" ", max_col_width[col_name] - length(value) + num_dashes_per_column))
        end
        print()
    end
end

-- transposes a dataframe
function transpose(data_table)
    if not is_dataframe(data_table) then
        print("Not a valid dataframe.")
        return
    end

    local transposed_table = {}

    -- Get the number of rows and columns in the original table
    local num_rows = length(data_table)
    local num_columns = length(data_table[1])

    -- Transpose the table
    for col_index, col_data in pairs(data_table[1]) do
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