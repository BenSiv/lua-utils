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

-- Transposes a dataframe
function transpose(data_table)
    -- if not is_dataframe(data_table) then
    --     print("Not a valid dataframe.")
    --     return
    -- end

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

-- Pretty print a dataframe
function view(data_table)
    if isempty(data_table) then
        print("Empty table")
        return
    elseif not is_dataframe(data_table) then
        print("Not a valid dataframe")
        return
    end

    -- Get terminal line length
    local line_length = get_line_length()

    -- Calculate column widths
    local column_widths = {}
    for _, row in pairs(data_table) do
        for col_name, col_value in pairs(row) do
            local col_width = length(tostring(col_name))
            local val_width = length(tostring(col_value))
            column_widths[col_name] = math.max(column_widths[col_name] or 0, col_width, val_width)
        end
    end

    -- Adjust column widths to fit within terminal line length
    local total_width = 0
    for _, width in pairs(column_widths) do
        total_width = total_width + width + 1 -- Add 1 for spacing
    end

    -- Constrain total width to line length
    if total_width > line_length then
        local available_width = line_length - length(column_widths) -- Subtract space for separators
        local width_per_column = math.floor(available_width / length(column_widths))
        for col_name, _ in pairs(column_widths) do
            column_widths[col_name] = math.min(column_widths[col_name], width_per_column)
        end
    end

    -- Print column headers in bold
    for key, col_width in pairs(column_widths) do
        io.write("\27[1m")
        local padded_key = tostring(key)
        padded_key = padded_key .. string.rep(" ", col_width - length(padded_key))
        io.write(padded_key .. "\27[0m\t")
    end
    io.write("\n")

    -- Print rows
    for _, row in pairs(data_table) do
        for col_name, col_width in pairs(column_widths) do
            local value = tostring(row[col_name] or "")
            value = value .. string.rep(" ", col_width - length(value))
            io.write(value .. "\t")
        end
        io.write("\n")
    end
end

function array_to_df(array)
    local df = {}
    for idx, val in pairs(array) do
        table.insert(df, {index = idx, value = val})
    end
    return df
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

-- Function to select specific columns
local function select(tbl, cols)
    local result = {}
    for _, row in pairs(tbl) do
        local selected = {}
        for _, col in pairs(cols) do
            local value = row[col]
            selected[col] = value
        end
        table.insert(result, selected)
    end
    return result
end

-- Function to select specific columns
local function diff(tbl, col)
    local result = {}
    local last_value = 0
    local value = 0
    for index, row in pairs(tbl) do
        if index == 1 then 
            -- do not update values
        else
            value = row[col] - last_value
        end
        last_value = row[col]
        table.insert(result, value)
    end
    return result
end

dataframes.is_dataframe = is_dataframe
dataframes.view = view
dataframes.transpose = transpose
dataframes.groupby = groupby
dataframes.sum_values = sum_values
dataframes.mean_values = mean_values
dataframes.sort_by = sort_by
dataframes.select = select
dataframes.diff = diff

-- Export the module
return dataframes