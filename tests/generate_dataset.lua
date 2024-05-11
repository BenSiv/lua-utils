-- generate dataset of transaction for transactions analysis

require("utils").using("utils")
using("dates")
using("dataframes")
using("delimited_files")

local function get_salary(min, max)
    local salary = math.random(min, max)
    return salary
end

local function get_salary_day()
    local day_in_month = math.random(1, 10)
    return day_in_month
end

local function get_expenses_range()
    local expenses_range = {
        min = math.random(0, 200),
        max = math.random(200, 2000)
    }
    return expenses_range
end

local function get_expense(expenses_range)
    local expense = math.random(expenses_range.min, expenses_range.max)
    return expense
end

local function get_major_expense(expenses_range, factor)
    local expense = get_expense(expenses_range)
    local major_expense = expense * factor
    return major_expense
end

-- the probability to make an expence each day
local function get_expense_probability(min, max)
    local expense_probability = math.random(min*100, max*100)/100
    return expense_probability
end

local function get_person(id, min_salary, max_salary)
    -- define a person
    local person = {
        id = id,
        salary = get_salary(min_salary, max_salary),
        salary_day = get_salary_day(),
        expenses_range = get_expenses_range(),
        expense_probability = get_expense_probability(0.1, 0.5),
        major_expenses_factor = math.random(2, 10)
    }

    return person
end

local function does_expend(person)
    local random_value = math.random()
    local expend = false
    if random_value > person.expense_probability then
        expend = true
    else
        expend = false
    end
    return expend
end

local function generate_month(person, initial_balance, year, month)
    local data = {
        Id = {},
        Date = {},
        In = {},
        Out = {},
        Balance = {}
    }

    local balance = initial_balance
    local day = 1
    local initial_date = os.date("%Y-%m-%d", os.time{year=year, month=month, day=day})
    local salary_date = os.date("%Y-%m-%d", os.time{year=year, month=month, day=person.salary_day})
    local current_date = os.date("%Y-%m-%d", os.time{year=year, month=month, day=day})

    while get_month(current_date) == get_month(initial_date) do
        local balance_in = 0
        local balance_out = 0
        table.insert(data.Id, person.id)
        table.insert(data.Date, current_date)

        if get_day(current_date) == get_day(salary_date) then
            balance_in = person.salary
            table.insert(data.In, balance_in)
        else
            balance_in = 0
            table.insert(data.In, balance_in)
        end

        if get_day(current_date) == "10" then
            balance_out = get_major_expense(person.expenses_range, person.major_expenses_factor)
            table.insert(data.Out, balance_out)
        elseif does_expend(person) then
            balance_out = get_expense(person.expenses_range)
            table.insert(data.Out, balance_out)
        else
            balance_out = 0
            table.insert(data.Out, balance_out)
        end

        balance = balance - balance_out + balance_in
        table.insert(data.Balance, balance)
        day = day + 1
        current_date = os.date("%Y-%m-%d", os.time{year=year, month=month, day=day})
    end

    return data
end

local function generate_data(months, peoples, min_salary, max_salary, initial_balance, initial_year, output_file)
    local first_loop = true
    for m = 1, months do
        for p = 1, peoples do
            local person = get_person(p, min_salary, max_salary)
            local data = generate_month(person, initial_balance, initial_year, m)
            if first_loop then
                first_loop = false
                -- writedlm(filename, delimiter, data, header, append)
                writedlm(output_file, "\t", transpose(data), true, false)
            else
                -- writedlm(filename, delimiter, data, header, append)
                writedlm(output_file, "\t", transpose(data), false, true)
            end
        end
    end
end

local function main()
    local params = read_yaml("params.yaml")
    generate_data(
        params.months,
        params.people,
        params.min_salary,
        params.max_salary,
        params.initial_balance,
        params.initial_year,
        "data/transactions.tsv"
    )
end

-- runnnig script
main()