require("utils").using("utils")
using("database")
using("dataframes")

db_path = "/root/documents/obsidian-work.db"
query = "select * from tasks"

local data = local_query(db_path, query)

-- need to be a valid dataframe
view(data)
-- show(data)