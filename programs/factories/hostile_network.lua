package.path = package.path .. ';/ComputerCraft/*/?.lua'
package.path = package.path .. ';/ComputerCraft/common/?.lua'

local container = require 'common.container'
local prefixes = require 'common.const.prefixes'

local peripheral_names = {}
local item_names = {}
local routes = {}

local MAIN_LOOP_DELAY = 60

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
    peripheral_names.trash = prefixes.trash_item .. '0'
    peripheral_names.chest_predict_matrix = prefixes.ender_chest .. '4'
    peripheral_names.chest_heart = prefixes.ender_chest .. '5'
    peripheral_names.chest_predict_end = prefixes.ender_chest .. '6'

    peripheral_names.fabricator_heart = prefixes.loot_fabricator .. '0'
    peripheral_names.sim_piglich = prefixes.sim .. '0'
    peripheral_names.all_sim = {
        peripheral_names.sim_piglich,
    }

    item_names.predict_matrix = prefixes.mod.hostile_networks .. 'prediction_matrix'
    item_names.predict_end = prefixes.mod.hostile_networks .. 'end_prediction'
    item_names.predict_mob = prefixes.mod.hostile_networks .. 'prediction'
    item_names.piglich_heart = prefixes.mod.allthemodium .. 'piglich_heart'

    routes = {}
    routes[#routes+1] = {from = peripheral_names.chest_predict_matrix, to = peripheral_names.all_sim, item = item_names.predict_matrix}
    routes[#routes+1] = {from = peripheral_names.sim_piglich, to = peripheral_names.chest_predict_end, item = item_names.predict_end}
    routes[#routes+1] = {from = peripheral_names.sim_piglich, to = peripheral_names.fabricator_heart, item = item_names.predict_mob}
    routes[#routes+1] = {from = peripheral_names.fabricator_heart, to = peripheral_names.chest_heart, item = item_names.piglich_heart}
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

local function normal_routing()
    exec_route_list(routes, true)
    print('Sleeping normal routes for ' .. MAIN_LOOP_DELAY .. ' seconds')
    sleep(MAIN_LOOP_DELAY)
end

local function main()
    init()
    check_peripheral_connection(peripheral_names)
    while true do
        normal_routing()
    end
end

main()