require("utils").using("utils")
using("delimited_files")
using("dataframes")
local sqlite = require("sqlite3")

-- Define a module table
local database = {}

local function local_query(db_path, query)
    local db = sqlite.open(db_path)
    if not db then
        print("Error opening database")
        return nil
    end

    query = unescape_string(query)
    local stmt, err = db:prepare(query)
    if not stmt then
        db:close()
        print("Invalid query: " .. err)
        return nil, "Invalid query: " .. err
    end

    local result_rows = {}
    local column_names = {}

    for row in stmt:rows() do
        table.insert(result_rows, row)
        for col_name, _ in pairs(row) do
        	table.insert(column_names, col_name)
        end
    end

    db:close()

    if length(result_rows) == 0 then
        print("Query executed successfully, but no rows were returned.")
        return nil
    end

    for _, row in ipairs(result_rows) do
        for _, col_name in ipairs(column_names) do
            if row[col_name] == nil then
                row[col_name] = ""
            end
        end
    end

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
        return nil
    end

    db:close()
    return true
end

local function get_sql_values(row, col_names)
	local value
	local sql_values = {}
	for _, col in pairs(col_names) do
		value = row[col]
		if value and value ~= "" then
			table.insert(sql_values, string.format("'%s'", value))
		else
			table.insert(sql_values, "NULL")
		end
	end
	return sql_values
end

local function import_delimited(db_path, file_path, table_name, delimiter)    
    local db = sqlite.open(db_path)
    if not db then
        print("Error opening database")
        return nil
    end

    local content = readdlm(file_path, delimiter, true)
    if not content then
        print("Error reading delimited file")
        return nil
    end
    
    local col_names = keys(content[1]) -- problematic if first row does not have all the columns
    local col_row = table.concat(col_names, "', '")
    local insert_statement = string.format("INSERT INTO %s ('%s') VALUES ", table_name, col_row)

    local value_rows = {}
    for _, row in pairs(content) do
    	local sql_values = get_sql_values(row, col_names)
        local row_values = string.format("(%s)", table.concat(sql_values, ", "))
        table.insert(value_rows, row_values)
    end
    insert_statement = insert_statement .. table.concat(value_rows, ", ") .. ";"

    local _, err = db:exec(insert_statement)
    if err then
        print("Error: " .. err)
        return nil
    end

    db:close()
    return true
end

local function export_delimited(db_path, query, file_path, delimiter, header)
    local results = local_query(db_path, query)

    if not results then
    	print("Failed query")
    	return nil
    end
    
   	if length(results) == 0 then
        print("No data found")
        return nil
    end

    writedlm(file_path, delimiter, results, header)
    return true
end

local function load_df(db_path, table_name, dataframe)
    -- Check if the provided dataframe is valid
    if not is_dataframe(dataframe) then
        error("The provided table is not a valid dataframe.")
    end

    -- Get the columns from the dataframe
    local columns = get_columns(dataframe)
    
    -- Open the SQLite database
    local db = sqlite.open(db_path)
    if not db then
        print("Error opening database")
        return nil
    end

    -- Prepare column names for the insert statement
    local col_row = table.concat(columns, "', '")
    local insert_statement = string.format("INSERT INTO %s ('%s') VALUES ", table_name, col_row)

    -- Prepare the data rows for insertion
    local value_rows = {}
    for _, row in ipairs(dataframe) do
        local sql_values = {}
        -- Get values for each column in the row
        for _, col_name in ipairs(columns) do
            local value = row[col_name]
            if value and value ~= "" then
                table.insert(sql_values, string.format("'%s'", value))
            else
                table.insert(sql_values, "NULL")
            end
        end
        -- Format the row values
        local row_values = string.format("(%s)", table.concat(sql_values, ", "))
        table.insert(value_rows, row_values)
    end

    -- Complete the insert statement
    insert_statement = insert_statement .. table.concat(value_rows, ", ") .. ";"

    -- Execute the insert statement
    local _, err = db:exec(insert_statement)
    if err then
        print("Error: " .. err)
        db:close()
        return nil
    end

    -- Close the database connection
    db:close()
    return true
end

database.local_query = local_query
database.local_update = local_update
database.import_delimited = import_delimited
database.export_delimited = export_delimited
database.load_df = load_df

-- Export the module
return database
