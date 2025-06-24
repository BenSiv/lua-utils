-- Define a module table
local utils = {}

local lfs = require("lfs")
local yaml = require("yaml")
local json = require("dkjson")

-- Function to merge one module into another
local function merge_module(target, source)
	local env = getfenv(1)  -- Get the current function's environment (i.e., the module scope)
  	for k, v in pairs(source) do
    	target[k] = v
    	env[k] = v
  	end
end

local string_utils = require("string_utils")
merge_module(utils, string_utils)

local table_utils = require("table_utils")
merge_module(utils, table_utils)

-- Exposes all functions to global scope
local function using(source)
    module = require(source)
    for name,func in pairs(module) do
        _G[name] = func
    end
end

-- Read file content
local function read(path)
    local file = io.open(path, "r")
    local content = nil
    if file then
        content = file:read("*all")
        content = escape_string(content)
        file:close()
    else
        print("Failed to open " .. path)
    end
    return content
end

-- write content to file
local function write(path, content, append)
    local file
    if append then
        file = io.open(path, "a")
    else
        file = io.open(path, "w")
    end

    if file then
        file:write(content)
        file:close()
    else
        print("Failed to open " .. path)
    end
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
local function show(object)
    if type(object) ~= "table" then
        print(object)
    else
        show_table(object)
    end
end

-- Length alias for the # symbol
-- function length(tbl)
--     local len = #tbl
--     return len
-- end

local function length(containable)
    local cnt
    if type(containable) == "string" then
        cnt = #containable
    elseif type(containable) == "table" then
        cnt = 0
        for _, _ in pairs(containable) do
            cnt = cnt + 1
        end
    else
        error("Unsupported type given")
    end
    return cnt
end

-- Round a number
local function round(value, decimal)
    local factor = 10 ^ (decimal or 0)
    return math.floor(value * factor + 0.5) / factor
end

-- Helper function to compare two tables for deep equality
local function deep_equal(t1, t2)
    if t1 == t2 then return true end  -- Same reference
    if type(t1) ~= "table" or type(t2) ~= "table" then return false end

    for key, value in pairs(t1) do
        if type(value) == "table" and type(t2[key]) == "table" then
            if not deep_equal(value, t2[key]) then return false end
        elseif value ~= t2[key] then
            return false
        end
    end

    -- Check if `t2` has extra keys not present in `t1`
    for key in pairs(t2) do
        if t1[key] == nil then return false end
    end

    return true
end

-- Checks if an element is present in a table (supports deep comparison)
local function in_table(element, some_table)
    for _, value in pairs(some_table) do
        if type(element) == "table" and type(value) == "table" then
            if deep_equal(element, value) then return true end
        elseif value == element then
            return true
        end
    end
    return false
end

-- Checks if a substring is present in a string
local function in_string(element, some_string)
    return string.find(some_string, element) ~= nil
end

-- Generic function to check if an element is present in a composable type
local function occursin(element, source)
    if type(source) == "table" then
        return in_table(element, source)
    elseif type(source) == "string" then
        return in_string(element, source)
    else
    	print("Element: ", element)
    	print("Source: ", source)
        error("Unsupported type given")
    end
end

local function isempty(source)
    local answer = false
    if source and (type(source) == "table" or type(source) == "string") then
        if length(source) == 0 then
            answer = true
        end
    else
        print("Error: got a non containable type")
    end
    return answer
end

-- Syntax sugar for match
local function match(where, what)
    return string.match(where, what)
end

-- Syntax sugar for gmatch
local function match_all(where, what)
    return string.gmatch(where, what)
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
local function copy(source)
    if type(source) == "table" then
        new_copy = copy_table(source)
    else
        new_copy = source
    end
    return new_copy
end

-- Returns new table with replaced value
local function replace_table(tbl, old, new)
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

-- Returns new table with replaced value
local function replace_string(str, old, new)
    old = escape_string(old)
    local output_str = str:gsub(old, new)
    return output_str
end

-- Returns new table with replaced value
local function replace(container, old, new)
    if type(container) == "table" then
        answer = replace_table(container, old, new)
    elseif type(container) == "string" then
        answer = replace_string(container, old, new)
    else
        print("unsupported type given")
        return
    end
    return answer
end

-- Generic function to return the 0 value of type
local function empty(reference)
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
local function slice(source, start_index, end_index)
    if type(source) == "table" then
        result = slice_table(source, start_index, end_index)
    elseif type(source) == "string" then
        result = slice_string(source, start_index, end_index)
    else
        error("ERROR: can't slice element of type: " .. type(source))
    end
    return result
end

