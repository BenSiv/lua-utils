-- Define a module table
local prettyprint = {}

function bold(str)
    print("\27[1m" .. str .. "\27[0m")
end

function color(str, clr)
    local color_dict = {
        blue = {
            before = "\27[34m",
            after = "\27[0m"
        },
        yellow = {
            before = "\27[33m",
            after = "\27[0m"
        },
        red = {
            before = "\27[31m",
            after = "\27[0m"
        },
        green = {
            before = "\27[32m",
            after = "\27[0m"
        },
        purple = {
            before = "\27[35m",
            after = "\27[0m"
        },
        orange = {
            before = "\27[38;5;214m", -- Orange is not standard in ANSI, so using an extended color
            after = "\27[0m"
        }
    }

    if color_dict[clr] then
        print(color_dict[clr].before .. str .. color_dict[clr].after)
    else
        print(str) -- Default to no color if invalid color name is provided
    end
end

prettyprint.bold = bold
prettyprint.color = color

-- Export the module
return prettyprint
