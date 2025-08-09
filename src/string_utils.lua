-- Define a module table
local string_utils = {}


local function starts_with(str, prefix)
    local result = slice(str, 1, length(prefix))
    return prefix == result
end

local function ends_with(str, suffix)
    local result = slice(str, length(str) - length(suffix) + 1, length(str))
    return suffix == result
end

-- Splits a string by delimiter to a table
local function split(str, delimiter)
    local result = {}
    local token = ""
    local pos = 1
    local delimiter_length = length(delimiter)
    local str_length = length(str)

    while pos <= str_length do
        -- Check if the substring from pos to pos + delimiter_length - 1 matches the delimiter
        if str:sub(pos, pos + delimiter_length - 1) == delimiter then
            if token ~= "" then
                table.insert(result, token)
                token = ""
            end
            pos = pos + delimiter_length
        else
            token = token .. str:sub(pos, pos)
            pos = pos + 1
        end
    end

    if token ~= "" then
        table.insert(result, token)
    end

    return result
end

local function strip(str)
    return (str:gsub("%s+$", ""))
end

-- Escape special characters string
local function escape_string(str)
    local new_str = str:gsub("[%[%]%(%)%.%+%-%*%%]", "%%%1")
    return new_str
end

local function unescape_string(str)
    local new_str = str:gsub("%%([%[%]%(%)%.%+%-%*%%])", "%1")
    return new_str
end

-- Repeats a string n times into a new concatenated string
local function repeat_string(str, n)
    local result = ""
    for i = 1, n do
        result = result .. str
    end
    return result
end

string_utils.split = split
string_utils.strip = strip
string_utils.escape_string = escape_string
string_utils.unescape_string = unescape_string
string_utils.repeat_string = repeat_string
string_utils.starts_with = starts_with
string_utils.ends_with = ends_with

-- Export the module
return string_utils
