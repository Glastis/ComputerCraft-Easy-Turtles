package.path = package.path .. ';/ComputerCraft/common/?.lua'

local file = require 'file'

local args = {...}

local function check_args()
    if #args == 0 then
        print('Usage: touch <file1> [<file2> ... <fileN>]')
        return false
    end
    return true
end

local function main(args)
    local i

    i = 1
    if not check_args() then
        return
    end
    while i <= #args do
        file.write(args[i], '')
        i = i + 1
    end
end

main(args)