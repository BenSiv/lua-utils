-- graphs.lua
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

-- Get or create an index for a name
local function get_or_create_index(name, node_map)
    local index_map = reverse_kv(node_map)
    local node_index = index_map[name]
    if not node_index then
        node_index = #node_map + 1
        node_map[node_index] = name
    end
    return node_index
end

-- Get index of a node name
local function get_node_index(node_map, node_name)
    for index, name in pairs(node_map) do
        if name == node_name then return index end
    end
    return nil
end

-- Build a DAG as adjacency list
local function build_graph(data)
    local graph = {}
    local node_map = {}
    for _, entry in ipairs(data) do
        local src_idx = get_or_create_index(entry.source, node_map)
        local name_idx = get_or_create_index(entry.name, node_map)
        graph[src_idx] = graph[src_idx] or {}
        table.insert(graph[src_idx], name_idx)
    end
    return graph, node_map
end

-- Build reverse graph once for parent traversal
local function build_reverse_graph(graph)
    local reversed = {}
    for parent, children in pairs(graph) do
        for _, child in ipairs(children) do
            reversed[child] = reversed[child] or {}
            table.insert(reversed[child], parent)
        end
    end
    return reversed
end

-- Generic DFS traversal
local function traverse_graph(graph, start_node, reverse)
    local g = graph
    if reverse then g = build_reverse_graph(graph) end
    local visited = {}
    local result = {}

    local function dfs(curr)
        if visited[curr] then return end
        visited[curr] = true
        if g[curr] then
            for _, neighbor in ipairs(g[curr]) do
                if not visited[neighbor] then
                    table.insert(result, neighbor)
                    dfs(neighbor)
                end
            end
        end
    end

    dfs(start_node)
    return result
end

-- Get all children
local function get_all_children(graph, node_map, node_name)
    local idx = get_node_index(node_map, node_name)
    if not idx then return {} end
    local indices = traverse_graph(graph, idx, false)
    local children = {}
    for _, i in ipairs(indices) do table.insert(children, node_map[i]) end
    return children
end

-- Get all parents
local function get_all_parents(graph, node_map, node_name)
    local idx = get_node_index(node_map, node_name)
    if not idx then return {} end
    local indices = traverse_graph(graph, idx, true)
    local parents = {}
    for _, i in ipairs(indices) do table.insert(parents, node_map[i]) end
    return parents
end

-- Get leaves (nodes with no outgoing edges)
local function get_leaves(graph, node_map)
    local has_outgoing = {}
    for node, edges in pairs(graph) do
        has_outgoing[node] = true
    end
    local leaves = {}
    for idx, name in pairs(node_map) do
        if not has_outgoing[idx] then table.insert(leaves, name) end
    end
    return leaves
end

-- Get roots (nodes with no parents)
local function get_roots(graph, node_map)
    local reversed = build_reverse_graph(graph)
    local roots = {}
    for idx, name in pairs(node_map) do
        if not reversed[idx] or #reversed[idx] == 0 then table.insert(roots, name) end
    end
    return roots
end

-- Get connected components
local function get_all_components(graph, node_map)
    local visited = {}
    local components = {}
    local function dfs(node, comp)
        if visited[node] then return end
        visited[node] = true
        table.insert(comp, node_map[node])
        if graph[node] then
            for _, n in ipairs(graph[node]) do dfs(n, comp) end
        end
    end
    for idx, _ in pairs(node_map) do
        if not visited[idx] then
            local comp = {}
            dfs(idx, comp)
            table.insert(components, comp)
        end
    end
    return components
end

-- Get lineage depth
local function get_lineage_depth(graph, node_map, sample_name)
    local node_idx = get_node_index(node_map, sample_name)
    if not node_idx then return nil end
    local reversed = build_reverse_graph(graph)

    local function depth(curr, visited)
        visited = visited or {}
        if visited[curr] then return 0 end
        visited[curr] = true
        local parents = reversed[curr] or {}
        if #parents == 0 then return -1 end
        local max_depth = -math.huge
        for _, p in ipairs(parents) do
            local d = depth(p, visited)
            if d > max_depth then max_depth = d end
        end
        return max_depth + 1
    end

    return depth(node_idx)
end

-- Exports
graphs.build_graph = build_graph
graphs.get_all_children = get_all_children
graphs.get_all_parents = get_all_parents
graphs.get_leaves = get_leaves
graphs.get_roots = get_roots
graphs.get_node_index = get_node_index
graphs.get_all_components = get_all_components
graphs.get_lineage_depth = get_lineage_depth

return graphs
