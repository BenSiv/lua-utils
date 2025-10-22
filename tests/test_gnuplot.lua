local gp = require("gnuplot")

local plot_obj = gp.create(plot_cfg)
gp.savefig(plot_obj, "/root/monthly_rate.png")

-- === Test ===
-- local x = {1, 2, 3, 4, 5}
-- local y = {10, 20, 30, 40, 50}

-- local fname = array_to_file({x, y})
-- print("Temp file created:", fname)

-- -- print file content for verification
-- local f = assert(io.open(fname, "r"))
-- print("File content:")
-- for line in f:lines() do
--     print(line)
-- end
-- f:close()


local dates = {"2025-10-20", "2025-10-21", "2025-10-22"}
local values = {1.2, 3.4, 2.8}

local plot = gp.create({
    data = {
        {
            {
                dates,
                values
            },
            using={1,2},
            with="linespoints",
            title="Measurements"
        }
    },
    title = "Time Series Example",
    xlabel = "Date",
    ylabel = "Value",
    width = 800,
    height = 400,
    xformat = "%Y-%m-%d",
    grid = true,
    xtics = "rotate by -45"
})

gp.savefig(plot, "time_series.png")

