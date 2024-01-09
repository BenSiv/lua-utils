-- Define a module table
local utils = {}

-- local lfs = require("lfs")

function using(source)
    module = require(source)
    for name,func in pairs(module) do
        _G[name] = func
    end
end

function split(str, delimiter)
    local result = {}
    local token = ""
    local start = 1
    local pos = 1
    
    while pos <= length(str) do
        local char = str:sub(pos, pos)
        if char == delimiter then
            table.insert(result, token)
            start = pos + 1
            token = ""
        else
            token = token .. char
        end
        pos = pos + 1
    end

    table.insert(result, token)

    return result
end

local function repeat_string(str, n)
    local result = ""
    for i = 1, n do
        result = result .. str
    end
    return result
end

local function show_table(table, indent_level)
    indent_level = indent_level or 0
    local indent = repeat_string(" ", 4)
    local current_indent = repeat_string(indent, indent_level)
    print(current_indent .. "{")
    indent_level = indent_level + 1
    local current_indent = repeat_string(indent, indent_level)
    for key, value in pairs(table) do
        if type(value) ~= "table" then
            print(current_indent .. key .. " = " .. value)
        else
            print(current_indent .. key .. " = ")
            show_table(value, indent_level)
        end
    end
    indent_level = indent_level - 1
    local current_indent = repeat_string(indent, indent_level)
    print(current_indent .. "}")
end

function show(object)
    if type(object) ~= "table" then
        print(object)
    else
        show_table(object)
    end
end

function length(table)
    local len = #table
    return len
end

local function in_table(element, some_table)
    local answer = false
    for _, value in pairs(some_table) do
        if value == element then
            answer = true
        end
    end
    return answer
end

local function in_string(element, some_string)
    local answer = false
    if string.find(some_string, element) then
        answer = true
    else
        answer = false
    end
    return answer
end

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

local function copy_table(table)
    local new_copy = {}
    for key, value in pairs(table) do
        if type(value) == "table" then
            new_copy[key] = copy_table(value)
        else
            new_copy[key] = value
        end
    end
    return new_copy
end

function copy(source)
    if type(source) == "table" then
        new_copy = copy_table(source)
    else
        new_copy = source
    end
    return new_copy
end

function replace(table, old, new)
    local new_table = copy_table(table)
    for i, value in ipairs(new_table) do
        if type(value) == "table" then
            replace(value, old, new)
        elseif value == old then
            new_table[i] = new
        end
    end
    return new_table
end

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

-- function readdir(directory)
--     directory = directory or "."
--     local files = {}
--     for file in lfs.dir(directory) do
--         if file ~= "." and file ~= ".." then
--             table.insert(files, file)
--         end
--     end
--     return files
-- end

utils.using = using
utils.split = split
utils.show = show
utils.show_table = show_table
utils.length = length
utils.in_table = in_table
utils.in_string = in_string
utils.occursin = occursin
utils.copy_table = copy_table
utils.copy = copy
utils.replace = replace
utils.empty = empty
utils.slice = slice
utils.reverse = reverse

-- Export the module
return utils