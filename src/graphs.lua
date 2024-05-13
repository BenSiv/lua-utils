require("utils").using("utils")

-- Define a module table
local graphs = {}

-- Translate node name to node index
local function get_or_create_index(name)
    if not name_to_index[name] then
        name_to_index[name] = next_index
        index_to_name[next_index] = name
        next_index = next_index + 1
    end
    return name_to_index[name]
end

-- Function to perform depth first search from a specific node
local function dfs(node_index, graph, visited)
    if visited[node_index] then return end
    visited[node_index] = true

    if graph[node_index] then
        for _, child_index in ipairs(graph[node_index]) do
            dfs(child_index, graph, visited)
        end
    end
end

-- Function to find all children of a specific node
local function find_children(node_index, graph)
    local children = {}
    local visited = {}

    dfs(node_index, graph, visited)

    for index, visited_node in pairs(visited) do
        if visited_node then
            table.insert(children, index)
        end
    end

    return children
end

graphs.get_or_create_index = get_or_create_index

-- Export the module
return graphs