require("utils").using("utils")

-- Define a module table
local dataframes = {}

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

function view(data_table)
    if not is_dataframe(data_table) then
        print("Not a valid dataframe.")
        return
    end

    local column_names = {}
    local max_col_width = {}

    for _, row in ipairs(data_table) do
        for col_name, col_value in pairs(row) do
            if column_names[col_name] == nil then
                column_names[col_name] = true
                max_col_width[col_name] = #tostring(col_name)
            end

            max_col_width[col_name] = math.max(max_col_width[col_name], #tostring(col_value))
        end
    end

    -- Calculate the number of '-' characters per column
    local num_dashes_per_column = 5

    -- Print column names
    for col_name, _ in pairs(column_names) do
        io.write(col_name .. string.rep(" ", max_col_width[col_name] - #col_name + num_dashes_per_column))
    end
    print("\n" .. string.rep("-", num_dashes_per_column * #column_names))

    -- Print data
    for i, row in ipairs(data_table) do
        for col_name, _ in pairs(column_names) do
            local value = row[col_name] or ""
            io.write(tostring(value) .. string.rep(" ", max_col_width[col_name] - #tostring(value) + num_dashes_per_column))
        end
        print()
    end
end

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