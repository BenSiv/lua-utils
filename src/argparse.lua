require("utils").using("utils")
using("dataframes")

-- Define a module table
local argparse = {}

local function print_help(cmd_args, expected_args)
    print("Usage: ", cmd_args[0])
    local help_df = {}
    for _, arg_parsed in pairs(expected_args) do
        local row = {
            short = "-" .. arg_parsed["short"],
            long = "--" .. arg_parsed["long"],
            kind = arg_parsed["arg_kind"],
            type = arg_parsed["arg_type"],
            required = tostring(arg_parsed["is_required"])
        }
        table.insert(help_df, row)
    end
    view(help_df)
    print()
end

local function add_arg(expected_args, short, long, arg_kind, arg_type, is_required)
    if not expected_args then
        expected_args = {}
    end
    local arg_to_add = {
        short = short,
        long = long,
        arg_kind = arg_kind,
        arg_type = arg_type,
        is_required = is_required
    }
    table.insert(expected_args, arg_to_add)
    return expected_args
end

local function def_args(arg_string)
    local expected_args = {}
    local short, long, arg_kind, arg_type, is_required
    for line in match_all(arg_string, "[^\r\n]+") do
    	if not match(line, "^$s*$") then
        	short, long, arg_kind, arg_type, is_required = match(line, "%s*%-(%a)%s+%-%-([%a_]+)%s+(%a+)%s+(%a+)%s+(%a+)%s*")
        	is_required = is_required == "true"
        	if short and long and arg_kind and arg_type then
        		expected_args = add_arg(expected_args, short, long, arg_kind, arg_type, is_required)
        	end
        end
    end
    return expected_args
end

local function parse_args(cmd_args, expected_args)
    local result = {}
    local arg_map = {}

    -- Create a map for quick lookup of parsed_args by short and long names
    for _, arg_parsed in pairs(expected_args) do
        arg_map["-" .. arg_parsed.short] = arg_parsed
        arg_map["--" .. arg_parsed.long] = arg_parsed
    end

    local i = 1
    while i <= length(cmd_args) do
        local arg_name = cmd_args[i]
        local parsed_arg = arg_map[arg_name]

        if not parsed_arg then
            print("Unknown argument: " .. arg_name)
            print_help(cmd_args, expected_args)
            return nil
        end

        if parsed_arg.arg_kind == "flag" then
            result[parsed_arg.long] = true
        elseif parsed_arg.arg_kind == "arg" then
            i = i + 1
            if i > length(cmd_args) then
                print("Expected value after " .. arg_name)
                print_help(cmd_args, expected_args)
                return nil
            end
            if parsed_arg.arg_type == "number" then
                result[parsed_arg.long] = tonumber(cmd_args[i])
            else
                result[parsed_arg.long] = cmd_args[i]
            end
        end

        i = i + 1
    end

    -- Check for required arguments
    for _, arg_parsed in pairs(expected_args) do
        if arg_parsed.is_required and result[arg_parsed.long] == nil then
            print("Missing required argument: --" .. arg_parsed.long .. "\n")
            print_help(expected_args)
            return nil
        end
    end

    return result
end

argparse.print_help = print_help
argparse.add_arg = add_arg
argparse.def_args = def_args
argparse.parse_args = parse_args

-- Export the module
return argparse


-- example of arg_string
-- local arg_string = [[
--     -d --detach flag string false
--     -o --output arg string true
--     -i --iterations arg number false
-- ]]

-- local expected_args = def_args(arg_string)
-- local args = parse_args(arg, expected_args)
