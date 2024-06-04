require("utils").using("utils")
using("argparse")

arg_string = [[
    -d --detach flag string false
    -o --output arg string true
    -i --iterations arg number false
]]

expected_args = def_args(arg_string)
-- print_help(expected_args)
-- show(expected_args)

-- arg = {"this_script.lua", "-d", "--output", "out_file.txt", "-i", "5"}

parsed_args = parse_args(arg, expected_args)
show(parsed_args)