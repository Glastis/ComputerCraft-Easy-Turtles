package.path = package.path .. ';/ComputerCraft/*/?.lua'
package.path = package.path .. ';/ComputerCraft/common/?.lua'

local container = require 'common.container'
local prefixes = require 'common.const.prefixes'

local peripheral_names = {}
local item_names = {}
local routes = {}
local fast_routes = {}

local ITEM_MAX_COUNT = 5000
local MAIN_LOOP_DELAY = 15
local FAST_ROUTES_DELAY = 10

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
    peripheral_names.inventory_connector = prefixes.inventory_connector .. '9'
    peripheral_names.wood_farm = prefixes.barrel .. '22'
    peripheral_names.oven_input = prefixes.barrel .. '23'
    peripheral_names.oven_output = prefixes.barrel .. '21'
    peripheral_names.trash = prefixes.barrel .. '25'
    peripheral_names.dissolvers = {}
    for i = 52, 66 do
        peripheral_names.dissolvers[#peripheral_names.dissolvers + 1] = prefixes.dissolver .. i
    end

    peripheral_names.compactor_diamond = prefixes.compactor .. '26'
    peripheral_names.compactor_graphite = {}
    for i = 20, 25 do
        peripheral_names.compactor_graphite[#peripheral_names.compactor_graphite + 1] = prefixes.compactor .. i
    end

    item_names.charcoal = prefixes.minecraft .. 'charcoal'
    item_names.diamond = prefixes.minecraft .. 'diamond'
    item_names.graphite = prefixes.mod.chemlib .. 'graphite'
    item_names.graphite_dust = prefixes.mod.chemlib .. 'graphite_dust'
    item_names.log = prefixes.minecraft .. 'birch_log'

    fast_routes = {
        {from = peripheral_names.inventory_connector, to = peripheral_names.compactor_graphite, item = item_names.charcoal},
    }

    routes = {}
    routes[#routes+1] = {from = peripheral_names.wood_farm, to = peripheral_names.oven_input, item = item_names.log}
    routes[#routes+1] = {from = peripheral_names.wood_farm, to = peripheral_names.trash}
    routes[#routes+1] = {from = peripheral_names.oven_output, to = peripheral_names.inventory_connector}
    routes[#routes+1] = {from = peripheral_names.compactor_graphite, to = peripheral_names.inventory_connector, item = item_names.graphite_dust}
    routes[#routes+1] = {from = peripheral_names.compactor_diamond, to = peripheral_names.inventory_connector, item = item_names.diamond}
    routes[#routes+1] = {from = peripheral_names.dissolvers, to = peripheral_names.inventory_connector, item = item_names.graphite}
    routes[#routes+1] = {from = peripheral_names.inventory_connector, to = peripheral_names.dissolvers, item = item_names.charcoal}
    routes[#routes+1] = {from = peripheral_names.inventory_connector, to = peripheral_names.compactor_graphite, item = item_names.graphite}
    routes[#routes+1] = {from = peripheral_names.inventory_connector, to = peripheral_names.compactor_diamond, item = item_names.graphite_dust}
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
        trashed_count = container.transfer_item(peripheral_names.inventory_connector, peripheral_names.trash, name, count)
        if trashed_count == 0 then
            print('Failed to trash ' .. count .. ' ' .. name)
            return
        end
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

local function exec_route_list(route_list, should_run_async)
    local functions = {}

    for _, route in pairs(route_list) do
        table.insert(functions, function()
            route_item(route.from, route.to, route.item, route.condition_function)
        end)
    end
    if should_run_async then
        parallel.waitForAny(table.unpack(functions))
    else
        for _, f in pairs(functions) do
            f()
        end
    end
end

local function fast_routing()
    while true do
        exec_route_list(fast_routes, true)
        sleep(FAST_ROUTES_DELAY)
    end
end

local function normal_routing()
    exec_route_list(routes, false)
    trash_extra_items()
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