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
function view(data_table, limit)
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
    if limit then
        for num, row in pairs(data_table) do
            if num >= limit then
                break
            end
            for col_name, col_width in pairs(column_widths) do
                local value = tostring(row[col_name] or "")
                value = value .. string.rep(" ", col_width - length(value))
                io.write(value .. "\t")
            end
            io.write("\n")
        end
    else
        for _, row in pairs(data_table) do
            for col_name, col_width in pairs(column_widths) do
                local value = tostring(row[col_name] or "")
                value = value .. string.rep(" ", col_width - length(value))
                io.write(value .. "\t")
            end
            io.write("\n")
        end
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

-- Function to filter by column value
local function filter_by_value(tbl, column, condition)
    local fcon = loadstring("return function(x) return " .. condition .. " end")()
    local result = {}
    for row, values in pairs(tbl) do
        local x = values[column]
        if x and fcon(x) then
            table.insert(result, values)
        end
    end
    return result
end

-- Function to filter rows based on a condition involving one or two columns
local function filter_by_columns(tbl, col1, op, col2)
    local result = {}
    for _, values in pairs(tbl) do
        local v1, v2 = values[col1], values[col2]
        if v1 and v2 then
            local condition = loadstring(string.format("return %s %s %s", v1 ,op ,v2))
            if condition() then
                table.insert(result, values)
            end
        end
    end
    return result
end

function filter_unique(tbl, column)
    local count = {}
    
    -- Count occurrences of each value in the specified column
    for _, row in pairs(tbl) do
        local val = row[column]
        if val then
            count[val] = (count[val] or 0) + 1
        end
    end
    
    -- Collect rows where the column value appears only once
    local filtered = {}
    local index = 1
    for _, row in pairs(tbl) do
        if count[row[column]] == 1 then
            filtered[index] = row
            index = index + 1
        end
    end
    
    return filtered
end

-- Function to generate new column based on a transformation of pair columns
local function generate_column(tbl, new_col, col1, op, col2)
    new_tbl = copy(tbl)
    for row, values in pairs(new_tbl) do
        local v1, v2 = values[col1], values[col2]
        if v1 and v2 then
            local condition = loadstring(string.format("return %s %s %s", v1 ,op ,v2))
            local result = condition()
            if result then
                new_tbl[row][new_col] = result
            end
        end
    end
    return new_tbl
end

-- Function to generate new column based on a transformation of pair columns
local function transform(tbl, new_col, col1, col2, transform_fn)
    local new_tbl = copy(tbl)
    for row, values in pairs(new_tbl) do
        local v1, v2 = values[col1], values[col2]
        if v1 and v2 then
            local result = transform_fn(v1, v2)
            if result then
                new_tbl[row][new_col] = result
            end
        end
    end
    return new_tbl
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

local function innerjoin(df1, df2, columns, prefixes)
    prefixes = prefixes or {"df1", "df2"}
    local joined_df = {}

    -- Convert join columns to a set for quick lookup
    local join_columns = {}
    for _, col in ipairs(columns) do
        join_columns[col] = true
    end

    -- Identify overlapping non-join columns
    local df1_columns, df2_columns = {}, {}
    for _, row in ipairs(df1) do
        for col in pairs(row) do
            if not join_columns[col] then
                df1_columns[col] = true
            end
        end
    end
    for _, row in ipairs(df2) do
        for col in pairs(row) do
            if not join_columns[col] then
                df2_columns[col] = true
            end
        end
    end

    local shared_columns = {}
    for col in pairs(df1_columns) do
        if df2_columns[col] then
            shared_columns[col] = true
        end
    end

    -- Helper to check if rows match on all join columns
    local function rows_match(row1, row2)
        for _, col in ipairs(columns) do
            if row1[col] ~= row2[col] then
                return false
            end
        end
        return true
    end

    -- Perform the join
    for _, row1 in ipairs(df1) do
        for _, row2 in ipairs(df2) do
            if rows_match(row1, row2) then
                local joined_row = {}

                -- Add join columns once
                for _, col in ipairs(columns) do
                    joined_row[col] = row1[col]
                end

                -- Add non-join columns from df1
                for col, val in pairs(row1) do
                    if not join_columns[col] then
                        local key = shared_columns[col] and (prefixes[1] .. "_" .. col) or col
                        joined_row[key] = val
                    end
                end

                -- Add non-join columns from df2
                for col, val in pairs(row2) do
                    if not join_columns[col] then
                        local key = shared_columns[col] and (prefixes[2] .. "_" .. col) or col
                        joined_row[key] = val
                    end
                end

                table.insert(joined_df, joined_row)
            end
        end
    end

    return joined_df
end


local function innerjoin_multiple(tables, columns, prefixes)
    prefixes = prefixes or {}
    local joined_table = {}
    local join_columns = {}
    
    -- Convert join columns to a set for quick lookup
    for _, col in ipairs(columns) do
        join_columns[col] = true
    end
    
    -- Identify overlapping non-join columns across all tables
    local column_sets = {}
    for i, tbl in ipairs(tables) do
        column_sets[i] = {}
        for _, row in ipairs(tbl) do
            for col in pairs(row) do
                if not join_columns[col] then
                    column_sets[i][col] = true
                end
            end
        end
    end
    
    -- Determine shared columns across multiple tables
    local shared_columns = {}
    for i = 1, #tables - 1 do
        for col in pairs(column_sets[i]) do
            for j = i + 1, #tables do
                if column_sets[j][col] then
                    shared_columns[col] = true
                end
            end
        end
    end
    
    -- Helper to check if rows match on all join columns
    local function rows_match(rows)
        for _, col in ipairs(columns) do
            local val = rows[1][col]
            for i = 2, #rows do
                if rows[i][col] ~= val then
                    return false
                end
            end
        end
        return true
    end
    
    -- Generate the Cartesian product and filter valid joins
    local function join_recursive(depth, selected_rows)
        if depth > #tables then
            if rows_match(selected_rows) then
                local joined_row = {}
                
                -- Add join columns once
                for _, col in ipairs(columns) do
                    joined_row[col] = selected_rows[1][col]
                end
                
                -- Add non-join columns with prefixes if necessary
                for i, row in ipairs(selected_rows) do
                    local prefix = prefixes[i] or ("tbl" .. i)
                    for col, val in pairs(row) do
                        if not join_columns[col] then
                            local key = shared_columns[col] and (prefix .. "_" .. col) or col
                            joined_row[key] = val
                        end
                    end
                end
                
                table.insert(joined_table, joined_row)
            end
            return
        end
        
        for _, row in ipairs(tables[depth]) do
            selected_rows[depth] = row
            join_recursive(depth + 1, selected_rows)
        end
    end
    
    join_recursive(1, {})
    return joined_table
end

dataframes.is_dataframe = is_dataframe
dataframes.view = view
dataframes.transpose = transpose
dataframes.groupby = groupby
dataframes.sum_values = sum_values
dataframes.mean_values = mean_values
dataframes.sort_by = sort_by
dataframes.select = select
dataframes.filter_by_value = filter_by_value
dataframes.filter_by_columns = filter_by_columns
dataframes.filter_unique = filter_unique
dataframes.generate_column = generate_column
dataframes.transform = transform
dataframes.diff = diff
dataframes.innerjoin = innerjoin
dataframes.innerjoin_multiple = innerjoin_multiple

-- Export the module
return dataframes
