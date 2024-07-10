require("utils").using("utils")
local sqlite = require("sqlite3")

-- Define a module table
local database = {}

local function local_query(db_path, query)
    local db = sqlite.open(db_path)
    if not db then
        print("Error opening database")
        return nil
    end

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

    local _, err = db:exec(statement)
    if err then
        print("Error: " .. err)
    end

    db:close()
end

database.local_query = local_query
database.local_update = local_update

-- Export the module
return database