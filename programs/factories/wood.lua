package.path = package.path .. ';/ComputerCraft/*/?.lua'
package.path = package.path .. ';/ComputerCraft/common/?.lua'

local container = require "common.container"

local PERIPHERAL_NAMES = {}
local ITEM_NAMES = {}
local routes = {}

local TRASH_PULSE_DELAY = 0.2
local MAIN_LOOP_DELAY = 20

local function init()
    local prefixes = {}
    prefixes.redstone = 'redstoneIntegrator_'
    prefixes.barrel = 'minecraft:barrel_'
    prefixes.dropper = 'minecraft:dropper_'

    PERIPHERAL_NAMES.redstone = prefixes.redstone .. '1'
    PERIPHERAL_NAMES.dropper =  prefixes.dropper .. '0'
    PERIPHERAL_NAMES.oak_raw = prefixes.barrel .. '7'
    PERIPHERAL_NAMES.spruce_raw = prefixes.barrel .. '8'
    PERIPHERAL_NAMES.birch_raw = prefixes.barrel .. '9'
    PERIPHERAL_NAMES.oak_logs = prefixes.barrel .. '6'
    PERIPHERAL_NAMES.oak_saplings = prefixes.barrel .. '5'
    PERIPHERAL_NAMES.spruce_logs = prefixes.barrel .. '4'
    PERIPHERAL_NAMES.spruce_saplings = prefixes.barrel .. '3'
    PERIPHERAL_NAMES.birch_logs = prefixes.barrel .. '2'
    PERIPHERAL_NAMES.birch_saplings = prefixes.barrel .. '1'
    PERIPHERAL_NAMES.apple = prefixes.barrel .. '0'

    ITEM_NAMES.oak_log = 'minecraft:oak_log'
    ITEM_NAMES.spruce_log = 'minecraft:spruce_log'
    ITEM_NAMES.birch_log = 'minecraft:birch_log'
    ITEM_NAMES.oak_sapling = 'minecraft:oak_sapling'
    ITEM_NAMES.spruce_sapling = 'minecraft:spruce_sapling'
    ITEM_NAMES.birch_sapling = 'minecraft:birch_sapling'
    ITEM_NAMES.stick = 'minecraft:stick'
    ITEM_NAMES.apple = 'minecraft:apple'

    routes[#routes+1] = {from = PERIPHERAL_NAMES.oak_raw, to = PERIPHERAL_NAMES.oak_logs, item = ITEM_NAMES.oak_log}
    routes[#routes+1] = {from = PERIPHERAL_NAMES.spruce_raw, to = PERIPHERAL_NAMES.spruce_logs, item = ITEM_NAMES.spruce_log}
    routes[#routes+1] = {from = PERIPHERAL_NAMES.birch_raw, to = PERIPHERAL_NAMES.birch_logs, item = ITEM_NAMES.birch_log}
    routes[#routes+1] = {from = PERIPHERAL_NAMES.oak_raw, to = PERIPHERAL_NAMES.oak_saplings, item = ITEM_NAMES.oak_sapling}
    routes[#routes+1] = {from = PERIPHERAL_NAMES.spruce_raw, to = PERIPHERAL_NAMES.spruce_saplings, item = ITEM_NAMES.spruce_sapling}
    routes[#routes+1] = {from = PERIPHERAL_NAMES.birch_raw, to = PERIPHERAL_NAMES.birch_saplings, item = ITEM_NAMES.birch_sapling}
    routes[#routes+1] = {from = PERIPHERAL_NAMES.oak_raw, to = PERIPHERAL_NAMES.apple, item = ITEM_NAMES.apple}
    
    routes[#routes+1] = {from = PERIPHERAL_NAMES.oak_raw, to = PERIPHERAL_NAMES.spruce_saplings, item = ITEM_NAMES.spruce_sapling}
    routes[#routes+1] = {from = PERIPHERAL_NAMES.spruce_raw, to = PERIPHERAL_NAMES.oak_saplings, item = ITEM_NAMES.oak_sapling}
    routes[#routes+1] = {from = PERIPHERAL_NAMES.spruce_raw, to = PERIPHERAL_NAMES.birch_saplings, item = ITEM_NAMES.birch_sapling}
    routes[#routes+1] = {from = PERIPHERAL_NAMES.birch_raw, to = PERIPHERAL_NAMES.spruce_saplings, item = ITEM_NAMES.spruce_sapling}

end

local function redstone_pulse(count, delay)
    local red_peripheral

    red_peripheral = peripheral.wrap(PERIPHERAL_NAMES.redstone)
    while count > 0 do
        red_peripheral.setOutput('back', true)
        sleep(delay)
        red_peripheral.setOutput('back', false)
        sleep(delay)
        count = count - 1
    end
end

local function trash_all(peripheral_from, item_name)
    local i

    i = container.transfer_item(peripheral_from, PERIPHERAL_NAMES.dropper, item_name)
    while i > 0 do
        redstone_pulse(i, TRASH_PULSE_DELAY)
        i = container.transfer_item(peripheral_from, PERIPHERAL_NAMES.dropper, item_name)
    end
end

local function route_item(from, to, item_name)
    local transfered_count

    transfered_count = 1
    print('Routing ' .. string.match(item_name, ':(.*)') .. ' from ' .. string.match(from, '_(.*)') .. ' to ' .. string.match(to, '_(.*)'))
    while transfered_count > 0 do
        transfered_count = container.transfer_item(from, to, item_name)
    end
    if container.is_full(to) then
        trash_all(from, item_name)
    end
end

local function main()
    local i

    init()
    while true do
        i = 1
        while i <= #routes do
            route_item(routes[i].from, routes[i].to, routes[i].item)
            i = i + 1
        end
        trash_all(PERIPHERAL_NAMES.oak_raw, ITEM_NAMES.stick)
        trash_all(PERIPHERAL_NAMES.spruce_raw, ITEM_NAMES.stick)
        trash_all(PERIPHERAL_NAMES.birch_raw, ITEM_NAMES.stick)
        sleep(MAIN_LOOP_DELAY)
    end
end

main()