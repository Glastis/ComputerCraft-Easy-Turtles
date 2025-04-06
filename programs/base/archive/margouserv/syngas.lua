package.path = package.path .. ';/ComputerCraft/*/?.lua'
package.path = package.path .. ';/ComputerCraft/common/?.lua'

local container = require 'common.container'
local inventory = require 'common.inventory'
local sides = require 'common.sides'
local prefixes = require 'common.const.prefixes'

local peripheral_names = {}
local item_names = {}
local routes = {}

local REDSTONE_DETECTOR_SIDE = 'left'
local ITEM_MAX_COUNT = 5000

local function check_peripheral_connection()
    for _, name in pairs(peripheral_names) do
        if not peripheral.wrap(name) then
            print('Peripheral ' .. name .. ' not found')
            error()
        end
    end
end

local function init()
    peripheral_names.syngas_input = prefixes.advanced_generator_item_input .. '1'
    peripheral_names.ender_chest = prefixes.ender_chest .. '6'
    peripheral_names.turtle = prefixes.turtle .. '8'
    peripheral_names.inventory_connector = prefixes.inventory_connector .. '5'

    item_names.birch_log = prefixes.minecraft .. 'birch_log'
    check_peripheral_connection()
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

local function trash_item(name, count)
    local trashed_count

    print('Trashing ' .. count .. ' ' .. name)
    while count > 0 do
        trashed_count = container.transfer_item_to_turtle(peripheral_names.ender_chest, peripheral_names.turtle, name, count)
        if trashed_count == 0 then
            print('Failed to trash ' .. count .. ' ' .. name)
            return
        end
        inventory.drop_all(sides.front)
        count = count - trashed_count
    end
end

local function trash_all()
    local items

    inventory.drop_all(sides.front)
    items = container.get_all_items(peripheral_names.ender_chest)
    for item_name, count in pairs(items) do
        if count > 0 then
            trash_item(item_name, count)
        end
    end
end

local function main()
    init()
    while true do
        route_item(peripheral_names.ender_chest, peripheral_names.inventory_connector, item_names.birch_log)
        route_item(peripheral_names.inventory_connector, peripheral_names.syngas_input, item_names.birch_log)
        trash_all()
        sleep(5)
    end
end

main()