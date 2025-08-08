require("utils").using("utils")
using("argparse")

arg_string = [[
    -d --detach flag string false
    -o --output arg string true
    -i --iterations arg number false
]]

help_string = [[

-d --detach: Detach the process (flag)
-o --output: Specify the output file (arg, required)
-i --iterations: Number of iterations to perform (arg, number)
]]

expected_args = def_args(arg_string)
-- print_help(expected_args)
-- show(expected_args)

-- arg = {
--     [-1] = "lua",
--     [0] = "this_script.lua",
--     [1] = "-d",
--     [2] = "-i",
--     [3] = "5",
--     [4] = "--output",
--     [5] = "out_file.txt",
-- }

-- arg = {
--     [-1] = "lua",
--     [0] = "this_script.lua",
--     [1] = "-h"
-- }

parsed_args = parse_args(arg, expected_args, help_string)
show(parsed_args)