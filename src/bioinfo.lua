require("utils").using("utils")

-- Define a module table
local bioinfo = {}

local function read_fasta(filename)
    local sequences = {}
    local seq_id = nil
    local seq = {}

    for line in io.lines(filename) do
        if line:sub(1,1) == ">" then
            -- Save the previous sequence if it exists
            if seq_id then
                sequences[seq_id] = table.concat(seq)
            end
            -- Start a new sequence
            seq_id = line:sub(2):match("%S+")  -- Remove ">" and take first word as ID
            seq = {}  -- Reset sequence storage
        else
            table.insert(seq, line)
        end
    end

    -- Save the last sequence
    if seq_id then
        sequences[seq_id] = table.concat(seq)
    end

    return sequences
end

bioinfo.read_fasta = read_fasta

-- Export the module
return bioinfo