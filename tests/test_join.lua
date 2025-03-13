require("utils").using("utils")
using("dataframes")

-- Example usage
local df1 = {
    {id = 1, name = "Alice", age = 25, hight = 1.6},
    {id = 2, name = "Bob", age = 30, hight = 1.8},
    {id = 3, name = "Charlie", age = 35, hight = 1.7},
}

view(df1)

local df2 = {
    {id = 1, name = "Alicia", location = "NYC", hight = 1.6},
    {id = 2, name = "Bobby", location = "LA", hight = 1.8},
    {id = 4, name = "Dave", location = "Chicago", hight = 1.7},
}
view(df2)

local columns = {"id", "hight"}
local prefixes = {"df1", "df2"}

local result = innerjoin(df1, df2, columns, prefixes)

-- View the result
view(result)