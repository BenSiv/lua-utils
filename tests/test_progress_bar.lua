require("utils").using("utils")

local total = 100
for i = 1, total do
    draw_progress(i, total)
    os.execute("sleep 0.05") -- Simulate work
end
print("\nDone!")
