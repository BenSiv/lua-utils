-- local current_time = os.time()
-- local current_date = os.date("%Y-%m-%d")
-- local converted_date = os.date("%Y-%m-%d", os.time{year=2024, month=1, day=10})

local utils = require("utils")

-- Define a module table
local dates = {}

local function pad_to_length(input, total_length, pad_char)
    pad_char = pad_char or '0'
    while utils.length(input) < total_length do
        input = input .. pad_char
    end
    return input
end

local function normalize_datetime(datetime_str)
    local year, month, day, hour, min, sec

    if utils.length(datetime_str) == 4 then
        year = datetime_str
        month, day, hour, min, sec = "01", "01", "00", "00", "00"
    elseif utils.length(datetime_str) == 7 then
        year, month = datetime_str:match("(%d%d%d%d)-(%d%d)")
        if not (year and month) then return nil end
        day, hour, min, sec = "01", "00", "00", "00"
    elseif utils.length(datetime_str) == 10 then
        year, month, day = datetime_str:match("(%d%d%d%d)-(%d%d)-(%d%d)")
        if not (year and month and day) then return nil end
        hour, min, sec = "00", "00", "00"
    elseif utils.length(datetime_str) == 16 then
        year, month, day, hour, min = datetime_str:match("(%d%d%d%d)-(%d%d)-(%d%d) (%d%d):(%d%d)")
        if not (year and month and day and hour and min) then return nil end
        sec = "00"
    elseif utils.length(datetime_str) == 19 then
        year, month, day, hour, min, sec = datetime_str:match("(%d%d%d%d)-(%d%d)-(%d%d) (%d%d):(%d%d):(%d%d)")
        if not (year and month and day and hour and min and sec) then return nil end
    else
        return nil
    end

    year = pad_to_length(year or "", 4, "0")
    month = pad_to_length(month or "01", 2, "0")
    day = pad_to_length(day or "01", 2, "0")
    hour = pad_to_length(hour or "00", 2, "0")
    min = pad_to_length(min or "00", 2, "0")
    sec = pad_to_length(sec or "00", 2, "0")

    return year .. "-" .. month .. "-" .. day .. " " .. hour .. ":" .. min .. ":" .. sec
end

local function is_valid_timestamp(timestamp)
    local pattern = "^%d%d%d%d%-%d%d%-%d%d %d%d:%d%d:%d%d$"
    local answer = false

    if timestamp then
        if type(timestamp) == "string" then
            if timestamp:match(pattern) then
                local year, month, day, hour, minute, second = timestamp:match("(%d%d%d%d)%-(%d%d)%-(%d%d) (%d%d):(%d%d):(%d%d)")

                year = tonumber(year)
                month = tonumber(month)
                day = tonumber(day)
                hour = tonumber(hour)
                minute = tonumber(minute)
                second = tonumber(second)

                local is_leap_year = (year % 4 == 0 and year % 100 ~= 0) or (year % 400 == 0)
                local days_in_month = {
                    31, (is_leap_year and 29 or 28), 31, 30, 31, 30, 31, 31, 30, 31, 30, 31
                }

                if month >= 1 and month <= 12 and
                   day >= 1 and day <= days_in_month[month] and
                   hour >= 0 and hour <= 23 and
                   minute >= 0 and minute <= 59 and
                   second >= 0 and second <= 59 then
                    answer = true
                end
            end
        end
    end

    return answer
end


local function convert_date_format(input_date)
    -- Split the input string based on the "." delimiter
    local day, month, year = input_date:match("(%d+).(%d+).(%d+)")
    -- Rearrange the components into the desired format "yyyy-mm-dd"
    local output_date = year .. "-" .. month .. "-" .. day
    return output_date
end

local function date_range(first_date, last_date, unit, interval)
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

local function disect_date(input_date)
    local year, month, day = input_date:match("(%d+)-(%d+)-(%d+)")
    return year, month, day
end

local function get_day(input_date)
    local year, month, day = disect_date(input_date)
    return day
end

local function get_month(input_date)
    local year, month, day = disect_date(input_date)
    return month
end

local function get_year(input_date)
    local year, month, day = disect_date(input_date)
    return year
end

dates.normalize_datetime = normalize_datetime
dates.is_valid_timestamp = is_valid_timestamp
dates.convert_date_format = convert_date_format
dates.disect_date = disect_date
dates.get_day = get_day
dates.get_month = get_month
dates.get_year = get_year

-- Export the module
return dates
