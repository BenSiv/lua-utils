-- Define a module table
local utils = {}

local lfs = require("lfs")
local yaml = require("yaml")

-- Exposes all functions to global scope
function using(source)
    module = require(source)
    for name,func in pairs(module) do
        _G[name] = func
    end
end

-- Read file content
function read(path)
    local file = io.open(path, "r")
    local content = nil
    if file then
        content = file:read("*all")
        file:close()
    else
        print("Failed to open " .. path)
    end
    return content
end

-- Repeats a string n times into a new concatenated string
local function repeat_string(str, n)
    local result = ""
    for i = 1, n do
        result = result .. str
    end
    return result
end

-- Pretty print a table
local function show_table(tbl, indent_level)
    indent_level = indent_level or 0
    local indent = repeat_string(" ", 4)
    local current_indent = repeat_string(indent, indent_level)
    print(current_indent .. "{")
    indent_level = indent_level + 1
    local current_indent = repeat_string(indent, indent_level)
    for key, value in pairs(tbl) do
        if type(value) ~= "table" then
            if type(value) == "boolean" then
                print(current_indent .. key .. " = " .. tostring(value))
            else
                print(current_indent .. key .. " = " .. value)
            end
        else
            print(current_indent .. key .. " = ")
            show_table(value, indent_level)
        end
    end
    indent_level = indent_level - 1
    local current_indent = repeat_string(indent, indent_level)
    print(current_indent .. "}")
end


-- Pretty print generic
function show(object)
    if type(object) ~= "table" then
        print(object)
    else
        show_table(object)
    end
end

-- Length alias for the # symbol
function length(tbl)
    local len = #tbl
    return len
end

-- Round a number
function round(value, decimal)
    local factor = 10 ^ (decimal or 0)
    return math.floor(value * factor + 0.5) / factor
end

-- Checks if element in table
local function in_table(element, some_table)
    local answer = false
    for _, value in pairs(some_table) do
        if value == element then
            answer = true
        end
    end
    return answer
end

-- Checks if substring in string
local function in_string(element, some_string)
    local answer = false
    if string.find(some_string, element) then
        answer = true
    else
        answer = false
    end
    return answer
end

-- Generic function to check if element in composable type
function occursin(element, source)
    local answer = false
    if type(source) == "table" then
        answer = in_table(element, source)
    elseif type(source) == "string" then
        answer = in_string(element, source)
    else
        print("unsupported type given")
        return
    end
    return answer
end

-- Syntax sugar for match
function match(what, where)
    return where:match(what)
end

-- Syntax sugar for gmatch
function match_all(what, where)
    local answer = where:gmatch(what)
    return answer
end

-- Returns a copy of table
local function copy_table(tbl)
    local new_copy = {}
    for key, value in pairs(tbl) do
        if type(value) == "table" then
            new_copy[key] = copy_table(value)
        else
            new_copy[key] = value
        end
    end
    return new_copy
end

-- Generic copy
function copy(source)
    if type(source) == "table" then
        new_copy = copy_table(source)
    else
        new_copy = source
    end
    return new_copy
end

-- Returns new table with replaced value
function replace(tbl, old, new)
    local new_table = {}
    for key, value in pairs(tbl) do
        if type(value) == "table" then
            new_table[key] = replace(value, old, new)
        elseif value == old then
            new_table[key] = new
        else
            new_table[key] = value
        end
    end
    return new_table
end

-- Generic function to return the 0 value of type
function empty(reference)
    local new_var

    if type(reference) == "number" then
        new_var = 0 -- Initialize as a number
    elseif type(reference) == "string" then
        new_var = "" -- Initialize as a string
    elseif type(reference) == "table" then
        new_var = {} -- Initialize as a table
    end

    return new_var
end

local function slice_table(source, start_index, end_index)
    local result = {}
    for i = start_index, end_index do
        if source[i] then
            table.insert(result, source[i])
        else
            error("ERROR: index is out of range")
            break
        end
    end
    return result
end

local function slice_string(source, start_index, end_index)
    return source:sub(start_index, end_index)
end

-- Generic slice function for composable types
function slice(source, start_index, end_index)
    if type(source) == "table" then
        result = slice_table(source, start_index, end_index)
    elseif type(source) == "string" then
        result = slice_string(source, start_index, end_index)
    else
        error("ERROR: can't slice element of type: " .. type(source))
    end
    return result
end

-- Splits a string by delimiter to a table
function split(str, delimiter)
    local result = {}
    local token = ""
    local pos = 1

    while pos <= length(str) do
        local char = str:sub(pos, pos)
        if char == delimiter then
            if token ~= "" then
                table.insert(result, token)
                token = ""
            end
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

-- Reverse order of composable type, only top level
function reverse(input)

    if type(input) == "string" then
        reversed = ""
        -- Reverse a string
        for i = #input, 1, -1 do
            reversed = reversed .. string.sub(input, i, i)
        end
    elseif type(input) == "table" then
        reversed = {}
        -- Reverse a table
        for i = #input, 1, -1 do
            table.insert(reversed, input[i])
        end
    else
        error("Unsupported type for reversal")
    end

    return reversed
end

function readdir(directory)
    directory = directory or "."
    local files = {}
    for file in lfs.dir(directory) do
        if file ~= "." and file ~= ".." then
            table.insert(files, file)
        end
    end
    return files
