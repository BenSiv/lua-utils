require("utils").using("utils")

-- Define a module table
local graphs = {}

-- Switch keys and values
local function reverse_kv(tbl)
    if type(tbl) ~= "table" then
        print("Expected table, received " .. type(tbl))
        return {}
    end

    local reversed = {}
    for k, v in pairs(tbl) do
        reversed[v] = k
    end
    return reversed
end

-- Function to get or create an index for a given name
local function get_or_create_index(name, node_map)
    local index_map = reverse_kv(node_map)  -- Reverse lookup for names
    local node_index = index_map[name]

    if not node_index then
        node_index = #node_map + 1  -- Assign a new index
        node_map[node_index] = name
    end
    return node_index
end

-- Build the graph as an adjacency list while also returning a node-map {index = name}
local function build_graph(data)
    local graph = {}
    local node_map = {}

    for _, entry in ipairs(data) do
        local source_index = get_or_create_index(entry.source, node_map)
        local name_index = get_or_create_index(entry.name, node_map)

        if not graph[source_index] then
            graph[source_index] = {}
        end
        table.insert(graph[source_index], name_index)
    end

    return graph, node_map
end

-- Function to find all children of a specific node
local function get_all_children(graph, node_map, node_name)
    local visited = {}
    local children_indices = {}
    local node = get_or_create_index(node_name, node_map)

    local function dfs(curr_node)
        if visited[curr_node] then return end
        visited[curr_node] = true

        if graph[curr_node] then
            for _, neighbor in ipairs(graph[curr_node]) do
                if not visited[neighbor] then
                    table.insert(children_indices, neighbor)
                    dfs(neighbor)
                end
            end
        end
    end

    dfs(node)

    -- Convert indices back to names
    local children = {}
    for _, index in ipairs(children_indices) do
        table.insert(children, node_map[index])
    end

    return children
end

-- Function to build a reverse adjacency list for quick parent lookup
local function build_reverse_graph(graph)
    if type(graph) ~= "table" then
        print("Expected table, received " .. type(graph))
        return
    end
    local reversed_graph = {}
    for parent, children in pairs(graph) do
        for _, child in ipairs(children) do
            if not reversed_graph[child] then
                reversed_graph[child] = {}
            end
            table.insert(reversed_graph[child], parent)  -- Preserve order
        end
    end
    return reversed_graph
end

-- Function to find all parents of a specific node
local function get_all_parents(graph, node_map, node_name)
    local visited = {}
    local parents_indices = {}
    local node = get_or_create_index(node_name, node_map)

    -- Reverse graph
    local reversed_graph = build_reverse_graph(graph)
    for parent, children in pairs(graph) do
        for _, child in ipairs(children) do
            if not reversed_graph[child] then
                reversed_graph[child] = {}
            end
            table.insert(reversed_graph[child], parent)
        end
    end

    local function dfs(curr_node)
        if visited[curr_node] then return end
        visited[curr_node] = true

        if reversed_graph[curr_node] then
            for _, parent in ipairs(reversed_graph[curr_node]) do
                if not visited[parent] then
                    table.insert(parents_indices, parent)
                    dfs(parent)
                end
            end
        end
    end

    dfs(node)

    -- Convert indices back to names
    local parents = {}
    for _, index in ipairs(parents_indices) do
        table.insert(parents, node_map[index])
    end

    return parents
end

-- Function to find all leaf nodes (nodes with no outgoing edges)
local function get_leaves(graph, node_map)
    local has_outgoing = {}
    local all_nodes = {}

    -- Mark nodes that have outgoing edges
    for node, edges in pairs(graph) do
        has_outgoing[node] = true
        for _, child in ipairs(edges) do
            all_nodes[child] = true
        end
    end

    -- Any node that is in node_map but not in has_outgoing is a leaf
    local leaves = {}
    for index, name in pairs(node_map) do
        if not has_outgoing[index] then
            table.insert(leaves, name)
        end
    end

    return leaves
end

function get_roots(graph, node_map)
    local reversed_graph = build_reverse_graph(graph)
    if not reversed_graph then
        return 
    end
    local roots = {}

    for node, _ in pairs(node_map) do
        if not reversed_graph[node] or next(reversed_graph[node]) == nil then
            table.insert(roots, node_map[node])
        end
    end

    return roots
end

-- Function to get the index of a node name
local function get_node_index(node_map, node_name)
    for index, name in pairs(node_map) do
        if name == node_name then
            return index
        end
    end
    return nil
end

-- Export module functions
graphs.build_graph = build_graph
graphs.get_all_children = get_all_children
graphs.get_all_parents = get_all_parents
graphs.get_leaves = get_leaves
graphs.get_roots = get_roots
graphs.get_node_index = get_node_index

return graphs
