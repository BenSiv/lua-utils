require("utils").using("utils")

-- Define a module table
local argparse = {}

local function print_help(parsed_args)
    print("Usage: ", arg[0])
    for _, arg_parsed in pairs(parsed_args) do
        print(
            "-" .. arg_parsed["short"],
            "--" .. arg_parsed["long"],
            "kind: " .. arg_parsed["arg_kind"],
            "of type: " .. arg_parsed["arg_type"],
            "required: " .. tostring(arg_parsed["is_required"])
        )
    end
end

local function add_arg(parsed_args, short, long, arg_kind, arg_type, is_required)
    if not parsed_args then
        parsed_args = {}
    end
    local arg_to_add = {
        short = short,
        long = long,
        arg_kind = arg_kind,
        arg_type = arg_type,
        is_required = is_required
    }
    table.insert(parsed_args, arg_to_add)
    return parsed_args
end

local function def_args(arg_string)
    local parsed_args = {}
    for line in arg_string:gmatch("[^\r\n]+") do
        local short, long, arg_kind, arg_type, is_required = line:match("%s*%-(%w)%s+%-%-(%w+)%s+(%w+)%s+(%w+)%s+(%w+)%s*")
        is_required = is_required == "true"
        parsed_args = add_arg(parsed_args, short, long, arg_kind, arg_type, is_required)
    end
    return parsed_args
end

local function parse_args(arg, parsed_args)
    local result = {}
    local arg_map = {}

    -- Create a map for quick lookup of parsed_args by short and long names
    for _, arg_parsed in pairs(parsed_args) do
        arg_map["-" .. arg_parsed.short] = arg_parsed
        arg_map["--" .. arg_parsed.long] = arg_parsed
    end

    local i = 1
    while i <= length(arg) do
        local arg_name = arg[i]
        local parsed_arg = arg_map[arg_name]

        if not parsed_arg then
            error("Unknown argument: " .. arg_name)
        end

        if parsed_arg.arg_kind == "flag" then
            result[parsed_arg.long] = true
        elseif parsed_arg.arg_kind == "arg" then
            i = i + 1
            if i > length(arg) then
                error("Expected value after " .. arg_name)
            end
            if parsed_arg.arg_type == "number" then
                result[parsed_arg.long] = tonumber(arg[i])
            else
                result[parsed_arg.long] = arg[i]
            end
        end

        i = i + 1
    end

    return result
end

argparse.print_help = print_help
argparse.add_arg = add_arg
argparse.def_args = def_args
argparse.parse_args = parse_args

-- Export the module
return argparse
