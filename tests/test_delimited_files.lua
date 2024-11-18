require("utils").using("utils")
using("dataframes")
using("delimited_files")

result = dlm_split("a b  c d", " ")
show(result)

data = readdlm("tests/data/tasks.tsv", "\t", true)
show(data)
