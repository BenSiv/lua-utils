
require("utils").using("utils")

-- Test the replace function
local input_table = {
    "test",
    123,
    true,
    nil,
    {1, 2, 3},
    {a = "apple", b = "banana", c = "cherry"}
}

local old_value = 123
local new_value = "replaced"

local output_table = replace(input_table, old_value, new_value)

unsorted_array = {5, 3, 8, 1, 2, 7, 4, 6}
show(merge_sort_with_indices(unsorted_array))

show(unique({"a","b","a","c"}))

