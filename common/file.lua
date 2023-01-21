--
-- User: Glastis
-- Date: 21/11/2017
-- Time: 06:47
--

local file = {}

--- Return true if file exists, false otherwise.
-- @string filepath Path to file, eg: /home/glastis/foo.txt
local function exists(filepath)
    local f

    f = io.open(filepath,"r")
    if f then
        io.close(f)
        return true
    end
    return false
end
file.exists = exists

--- Read and return all file content
-- @string filepath Path to file, eg: /home/glastis/foo.txt
local function read(filepath)
    local f
    local str

    f = io.open(filepath, 'rb')
    if not f then
        return nil
    end
    str = f:read('*all')
    f:close()
    return str
end
file.read = read

--- Write and string in file
-- @string filepath Path to the file, eg: /home/glastis/foo.txt
-- @string str Content to write
-- @string mode File open mode, "a" to append, "w" to overwrite file or "w+" to delete and write to file. Default is "a".
local function write(filepath, str, mode)
    local f

    if not mode then
        mode = "a"
    end
    f = io.open(filepath, mode)
    f:write(str)
    f:close()
end
file.write = write

--- Read and return one line from a file
-- @string filepath path to file, eg: /home/glastis/foo.txt
-- @file if nil, a new file will be opened with the provided filepath.
local function read_line(filepath, file)
    local line

    if not file then
        file = io.open(filepath, 'rb')
    end
    line = file:read()
    if line then
        return file, line
    end
    file:close()
    return nil
end
file.read_line = read_line

--- Create a new empty file. Have no effect if the file already exists.
-- @string filepath Path to the file, eg: /home/glastis/foo.txt
local function create(filepath)
    write(filepath, "", "w")
end
file.create = create

return file