require("utils").using("utils")

-- Define a module table
local graphs = {}

-- switch keys and values
local function reverse_kv(tbl)
    local reversed = {}
    for k, v in pairs(tbl) do
       reversed[v] = k
    end
    return reversed
end

-- Function to get or create an index for a given name
local function get_or_create_index(name, node_map)
    index_map = reverse_kv(node_map)
    local node_index
    if not index_map[name] then
        node_index = length(node_map) + 1
        node_map[node_index] = name
    else
        node_index = index_map[name]
    end
    return node_index, node_map
end

-- Build the graph as an adjacency list while also returning a node-map {index = name}
local function build_graph(data)
    local graph = {}
    local node_map = {}
    local source_index
    local name_index

    for _, entry in ipairs(data) do
        source_index, node_map = get_or_create_index(entry.source, node_map)
        name_index, node_map = get_or_create_index(entry.name, node_map)

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
  
    local function dfs(node)
        visited[node] = true
    
        if graph[node] then
            for i, neighbor in pairs(graph[node]) do
                if not visited[neighbor] then
                    children_indices[i] = neighbor
                    dfs(neighbor)
                end
            end
        end
    end
  
    local start_node = get_or_create_index(node_name, node_map)
    dfs(start_node)
    
    local children = {}
    for _, index in pairs(children_indices) do
        children[index] = node_map[index]
    end

    return children
end

-- Function to find all parents of a specific node
local function get_all_parents(graph, node_map, node_name)
    local visited = {}
    local parents_indices = {}
  
    local function dfs(node)
        visited[node] = true
        local neighbor = node_map[node]
        if neighbor then
            if not visited[neighbor] then
                parents_indices[neighbor] = node
                dfs(neighbor)
            end
        end
    end
  
    local target_node = get_or_create_index(node_name, node_map)
    dfs(target_node)
    
    local parents = {}
    for _, index in pairs(parents_indices) do
        parents[index] = node_map[index]
    end

    return parents
end


graphs.build_graph = build_graph
graphs.get_all_children = get_all_children
graphs.get_all_parents = get_all_parents

-- Export the module
return graphs