
require("utils").using("utils")
using("dataframes")

-- Testing is_dataframe function
local test_data1 = {
    {name = "Alice", age = 25},
    {name = "Bob", age = 30},
    {name = "Charlie", age = 22}
}

local test_data1 = {
    {name = "Alice", age = 25, date = "24.05.2023"},
    {name = "Bob", age = 30},
    {name = "Charlie", age = 22}
}

local test_data2 = {
    {name = "Dave", age = 28},
    {name = "Eva", age = 35},
    {name = "Frank"}
}

local is_dataframe_pass = is_dataframe(test_data1) and not is_dataframe(test_data2)
print("is_dataframe pass? ", is_dataframe_pass)

-- Testing view function
print("view Test:")
view(test_data1)
print()

-- Testing transpose function
local transposed_data = transpose(test_data1)
print("transpose Test:")
show(transposed_data)
print()


test_data1 = {
    {name = "Alice", content = "this is a long note content written to test the view function of a dataframe", content2 = "here is another content piece"},
    {name = "Bob", content = "30", content2 = "what happend if this part is too long to fit the screen size of the terminal?"},
    {name = "Charlie", content = "22", content2 = "here is another content piece"}
}