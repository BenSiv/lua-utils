require("utils").using("utils")
local sqlite = require("sqlite3")
local readdlm = require("delimited_files").readdlm

-- Define a module table
local database = {}

local function local_query(db_path, query)
    local db = sqlite.open(db_path)
    if not db then
        print("Error opening database")
        return nil
    end

    query = unescape_string(query)
    local result_rows = {}
    for row in db:rows(query) do
        table.insert(result_rows, row)
    end

    db:close()
    return result_rows
end

local function local_update(db_path, statement)
    local db = sqlite.open(db_path)

    if not db then
        print("Error opening database")
        return nil
    end
    
    statement = unescape_string(statement)
    local _, err = db:exec(statement)
    if err then
        print("Error: " .. err)
    end

    db:close()
end

local function import_delimited(db_path, file_path, table_name, delimiter)    
    local db = sqlite.open(db_path)
    if not db then
        print("Error opening database")
        return nil
    end

    local content = readdlm(file_path, delimiter, true)
    local col_names = keys(content[1])
    local col_row = table.concat(col_names, "', '")
    local insert_statement = string.format("INSERT INTO %s ('%s') VALUES ", table_name, col_row)
    value_rows = {}
    local row_values
    for _, row in pairs(content) do
        row_values = string.format("('%s')", table.concat(values(row), "', '"))
        table.insert(value_rows, row_values)
    end
    insert_statement = insert_statement .. table.concat(value_rows, ", ") .. ";"

    local _, err = db:exec(insert_statement)
    if err then
        print("Error: " .. err)
    end

    db:close()
end

database.local_query = local_query
database.local_update = local_update
database.import_delimited = import_delimited

-- Export the module
return database