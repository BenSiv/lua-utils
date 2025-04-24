require("utils").using("utils")
using("dataframes")

-- Example usage
-- local df1 = {
--     {id = 1, name = "Alice", age = 25, height = 1.6, city = "NYC"},
--     {id = 2, name = "Bob", age = 30, height = 1.8, city = "LA"},
--     {id = 3, name = "Charlie", age = 35, height = 1.7, city = "Chicago"},
-- }
-- view(df1)
-- print(" ")

-- local df2 = {
--     {id = 1, name = "Alicia", location = "NYC", height = 1.6, city = "NYC"},
--     {id = 2, name = "Bobby", location = "LA", height = 1.8, city = "LA"},
--     {id = 4, name = "Dave", location = "Chicago", height = 1.7, city = "Chicago"},
-- }
-- view(df2)
-- print(" ")

-- local columns = {"id", "height", "city"}
-- local prefixes = {"df1", "df2"}

-- local result = innerjoin(df1, df2, columns, prefixes)
-- view(result)


local df1 = {
    {bwd = "mTcCIR37_bwd", sequence = "NC_030859.1", fwd = "mTcCIR37_fwd", length = 289},
    {bwd = "mTcCIR61_fwd", sequence = "NC_030859.1", fwd = "mTcCIR61_bwd", length = 168},
    {bwd = "mTcCIR77_bwd", sequence = "NC_030859.1", fwd = "mTcCIR77_fwd", length = 276}
}

local df2 = {
    {bwd = "mTcCIR37_bwd", sequence = "NC_030859.1", fwd = "mTcCIR37_fwd", length = 289},
    {bwd = "mTcCIR61_fwd", sequence = "NC_030859.1", fwd = "mTcCIR61_bwd", length = 168},
    {bwd = "mTcCIR99_bwd", sequence = "NC_030859.1", fwd = "mTcCIR99_fwd", length = 300}
}

local expected = {
    {bwd = "mTcCIR37_bwd", sequence = "NC_030859.1", fwd = "mTcCIR37_fwd", df1_length = 289, df2_length = 289},
    {bwd = "mTcCIR61_fwd", sequence = "NC_030859.1", fwd = "mTcCIR61_bwd", df1_length = 168, df2_length = 168}
}

local result = innerjoin(df1, df2, {"bwd", "sequence", "fwd"})

view(result)