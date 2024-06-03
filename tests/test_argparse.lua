require("utils").using("utils")
using("argparse")

arg_string = [[
    -d --detach flag string false
    -o --output arg string true
    -i --iterations arg number false
]]

parsed_args = def_args(arg_string)
print_help(parsed_args)