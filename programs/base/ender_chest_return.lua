package.path = package.path .. ';/ComputerCraft/*/?.lua'
package.path = package.path .. ';/ComputerCraft/common/?.lua'

local container = require "common.container"

local PERIPHERAL_NAMES = {}
local routes = {}

local MAIN_LOOP_DELAY = 10

local function init()
    local prefixes = {}
    prefixes.chest = 'minecraft:chest_'
    prefixes.ender_chest = 'enderstorage:ender_chest_'

    PERIPHERAL_NAMES.chests = {}
    PERIPHERAL_NAMES.chests[#PERIPHERAL_NAMES.chests+1] = prefixes.chest .. '7'
    PERIPHERAL_NAMES.chests[#PERIPHERAL_NAMES.chests+1] = prefixes.chest .. '8'
    PERIPHERAL_NAMES.chests[#PERIPHERAL_NAMES.chests+1] = prefixes.chest .. '9'
    PERIPHERAL_NAMES.chests[#PERIPHERAL_NAMES.chests+1] = prefixes.chest .. '10'
    PERIPHERAL_NAMES.chests[#PERIPHERAL_NAMES.chests+1] = prefixes.chest .. '11'
    PERIPHERAL_NAMES.chests[#PERIPHERAL_NAMES.chests+1] = prefixes.chest .. '12'
    PERIPHERAL_NAMES.chests[#PERIPHERAL_NAMES.chests+1] = prefixes.chest .. '13'
    PERIPHERAL_NAMES.chests[#PERIPHERAL_NAMES.chests+1] = prefixes.chest .. '14'
    PERIPHERAL_NAMES.chests[#PERIPHERAL_NAMES.chests+1] = prefixes.chest .. '15'

    PERIPHERAL_NAMES.ender_chest = prefixes.ender_chest .. '0'

    for i = 1, #PERIPHERAL_NAMES.chests do
        routes[#routes+1] = {from = PERIPHERAL_NAMES.ender_chest, to = PERIPHERAL_NAMES.chests[i]}
    end

end

local function route_item(from, to)
    print('Routing from ' .. string.match(from, '_(.*)') .. ' to ' .. string.match(to, '_(.*)'))
    return container.transfer_item(from, to)
end

local function main()
    local i
    local transfered_count

    init()
    while true do
        i = 1
        transfered_count = 1
        while transfered_count > 0 do
            transfered_count = route_item(routes[i % #routes + 1].from, routes[i % #routes + 1].to)
            i = i + 1
            if i % 200 == 0 then
                print('Waiting for ' .. MAIN_LOOP_DELAY .. ' seconds')
                sleep(MAIN_LOOP_DELAY)
            end
        end
        print('Waiting for ' .. MAIN_LOOP_DELAY .. ' seconds')
        sleep(MAIN_LOOP_DELAY)
    end
end

main()