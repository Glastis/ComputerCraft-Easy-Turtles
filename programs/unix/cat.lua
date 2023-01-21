package.path = package.path .. ';/ComputerCraft/common/?.lua'

local file = require 'file'

local args = {...}

local function check_args()
    if #args == 0 then
        print('Usage: cat <file1> [<file2> ... <fileN>]')
        return false
    end
    return true
end

local function check_if_files_exists(path_list)
    local i
    local success

    i = 1
    success = true
    while i <= #path_list do
        if not file.exists(path_list[i]) then
            print('Error: cat: file "' .. path_list[i] .. '" does not exist')
            success = false
        end
        i = i + 1
    end
    return success
end

local function cat_files(path_list)
    local i
    local str

    i = 1
    while i <= #path_list do
        str = file.read(path_list[i])
        if str then
            print(str)
        end
        i = i + 1
    end
end

local function main(path_list)
    if not check_args() then
        return
    end
    if not check_if_files_exists(path_list) then
        return
    end
    cat_files(path_list)
end

main(args)