local list_globals = require("utils").list_globals
local show = require("utils").show

a = 5

function test_main()
	-- do nothing
end

b = {}

show(list_globals())
