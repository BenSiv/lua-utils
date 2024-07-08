-- Define a module table
local paths = {}

local function get_parent_dir(path)
    path = path:gsub("[\\/]+$", "")
    local parent_dir = path:match("(.*/)")
    return parent_dir
end

local function get_script_path()
    local script_path = debug.getinfo(1, "S").source:sub(2)
    return script_path
end

local function get_script_dir()
    local script_path = get_script_path()
    local script_dir = get_parent_dir(script_path)
    return script_dir
end

paths.get_parent_dir = get_parent_dir
paths.get_script_path = get_script_path
paths.get_script_dir = get_script_dir

-- Export the module
return paths
