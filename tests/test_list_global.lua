local user_defined_globals = require("utils").user_defined_globals
local show = require("utils").show

-- Add some new globals
a = 5

function test_main()
    -- do nothing
end

b = {}

-- Show only the new globals
show(user_defined_globals())
