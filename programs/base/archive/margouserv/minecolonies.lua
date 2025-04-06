package.path = package.path .. ';/ComputerCraft/*/?.lua'
package.path = package.path .. ';/ComputerCraft/common/?.lua'

local container = require 'common.container'
local inventory = require 'common.inventory'
local sides = require 'common.sides'
local prefixes = require 'common.const.prefixes'
local utils = require 'common.utils'

local peripheral_names = {}
local item_names = {}
local trash_list = {}
local routes = {}
local fast_routes = {}
local item_limits = {}


local ITEM_MAX_COUNT = 3000
local TRASH_SIDE = sides.front
local MAIN_LOOP_DELAY = 10
local FAST_ROUTES_DELAY = 5

local function check_peripheral_connection(peripheral_name)
    if type(peripheral_name) == 'table' then
        for _, p in pairs(peripheral_name) do
            check_peripheral_connection(p)
        end
        return
    end
    if not peripheral.wrap(peripheral_name) then
        print('Peripheral ' .. peripheral_name .. ' not found')
        error()
    end
end

local function init_item_names()
    item_names.charcoal = prefixes.minecraft .. 'charcoal'
    item_names.diamond = prefixes.minecraft .. 'diamond'
    item_names.graphite = prefixes.mod.chemlib .. 'graphite'
    item_names.graphite_dust = prefixes.mod.chemlib .. 'graphite_dust'
    item_names.log = prefixes.minecraft .. 'birch_log'
    item_names.wheat_seeds = prefixes.minecraft .. 'wheat_seeds'
    item_names.wheat = prefixes.minecraft .. 'wheat'
    item_names.beetroot_seeds = prefixes.minecraft .. 'beetroot_seeds'
    item_names.panel = prefixes.mod.domum_ornamentoum .. 'panel'
end

local function init_item_limit()
    item_limits[item_names.wheat_seeds] = 500
    item_limits[item_names.beetroot_seeds] = 500
    item_limits[item_names.panel] = 7000
end

local function init_peripherals()
    peripheral_names.inventory_connector = prefixes.inventory_connector .. '8'
    peripheral_names.turtle = prefixes.turtle .. '12'
    peripheral_names.trash = prefixes.barrel .. '20'
    check_peripheral_connection(peripheral_names.inventory_connector)
end

local function init_routes()
    routes = {}
end

local function init_fast_routes()
    fast_routes = {}
end

local function init()
    init_peripherals()
    init_item_names()
    init_item_limit()
    init_routes()
end

local function route_item(from, to, item_name, condition_function, item_blacklist)
    if type(from) == 'table' then
        for _, from_peripheral in pairs(from) do
            route_item(from_peripheral, to, item_name, condition_function)
        end
        return
    end
    if type(to) == 'table' then
        for _, to_peripheral in pairs(to) do
            route_item(from, to_peripheral, item_name, condition_function)
        end
        return
    end
    if condition_function and not condition_function() then
        print('Condition not met for routing from ' .. string.match(from, '_(.*)') .. ' to ' .. string.match(to, '_(.*)'))
        return
    end
    if item_name then
        print('Routing ' .. string.match(item_name, ':(.*)') .. ' from ' .. string.match(from, '_(.*)') .. ' to ' .. string.match(to, '_(.*)'))
        while container.transfer_item(from, to, item_name, nil, item_blacklist) > 0 do end
    else
        print('Routing all items from ' .. string.match(from, '_(.*)') .. ' to ' .. string.match(to, '_(.*)'))
        while container.transfer_all(from, to, item_blacklist) > 0 do end
    end
end

local function get_all_items()
    local contents
    local inventory_connector
    local items

    inventory_connector = peripheral.wrap(peripheral_names.inventory_connector)
    contents = inventory_connector.list()
    items = {}
    for slot, item in pairs(contents) do
        if not items[item.name] then
            items[item.name] = item.count
        else
            items[item.name] = items[item.name] + item.count
        end
    end
    return items
end

local function trash_item(name, count)
    local trashed_count

    print('Trashing ' .. count .. ' ' .. name)
    while count > 0 do
        trashed_count = container.transfer_item_to_turtle(peripheral_names.inventory_connector, peripheral_names.turtle, name, count)
        if trashed_count == 0 then
            print('Failed to trash ' .. count .. ' ' .. name)
            return
        end
        inventory.drop_all(TRASH_SIDE)
        count = count - trashed_count
    end
end

local function trash_extra_items()
    local items

    items = get_all_items()
    for item_name, count in pairs(items) do
        if count > ITEM_MAX_COUNT and not item_limits[item_name] then
            trash_item(item_name, count - ITEM_MAX_COUNT)
        elseif item_limits[item_name] and count > item_limits[item_name] then
            trash_item(item_name, count - item_limits[item_name])
        end
    end
end

local function trash_blacklisted_items()
    local inventory_connector
    local contents

    inventory_connector = peripheral.wrap(peripheral_names.inventory_connector)
    contents = inventory_connector.list()
    for slot, item in pairs(contents) do
        if utils.is_elem_in_table(trash_list, item.name) then
            inventory_connector.pushItems(peripheral_names.turtle, slot)
            inventory.drop_all(TRASH_SIDE)
        end
    end
end

local function exec_route_list(route_list)
    local functions = {}
    for _, route in pairs(route_list) do
        table.insert(functions, function()
            route_item(route.from, route.to, route.item, route.condition_function)
        end)
    end
    parallel.waitForAll(table.unpack(functions))
end

local function fast_routing()
    while true do
        exec_route_list(fast_routes)
        sleep(FAST_ROUTES_DELAY)
    end
end

local function normal_routing()
    exec_route_list(routes)
    trash_extra_items()
    trash_blacklisted_items()
    print('Sleeping normal routes for ' .. MAIN_LOOP_DELAY .. ' seconds')
    sleep(MAIN_LOOP_DELAY)
end

local function main()
    init()
    while true do
        parallel.waitForAny(fast_routing, normal_routing)
    end
end

main()