
require("utils").using("utils")

-- Test the replace function

function test_replace()
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
end

-- test_replace()

function test_merge_sort_with_indices()
    unsorted_array = {5, 3, 8, 1, 2, 7, 4, 6}
    show(merge_sort_with_indices(unsorted_array))
end

-- test_merge_sort_with_indices()

function test_unique()
    show(unique({"a","b","a","c"}))
end

-- test_unique()

function test_is_array()
    print(is_array({"a","b","c"}))

    print(is_array({a="aabba",b="babba",c="cabba"}))

    print(is_array({}))
end

-- test_is_array()


show(user_defined_globals())
