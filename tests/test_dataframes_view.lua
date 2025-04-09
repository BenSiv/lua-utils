require("utils").using("utils")
using("dataframes")

local data = {
    {id = 1, name = "Alice", age = 30},
    {id = 2, name = "Bob", age = 25},
    {id = 3, name = "Charlie", age = 35}
}

print("\nAll Data:")
view(data)

print("\nSubset Data:")
view(data, {columns={"name", "age"}})
