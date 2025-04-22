-- Define a module table
local table_utils = {}

local function swap_keys_values(tbl)
    local swapped = {}
    for k, v in pairs(tbl) do
        swapped[v] = k
    end
    return swapped
end

local function keys(tbl)
    if type(tbl) ~= "table" then
        error("Input is not a table")
    end

    local keys = {}
    for key, _ in pairs(tbl) do
        table.insert(keys, key)
    end
    return keys
end

local function values(tbl)
    if type(tbl) ~= "table" then
        error("Input is not a table")
    end

    local values = {}
    for _, value in pairs(tbl) do
        table.insert(values, value)
    end
    return values
end

local function unique(tbl)
    result = {}
    for _, element in pairs(tbl) do 
        if not occursin(element, result) then
            table.insert(result, element)
        end
    end
    return result
end

table_utils.swap_keys_values = swap_keys_values
table_utils.keys = keys
table_utils.values = values
table_utils.unique = unique

-- Export the module
return table_utils
