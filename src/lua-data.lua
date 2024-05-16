-- Helper function to serialize table to string
function serialize(tbl)
    local str = "{"
    for k, v in pairs(tbl) do
        if type(k) == "number" then
            str = str .. "[" .. k .. "]=" 
        else
            str = str .. k .. "="
        end

        if type(v) == "table" then
            str = str .. serialize(v) .. ","
        elseif type(v) == "string" then
            str = str .. '"' .. v .. '",'
        else
            str = str .. tostring(v) .. ","
        end
    end
    str = str .. "}"
    return str
end

-- Function to save a Lua table to a file
function save_Table(filename, tbl)
    local file = io.open(filename, "w")
    if file then
        file:write("return ")
        file:write(serialize(tbl))
        file:close()
    else
        print("Error: Unable to open file for writing")
    end
end

-- Function to load a Lua table from a file
function load_table(filename)
    local chunk, err = loadfile(filename)
    if chunk then
        return chunk()
    else
        print("Error loading file: " .. err)
        return nil
    end
end