---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by glastis.
--- DateTime: 28-Nov-22 22:22
---

local args = {...}

local output_filename = 'trace.log'

local function remove_file(filename)
    fs.delete(filename)
end

local function overwrite_logs(message, filename)
    local file

    remove_file(filename)
    file = io.open(filename, 'w')
    file:write(message)
    file:close()
end

local function main(args_table)
    local success
    local error_message

    success, error_message = pcall(shell.run, unpack(args_table))
    if not success then
        overwrite_logs(error_message, output_filename)
    end
end

main(pack(args))