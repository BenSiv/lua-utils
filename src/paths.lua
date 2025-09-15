-- Define a module table
local paths = {}

local function get_parent_dir(path)
    path = path:gsub("[\\/]+$", "")
    local parent_dir = path:match("(.*/)")
    return parent_dir
end

local function remove_trailing_slash(path)
    -- Remove the trailing slash if it exists
    return path:gsub("[\\/]+$", "")
end

local function get_file_name(path)
    return path:match("([^\\/]+)$")
end

local function get_dir_name(path)
	path = "/" .. path
	local dir_name
	local file_name = get_file_name(path)
	if file_name then
		dir_name = path:match(".*/([^/]*)/[^/]+$")
	else
		path = remove_trailing_slash(path)
		dir_name = get_file_name(path)
	end
	return dir_name
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

-- Function to join paths
local function joinpath(...)
    local parts = {...}
    local separator = package.config:sub(1,1)

    local joined_path = table.concat(parts, separator)

    if separator == '\\' then
        joined_path = joined_path:gsub('[\\/]+', '\\')
    else
        joined_path = joined_path:gsub('[\\/]+', '/')
    end

    return joined_path
end

-- Function to add relative path to package.path
-- local function add_to_path(script_path, relative_path)
--     local script_dir = get_parent_dir(script_path)
--     path_to_add = joinpath(script_dir, relative_path, "?.lua;")
--     package.path = path_to_add .. package.path
-- end

-- Function to add absolute path to package.path
local function add_to_path(path)
    path_to_add = joinpath(path, "?.lua;")
    package.path = path_to_add .. package.path
end

local function file_exists(path)
	local answer = false
	local file = io.open(path, "r")
	if file then
		answer = true
		file:close()
	end
	return answer
end

local function create_dir_if_not_exists(path)
	local dir_path = joinpath(path)
	-- Check if the directory exists
	local attr = lfs.attributes(path)
	if not attr then
	    -- Directory does not exist; create it
	    local success, err = lfs.mkdir(path)
	    if not success then
	        print("Error creating directory:", err)
	        return 
	    end
	end
	return true
end

local function create_file_if_not_exists(path)
	-- Check if the file exists
	local file = io.open(path, "r")
	if not file then
	    -- File does not exist; create it
	    file, err = io.open(path, "w")
	    if not file then
	        print("Error creating file:", err)
	        return
	    else
	        file:close()  -- Close the file after creating it
	    end
	end
	return true
end

paths.get_parent_dir = get_parent_dir
paths.get_file_name = get_file_name
paths.get_dir_name = get_dir_name
paths.get_script_path = get_script_path
paths.get_script_dir = get_script_dir
paths.joinpath = joinpath
paths.add_to_path = add_to_path
paths.file_exists = file_exists
paths.create_dir_if_not_exists = create_dir_if_not_exists
paths.create_file_if_not_exists = create_file_if_not_exists

-- Export the module
return paths
