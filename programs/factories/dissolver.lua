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

local ITEM_MAX_COUNT = 5000
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

local function init()
    local to_dissolve

    peripheral_names.inventory_connector = prefixes.inventory_connector .. '7'
    peripheral_names.turtle = prefixes.turtle .. '11'
    peripheral_names.dissolvers = {}
    for i = 10, 51 do
        peripheral_names.dissolvers[#peripheral_names.dissolvers + 1] = prefixes.dissolver .. i
    end

    peripheral_names.compactor_iron = prefixes.compactor .. '8'
    peripheral_names.compactor_platinum = prefixes.compactor .. '7'
    peripheral_names.compactor_andesite = {
        prefixes.compactor .. '9',
        prefixes.compactor .. '14',
        prefixes.compactor .. '15',
        prefixes.compactor .. '16',
        prefixes.compactor .. '17',
        prefixes.compactor .. '18',
        prefixes.compactor .. '19',
    }
    peripheral_names.compactor_gold = prefixes.compactor .. '10'
    peripheral_names.compactor_silver = prefixes.compactor .. '11'
    peripheral_names.compactor_aluminum = prefixes.compactor .. '12'
    peripheral_names.compactor_osmium = prefixes.compactor .. '13'

    peripheral_names.compactors = {
        peripheral_names.compactor_iron,
        peripheral_names.compactor_platinum,
        peripheral_names.compactor_andesite,
        peripheral_names.compactor_gold,
        peripheral_names.compactor_silver,
        peripheral_names.compactor_aluminum,
        peripheral_names.compactor_osmium,
    }

    item_names.element = {}
    item_names.element.iron = prefixes.mod.chemlib .. 'iron'
    item_names.element.oxygen = prefixes.mod.chemlib .. 'oxygen'
    item_names.element.platinum = prefixes.mod.chemlib .. 'platinum'
    item_names.element.calcium = prefixes.mod.chemlib .. 'calcium'
    item_names.element.gold = prefixes.mod.chemlib .. 'gold'
    item_names.element.silver = prefixes.mod.chemlib .. 'silver'
    item_names.element.aluminum = prefixes.mod.chemlib .. 'aluminum'
    item_names.element.osmium = prefixes.mod.chemlib .. 'osmium'

    item_names.coumpound = {}
    item_names.coumpound.silicon_dioxide = prefixes.mod.chemlib .. 'silicon_dioxide'
    item_names.coumpound.aluminium_oxide = prefixes.mod.chemlib .. 'aluminum_oxide'
    item_names.coumpound.potassium_chloride = prefixes.mod.chemlib .. 'potassium_chloride'
    item_names.coumpound.calcium_carbonate = prefixes.mod.chemlib .. 'calcium_carbonate'
    item_names.coumpound.carbonate = prefixes.mod.chemlib .. 'carbonate'
    item_names.coumpound.graphite = prefixes.mod.chemlib .. 'graphite'

    item_names.andesite = prefixes.minecraft .. 'andesite'
    item_names.cobbled_deepslate = prefixes.minecraft .. 'cobbled_deepslate'
    item_names.cobblestone = prefixes.minecraft .. 'cobblestone'
    item_names.stone = prefixes.minecraft .. 'stone'
    item_names.egg = prefixes.minecraft .. 'egg'

    to_dissolve = {
        item_names.andesite,
        item_names.cobbled_deepslate,
        item_names.cobblestone,
        item_names.stone,
        item_names.coumpound.aluminium_oxide,
        item_names.coumpound.potassium_chloride,
        item_names.coumpound.calcium_carbonate,
        item_names.coumpound.carbonate,
        item_names.coumpound.graphite,
        item_names.egg,
    }

    trash_list = {}

    fast_routes = {
        {from = peripheral_names.dissolvers, to = peripheral_names.compactor_gold, item = item_names.element.gold},
        {from = peripheral_names.dissolvers, to = peripheral_names.compactor_silver, item = item_names.element.silver},
        {from = peripheral_names.dissolvers, to = peripheral_names.compactor_aluminum, item = item_names.element.aluminum},
        {from = peripheral_names.dissolvers, to = peripheral_names.compactor_osmium, item = item_names.element.osmium},
        {from = peripheral_names.dissolvers, to = peripheral_names.compactor_iron, item = item_names.element.iron},
        {from = peripheral_names.dissolvers, to = peripheral_names.compactor_platinum, item = item_names.element.platinum},
    }

    routes = {}
    for _, item in pairs(to_dissolve) do
        routes[#routes+1] = {from = peripheral_names.inventory_connector, to = peripheral_names.dissolvers, item = item, condition_function = function() return container.count_item(peripheral_names.inventory_connector, item) > 0 end}
    end
    routes[#routes+1] = {from = peripheral_names.dissolvers, to = peripheral_names.inventory_connector}
    routes[#routes+1] = {from = peripheral_names.compactors, to = peripheral_names.inventory_connector}
    routes[#routes+1] = {from = peripheral_names.inventory_connector, to = peripheral_names.compactor_andesite, item = item_names.coumpound.silicon_dioxide}
    routes[#routes+1] = {from = peripheral_names.inventory_connector, to = peripheral_names.compactor_gold, item = item_names.element.gold}
    routes[#routes+1] = {from = peripheral_names.inventory_connector, to = peripheral_names.compactor_silver, item = item_names.element.silver}
    routes[#routes+1] = {from = peripheral_names.inventory_connector, to = peripheral_names.compactor_aluminum, item = item_names.element.aluminum}
    routes[#routes+1] = {from = peripheral_names.inventory_connector, to = peripheral_names.compactor_osmium, item = item_names.element.osmium}
    routes[#routes+1] = {from = peripheral_names.inventory_connector, to = peripheral_names.compactor_iron, item = item_names.element.iron}
    routes[#routes+1] = {from = peripheral_names.inventory_connector, to = peripheral_names.compactor_platinum, item = item_names.element.platinum}
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
        if count > ITEM_MAX_COUNT then
            trash_item(item_name, count - ITEM_MAX_COUNT)
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
    check_peripheral_connection(peripheral_names)
    while true do
        parallel.waitForAny(fast_routing, normal_routing)
    end
end

main()