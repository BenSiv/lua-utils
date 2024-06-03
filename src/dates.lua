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

function date_range(first_date, last_date, unit, interval)
	local full_date_range = {}
	local current_date = first_date
	table.insert(full_date_range, current_date)
	while current_date ~= last_date do
		local year, month, day = current_date:match("(%d+)-(%d+)-(%d+)")
        if unit == "day" then
		    current_date = os.date("%Y-%m-%d", os.time{year=year, month=month, day=day+interval})
        elseif unit == "month" then
		    current_date = os.date("%Y-%m-%d", os.time{year=year, month=month+interval, day=day})
        elseif unit == "year" then
		    current_date = os.date("%Y-%m-%d", os.time{year=year+interval, month=month, day=day})
        else
            print("Unknown time unit")
        end
		table.insert(full_date_range, current_date)
	end
    return full_date_range
end

function disect_date(input_date)
    local year, month, day = input_date:match("(%d+)-(%d+)-(%d+)")
    return year, month, day
end

function get_day(input_date)
    local year, month, day = disect_date(input_date)
    return day
end

function get_month(input_date)
    local year, month, day = disect_date(input_date)
    return month
end

function get_year(input_date)
    local year, month, day = disect_date(input_date)
    return year
end

dates.convert_date_format = convert_date_format
dates.disect_date = disect_date
dates.get_day = get_day
dates.get_month = get_month
dates.get_year = get_year

-- Export the module
return dates