-- Reverse order of composable type, only top level
local function reverse(input)

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

local function readdir(directory)
    directory = directory or "."
    local files = {}
    for file in lfs.dir(directory) do
        if file ~= "." and file ~= ".." then
            table.insert(files, file)
        end
    end
    return files
end

local function sleep(n)
    local clock = os.clock
    local t0 = clock()
    while clock() - t0 <= n do end
end

local function read_yaml(file_path)
    local file = io.open(file_path, "r")
    local data
    if not file then
        error("Failed to read file: " .. file_path)
    else
        local content = file:read("*all")
        -- data = yaml.load(content)
        data = yaml.eval(content)
        file:close()
    end
    return data
end

local function read_json(file_path)
    local file = io.open(file_path, "r")
    local data
    if not file then
        error("Failed to read file: " .. file_path)
    else
        local content = file:read("*all")
        -- data = yaml.load(content)
        data = json.decode(content)
        file:close()
    end
    return data
end

-- Merge function to merge two sorted arrays
local function merge(left, right)
    local result = {}
    local left_size, right_size = #left, #right
    local left_index, right_index, result_index = 1, 1, 1

    -- Pre-allocate size
    for _ = 1, left_size + right_size do
        result[result_index] = {}
        result_index = result_index + 1
    end

    result_index = 1
    while left_index <= left_size and right_index <= right_size do
        if left[left_index] < right[right_index] then
            result[result_index] = left[left_index]
            left_index = left_index + 1
        else
            result[result_index] = right[right_index]
            right_index = right_index + 1
        end
        result_index = result_index + 1
    end

    -- Append remaining elements
    while left_index <= left_size do
        result[result_index] = left[left_index]
        left_index = left_index + 1
        result_index = result_index + 1
    end

    while right_index <= right_size do
        result[result_index] = right[right_index]
        right_index = right_index + 1
        result_index = result_index + 1
    end

    return result
end

-- Merge Sort function
local function merge_sort(array)
    local len_array = #array

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

    while left_index <= #left and right_index <= #right do
        if left[left_index].value < right[right_index].value then
            table.insert(result, left[left_index])
            left_index = left_index + 1
        else
            table.insert(result, right[right_index])
            right_index = right_index + 1
        end
    end

    -- Append remaining elements from left array
    while left_index <= #left do
        table.insert(result, left[left_index])
        left_index = left_index + 1
    end

    -- Append remaining elements from right array
    while right_index <= #right do
        table.insert(result, right[right_index])
        right_index = right_index + 1
    end

    return result
end

