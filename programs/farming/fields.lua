package.path = package.path .. ';/ComputerCraft/*/?.lua'
package.path = package.path .. ';/ComputerCraft/common/?.lua'

local container = require 'common.container'
local inventory = require 'common.inventory'
local sides = require 'common.sides'
local prefixes = require 'common.const.prefixes'

local peripheral_names = {}
local item_names = {}
local routes = {}
local fast_routes = {}

local REDSTONE_DETECTOR_SIDE = 'left'
local ITEM_MAX_COUNT = 5000

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
    peripheral_names.storage_interface = prefixes.portable_storage_interface .. '3'
    peripheral_names.inventory_connector = prefixes.inventory_connector .. '4'
    peripheral_names.turtle = prefixes.turtle .. '5'
    peripheral_names.dissolvers_beetroot = {
        prefixes.dissolver .. '1',
        prefixes.dissolver .. '2',
        prefixes.dissolver .. '3',
        prefixes.dissolver .. '4',
        prefixes.dissolver .. '5',
        prefixes.dissolver .. '6',
    }
    peripheral_names.dissolvers_iron = {
        prefixes.dissolver .. '7',
        prefixes.dissolver .. '8',
        prefixes.dissolver .. '9',
    }
    peripheral_names.compactor_sugarcane = {
        prefixes.compactor .. '1',
        prefixes.compactor .. '3',
        prefixes.compactor .. '4',
        prefixes.compactor .. '5',
        prefixes.compactor .. '6',
    }
    peripheral_names.compactor_iron = prefixes.compactor .. '2'

    peripheral_names.dissolvers = {
        peripheral_names.dissolvers_beetroot,
        peripheral_names.dissolvers_iron,
    }

    peripheral_names.compactors = {
        peripheral_names.compactor_sugarcane,
        peripheral_names.compactor_iron,
    }

    item_names.beetroot = prefixes.minecraft .. 'beetroot'
    item_names.iron_oxide = prefixes.mod.chemlib .. 'iron_oxide'
    item_names.sucrose = prefixes.mod.chemlib .. 'sucrose'
    item_names.iron_elem = prefixes.mod.chemlib .. 'iron'
    item_names.iron_dust = prefixes.mod.chemlib .. 'iron_dust'
    item_names.oxygen_elem = prefixes.mod.chemlib .. 'oxygen'
    item_names.sugar_cane = prefixes.minecraft .. 'sugar_cane'
    item_names.straw = prefixes.mod.farmersdelight .. 'straw'

    fast_routes = {}
    fast_routes[#fast_routes+1] = {from = peripheral_names.dissolvers_iron, to = peripheral_names.compactor_iron, item = item_names.iron_elem}

    routes = {}
    routes[#routes+1] = {from = peripheral_names.storage_interface, to = peripheral_names.inventory_connector}
    routes[#routes+1] = {from = peripheral_names.inventory_connector, to = peripheral_names.dissolvers_beetroot, item = item_names.beetroot, condition_function = function() return container.count_item(peripheral_names.inventory_connector, item_names.iron_dust) < 4000 end}
    routes[#routes+1] = {from = peripheral_names.dissolvers_beetroot, to = peripheral_names.dissolvers_iron, item = item_names.iron_oxide}
    routes[#routes+1] = {from = peripheral_names.dissolvers_beetroot, to = peripheral_names.compactor_sugarcane, item = item_names.sucrose}
    routes[#routes+1] = {from = peripheral_names.inventory_connector, to = peripheral_names.dissolvers_iron, item = item_names.iron_oxide}
    routes[#routes+1] = {from = peripheral_names.inventory_connector, to = peripheral_names.compactor_sugarcane, item = item_names.sucrose}
    routes[#routes+1] = {from = peripheral_names.dissolvers_iron, to = peripheral_names.compactor_iron, item = item_names.iron_elem}
    routes[#routes+1] = {from = peripheral_names.dissolvers_iron, to = peripheral_names.inventory_connector, item = item_names.oxygen_elem}
    routes[#routes+1] = {from = peripheral_names.inventory_connector, to = peripheral_names.compactor_iron, item = item_names.iron_elem}
    routes[#routes+1] = {from = peripheral_names.compactor_sugarcane, to = peripheral_names.inventory_connector, item = item_names.sugar_cane}
    routes[#routes+1] = {from = peripheral_names.compactor_iron, to = peripheral_names.inventory_connector, item = item_names.iron_dust}
    routes[#routes+1] = {from = peripheral_names.dissolvers, to = peripheral_names.inventory_connector}
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

local function wait_storage_interface()
    os.pullEvent('redstone')
    return not rs.getInput(REDSTONE_DETECTOR_SIDE)
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
        inventory.drop_all(sides.bottom)
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

local function exec_fast_routes()
    while true do
        for _, route in pairs(fast_routes) do
            route_item(route.from, route.to, route.item, route.condition_function)
        end
        sleep(5)
    end
end

local function exec_routes()
    if wait_storage_interface() then
        for _, route in pairs(routes) do
            route_item(route.from, route.to, route.item, route.condition_function)
        end
        trash_extra_items()
    end
end

local function main()
    init()
    check_peripheral_connection(peripheral_names)
    while true do
        parallel.waitForAny(exec_fast_routes, exec_routes)
    end
end

main()