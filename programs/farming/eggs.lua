package.path = package.path .. ';/ComputerCraft/*/?.lua'
package.path = package.path .. ';/ComputerCraft/common/?.lua'

local container = require "common.container"
local inventory = require "common.inventory"
local sides = require 'sides'

local PERIPHERAL_NAMES = {}
local ITEM_NAMES = {}
local routes = {}

local MAIN_LOOP_DELAY = 30

local function init()
    local prefixes = {}
    prefixes.redstone = 'redstoneIntegrator_'
    prefixes.barrel = 'minecraft:barrel_'
    prefixes.dropper = 'minecraft:dropper_'
    prefixes.dispenser = 'minecraft:dispenser_'
    prefixes.turtle = 'turtle_'
    prefixes.generator = 'thermal:dynamo_stirling_'
    prefixes.dissolver = 'alchemistry:dissolver_block_entity_'
    prefixes.compactor = 'alchemistry:compactor_block_entity_'
    prefixes.extruder = 'thermal:device_rock_gen_'
    prefixes.pulverizer = 'thermal:machine_pulverizer_'

    PERIPHERAL_NAMES.redstone = prefixes.redstone .. '2'
    PERIPHERAL_NAMES.eggs_chest = prefixes.barrel .. '19'
    PERIPHERAL_NAMES.dispenser = prefixes.dispenser .. '0'

    routes[#routes+1] = {from = PERIPHERAL_NAMES.eggs_chest, to = PERIPHERAL_NAMES.dispenser}
end

local function route_item(from, to, item_name)
    local transfered_count

    transfered_count = 1
    if item_name then
        print('Routing ' .. string.match(item_name, ':(.*)') .. ' from ' .. string.match(from, '_(.*)') .. ' to ' .. string.match(to, '_(.*)'))
    else
        print('Routing all items from ' .. string.match(from, '_(.*)') .. ' to ' .. string.match(to, '_(.*)'))
    end
    while transfered_count > 0 do
        transfered_count = container.transfer_item(from, to, item_name)
    end
end

local function pulse_redstone(count, delay)
    local i
    local rs

    i = 0
    rs = peripheral.wrap(PERIPHERAL_NAMES.redstone)
    while i < count do
        rs.setOutput(sides.labels[sides.bottom], true)
        sleep(delay/2)
        rs.setOutput(sides.labels[sides.bottom], false)
        sleep(delay/2)
        i = i + 1
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
        pulse_redstone(64, 0.5)
        print('Waiting for ' .. MAIN_LOOP_DELAY .. ' seconds')
        sleep(MAIN_LOOP_DELAY)
    end
end

main()

