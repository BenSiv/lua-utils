-- Define a module table
local utils = {}

local lfs = require("lfs")
local yaml = require("yaml")

-- exposes all functions to global scope
function using(source)
    module = require(source)
    for name,func in pairs(module) do
        _G[name] = func
    end
end

-- splits a string by delimiter to a table
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

-- repeats a string n times into a new concatenated string
local function repeat_string(str, n)
    local result = ""
    for i = 1, n do
        result = result .. str
    end
    return result
end

-- pretty print a table
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

-- pretty print generic
function show(object)
    if type(object) ~= "table" then
        print(object)
    else
        show_table(object)
    end
end

-- length alias for the # symbol
function length(table)
    local len = #table
    return len
end

-- checks if element in table
local function in_table(element, some_table)
    local answer = false
    for _, value in pairs(some_table) do
        if value == element then
            answer = true
        end
    end
    return answer
end

-- checks if substring in string
local function in_string(element, some_string)
    local answer = false
    if string.find(some_string, element) then
        answer = true
    else
        answer = false
    end
    return answer
end

-- generic function to check if element in composable type
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

-- returns a copy of table
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

-- generic copy
function copy(source)
    if type(source) == "table" then
        new_copy = copy_table(source)
    else
        new_copy = source
    end
    return new_copy
end

-- returns new table with replaced value
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

-- generic function to return the 0 value of type
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

-- generic slice function for composable types
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

-- reverse order of composable type, only top level
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
--     local str = debug.getinfo(2, "S").source:sub(2)
--     return str:match("(.*/)")
--  end

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


utils.using = using
utils.split = split
utils.repeat_string = repeat_string
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
utils.readdir = readdir
utils.insert = insert
utils.keys = keys
-- utils.script_path = script_path
utils.dirname = dirname
utils.sleep = sleep
utils.read_yaml = read_yaml

-- Export the module
return utils