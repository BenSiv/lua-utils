package.path = package.path .. ";../src/?.lua"
local graphs = require("graphs")

-- Sample DAG
local data = {
    {source = "Root", name = "Culture1"},
    {source = "Culture1", name = "Subculture1"},
    {source = "Culture1", name = "Subculture2"},
    {source = "Root", name = "Culture2"},
    {source = "Culture2", name = "Subculture3"},
    {source = "Subculture3", name = "SubSub1"}
}

local graph, node_map = graphs.build_graph(data)

print("Nodes:")
for idx, name in pairs(node_map) do print(idx, name) end

print("\nRoots:", table.concat(graphs.get_roots(graph, node_map), ", "))
print("Leaves:", table.concat(graphs.get_leaves(graph, node_map), ", "))

print("\nChildren of Culture1:", table.concat(graphs.get_all_children(graph, node_map, "Culture1"), ", "))
print("Parents of SubSub1:", table.concat(graphs.get_all_parents(graph, node_map, "SubSub1"), ", "))

print("\nLineage depths:")
for _, name in ipairs({"Root", "Culture1", "Subculture1", "Subculture2", "Culture2", "Subculture3", "SubSub1"}) do
    print(name, graphs.get_lineage_depth(graph, node_map, name))
end

print("\nComponents:")
local components = graphs.get_all_components(graph, node_map)
for i, comp in ipairs(components) do
    print("Component " .. i .. ": " .. table.concat(comp, ", "))
end
