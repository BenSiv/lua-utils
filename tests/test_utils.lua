
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
