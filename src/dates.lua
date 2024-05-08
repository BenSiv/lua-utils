-- local current_time = os.time()
-- local current_date = os.date("%Y-%m-%d")
-- local converted_date = os.date("%Y-%m-%d", os.time{year=2024, month=1, day=10})

require("utils").using("utils")

-- Define a module table
local dates = {}

function convert_date_format(input_date)
    -- Split the input string based on the "." delimiter
    local day, month, year = input_date:match("(%d+).(%d+).(%d+)")
    -- Rearrange the components into the desired format "yyyy-mm-dd"
    local output_date = year .. "-" .. month .. "-" .. day
    return output_date
end

function get_year(date)
    local year = date:sub(1, 4)
    return year
end

function get_month(date)
    local month = date:sub(6, 7)
    return month
end

function get_day(date)
    local day = date:sub(9, 10)
    return day
end

dates.convert_date_format = convert_date_format
dates.get_year = get_year
dates.get_month = get_month
dates.get_day = get_day

-- Export the module
return dates