end

function insert(tbl, element)
    if type(tbl) ~= "table" then
        error("Input is not a table")
    end

    new_tbl = copy_table(tbl)

    table.insert(tbl, element)

    return new_tbl
end

function keys(tbl)
    if type(tbl) ~= "table" then
        error("Input is not a table")
    end

    local keys = {}
    for key, _ in pairs(tbl) do
        table.insert(keys, key)
    end
    return keys
end

function values(tbl)
    if type(tbl) ~= "table" then
        error("Input is not a table")
    end

    local values = {}
    for _, value in pairs(tbl) do
        table.insert(values, value)
    end
    return values
end

-- function script_path()
--     local str = debug.getinfo(1, "S").source:sub(2)
--     return str:match("(.*/)")
-- end

function dirname(path)
    local last_sep = path:match(".*/")
    if last_sep then
        return slice(path, 1, length(last_sep))
    else
        return path
    end
end

function sleep(n)
    local clock = os.clock
    local t0 = clock()
    while clock() - t0 <= n do end
end

function read_yaml(file_path)
    local file = io.open(file_path, "r")
    local data
    if not file then
        error("Failed to read file: " .. file_path)
    else
        local content = file:read("*all")
        data = yaml.load(content)
        file:close()
    end
    return data
end


-- Merge function to merge two sorted arrays
local function merge(left, right)
    local result = {}
    local left_index, right_index = 1, 1

    while left_index <= length(left) and right_index <= length(right) do
        if left[left_index] < right[right_index] then
            table.insert(result, left[left_index])
            left_index = left_index + 1
        else
            table.insert(result, right[right_index])
            right_index = right_index + 1
        end
    end

    -- Append remaining elements from left array
    while left_index <= length(left) do
        table.insert(result, left[left_index])
        left_index = left_index + 1
    end

    -- Append remaining elements from right array
    while right_index <= length(right) do
        table.insert(result, right[right_index])
        right_index = right_index + 1
    end

    return result
end

-- Merge Sort function
local function merge_sort(array)
    local len_array = length(array)

    -- Base case: If array has one or zero elements, it's already sorted
    if len_array <= 1 then
        return array
    end

    -- Split the array into two halves
    local middle = math.floor(len_array / 2)
    local left = {}
    local right = {}

    for i = 1, middle do
        table.insert(left, array[i])
    end

    for i = middle + 1, len_array do
        table.insert(right, array[i])
    end

    -- Recursively sort both halves
    left = merge_sort(left)
    right = merge_sort(right)

    -- Merge the sorted halves
    return merge(left, right)
end

-- Merge function to merge two sorted arrays along with their indices
local function merge_with_indices(left, right)
    local result = {}
    local left_index, right_index = 1, 1

    while left_index <= length(left) and right_index <= length(right) do
        if left[left_index].value < right[right_index].value then
            table.insert(result, left[left_index])
            left_index = left_index + 1
        else
            table.insert(result, right[right_index])
            right_index = right_index + 1
        end
    end

    -- Append remaining elements from left array
    while left_index <= length(left) do
        table.insert(result, left[left_index])
        left_index = left_index + 1
    end

    -- Append remaining elements from right array
    while right_index <= length(right) do
        table.insert(result, right[right_index])
        right_index = right_index + 1
    end

    return result
end

-- Merge Sort function along with indices
local function merge_sort_with_indices(array, inner)
    local len_array = length(array)

    if not inner then
        for i = 1, len_array do
            array[i] =  {value = array[i], index = i}
        end
    end

    -- Base case: If array has one or zero elements, it's already sorted
    if len_array <= 1 then
        return array
    end

    -- Split the array into two halves
    local middle = math.floor(len_array / 2)
    local left = {}
    local right = {}

    for i = 1, middle do
        -- left[i] = array[i]
        -- table.insert(left, {value = array[i], index = i})
        table.insert(left, array[i])
    end

    for i = middle + 1, len_array do
        -- right[i] = array[i]
        -- table.insert(right, {value = array[i], index = i})
        table.insert(right, array[i])

    end

    -- Recursively sort both halves
    left = merge_sort_with_indices(left, true)
    right = merge_sort_with_indices(right, true)

    -- Merge the sorted halves
    return merge_with_indices(left, right)
end

-- Function to get the indices of sorted values
local function get_sorted_indices(array)
    local sorted_with_indices = merge_sort_with_indices(array)
    local indices = {}
    for _, item in ipairs(sorted_with_indices) do
        table.insert(indices, item.index)
    end
    return indices
end

utils.using = using
utils.read = read
utils.split = split
utils.repeat_string = repeat_string
utils.show = show
utils.show_table = show_table
utils.length = length
utils.in_table = in_table
utils.in_string = in_string
utils.occursin = occursin
utils.match = match
utils.match_all = match_all
utils.copy_table = copy_table
utils.copy = copy
utils.replace = replace
utils.empty = empty
utils.slice = slice
utils.reverse = reverse
utils.readdir = readdir
utils.insert = insert
utils.keys = keys
utils.values = values
-- utils.script_path = script_path
utils.dirname = dirname
utils.sleep = sleep
utils.read_yaml = read_yaml
utils.merge_sort = merge_sort
utils.merge_sort_with_indices = merge_sort_with_indices
utils.get_sorted_indices = get_sorted_indices

-- Export the module
return utils