-- Merge Sort function along with indices
local function merge_sort_with_indices(array, _inner)
    -- _inner recursion boolean flag
    if not _inner then
        for i = 1, #array do
            array[i] =  {value = array[i], index = i}
        end
    end

    -- Base case: If array has one or zero elements, it's already sorted
    if #array <= 1 then
        return array
    end

    -- Split the array into two halves
    local middle = math.floor(#array / 2)
    local left = {}
    local right = {}

    for i = 1, middle do
        table.insert(left, array[i])
    end

    for i = middle + 1, #array do
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

-- Function to sort a table's values (and sub-tables recursively)
local function deep_sort(tbl)
	local sorted = merge_sort(tbl)

    for key, value in pairs(sorted) do
        if type(value) == "table" then
            sorted[key] = deep_sort(value)
        end
    end

    return sorted
end

local function apply(func, tbl, level, key, _current_level)
    _current_level = _current_level or 0
    level = level or 0
    local result = {}
    if _current_level < level then
        for k,v in pairs(tbl) do
            table.insert(result, apply(func, tbl[k], level, key, _current_level+1))
        end
    else
        if not key then
            for k,v in pairs(tbl) do
                result[k] = func(v)
            end
        elseif type(key) == "number" or type(key) == "string" then
            for k,v in pairs(tbl) do
                if k == key then
                    result[key] = func(v)
                else
                    result[k] = v
                end
            end
        elseif type(key) == "table" then
            for k,v in pairs(tbl) do
                if occursin(k, key) then
                    result[key] = func(v)
                else
                    result[k] = v
                end
            end
        else
            print("Unsupported key type")
        end
    end
    return result
end

-- Helper function to serialize table to string
local function serialize(tbl)
    local str = "{"
    for k, v in pairs(tbl) do
        if type(k) == "number" then
            str = str .. "[" .. k .. "]=" 
        else
            str = str .. k .. "="
        end

        if type(v) == "table" then
            str = str .. serialize(v) .. ","
        elseif type(v) == "string" then
            str = str .. '"' .. v .. '",'
        else
            str = str .. tostring(v) .. ","
        end
    end
    str = str .. "}"
    return str
end

-- Function to save a Lua table to a file
local function save_table(filename, tbl)
    local file = io.open(filename, "w")
    if file then
        file:write("return ")
        file:write(serialize(tbl))
        file:close()
    else
        print("Error: Unable to open file for writing")
    end
end

-- Function to load a Lua table from a file
local function load_table(filename)
    local chunk, err = loadfile(filename)
    if chunk then
        return chunk()
    else
        print("Error loading file: " .. err)
        return nil
    end
end

local function is_array(tbl)
    if type(tbl) ~= "table" then
        return false
    end

    local idx = 0
    for _ in pairs(tbl) do
        idx = idx + 1
        if tbl[idx] == nil then
            return false
        end
    end

    return true
end

-- Get the terminal line length
local function get_line_length()
    local handle = io.popen("stty size 2>/dev/null | awk '{print $2}'")
    if handle then
        local result = handle:read("*a")
        handle:close()
        return tonumber(result) or 80 -- Default to 80 if unable to fetch
    end
    return 80 -- Fallback to default width
end

local function exec_command(command)
    local process = io.popen(command)  -- Only stdout is captured here
    local output = process:read("*a")  -- Read the output
    local success = process:close()  -- Close the process and check for success
    return output, success
end

local function breakpoint()
  local level = 2  -- 1 would be inside this function, 2 is the caller
  local i = 1
  while true do
    local name, value = debug.getlocal(level, i)
    if not name then break end
    _G[name] = value
    i = i + 1
  end
  debug.debug()
end

local function show_methods(obj)
    for key, value in pairs(obj) do
        if type(value) == "function" then
            print("Function: " .. key)
        else
            print("Key: " .. key .. " -> " .. tostring(value))
        end
    end
end

-- Draw a progress bar
local function draw_progress(current, total)
    local width = get_line_length()
    local bar_width = width - 10 -- Room for percentage and brackets
    local percent = current / total
    local completed = math.floor(bar_width * percent)
    local remaining = bar_width - completed

    io.write("\r[")
    io.write(string.rep("=", completed))
    if remaining > 0 then
        io.write(">")
        io.write(string.rep(" ", remaining - 1))
    end
    io.write(string.format("] %3d%%", percent * 100))
    io.flush()

    -- Automatically move to a new line when finished
    if current == total then
        io.write("\n")
    end
end

local function list_globals()
    local result = {}
    for k, v in pairs(_G) do
        table.insert(result, {
            name = tostring(k),
            type = type(v)
        })
    end
    return result
end

utils.default_globals = list_globals()

local function user_defined_globals()
    local is_default_global = {}
   
    for _, entry in ipairs(utils.default_globals) do
        is_default_global[entry.name] = true
    end
    

    local user_globals = {}
    for k, v in pairs(_G) do
        if not is_default_global[k] then
            table.insert(user_globals, {
                name = k,
                type = type(v)
            })
        end
    end

    return user_globals
end

local function write_log_file(log_dir, filename, header, entries)
    if not log_dir then return nil end

    local file_path = joinpath(log_dir, filename)
    local file = io.open(file_path, "w")
    if not file then
        print("Failed to open " .. file_path)
        return nil
    end

    local current_datetime = os.date("%Y-%m-%d-%H-%M-%S")
    file:write(header .. "\n")
    file:write("-- Time stamp: " .. current_datetime .. "\n\n")

    for _, entry in pairs(entries) do
        file:write(entry)
        file:write("\n\n")
    end

    file:close()
    return "success"
end


utils.using = using
utils.read = read
utils.write = write
utils.show = show
utils.length = length
utils.is_array = is_array
utils.occursin = occursin
utils.isempty = isempty
utils.match = match
utils.match_all = match_all
utils.copy = copy
utils.replace = replace
utils.empty = empty
utils.slice = slice
utils.reverse = reverse
utils.readdir = readdir
utils.sleep = sleep
utils.read_yaml = read_yaml
utils.read_json = read_json
utils.sort = merge_sort
utils.sort_with_indices = merge_sort_with_indices
utils.get_sorted_indices = get_sorted_indices
utils.deep_sort = deep_sort
utils.apply = apply
utils.save_table = save_table
utils.load_table = load_table
utils.get_line_length = get_line_length
utils.exec_command = exec_command
utils.breakpoint = breakpoint
utils.show_methods = show_methods
utils.draw_progress = draw_progress
utils.list_globals = list_globals
utils.user_defined_globals = user_defined_globals
utils.write_log_file = write_log_file

-- Export the module
return utils
