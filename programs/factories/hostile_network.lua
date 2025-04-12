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

local function create_full_path(sim_name, chest_predict_name, fabricator_names, chest_names, predict_type)
    predict_type = predict_type or item_names.predict_overworld
    fabricator_names = type(fabricator_names) == 'table' and fabricator_names or {fabricator_names}
    chest_names = type(chest_names) == 'table' and chest_names or {chest_names}

    routes[#routes+1] = {from = sim_name, to = chest_predict_name, item = predict_type}
    routes[#routes+1] = {from = sim_name, to = peripheral_names.trash, item = predict_type}
    
    for i, fabricator_name in ipairs(fabricator_names) do
        routes[#routes+1] = {from = sim_name, to = fabricator_name, item = item_names.predict_mob}
        routes[#routes+1] = {from = fabricator_name, to = chest_names[i], item_blacklist = item_names.predict_mob}
    end
end

local function init()
    peripheral_names.trash = prefixes.trash_item .. '0'
    peripheral_names.chest_predict_matrix = prefixes.ender_chest .. '4'
    peripheral_names.chest_predict_end = prefixes.ender_chest .. '6'
    peripheral_names.chest_predict_nether = prefixes.ender_chest .. '7'
    peripheral_names.chest_predict_overworld = prefixes.ender_chest .. '10'
    peripheral_names.chest_heart = prefixes.ender_chest .. '5'
    peripheral_names.chest_skull = prefixes.ender_chest .. '8'
    peripheral_names.chest_redstone = prefixes.ender_chest .. '9'
    peripheral_names.chest_glowstone = prefixes.ender_chest .. '12'
    peripheral_names.chest_emerald = prefixes.ender_chest .. '11'
    peripheral_names.chest_undying = prefixes.ender_chest .. '13'
    peripheral_names.chest_iron = prefixes.ender_chest .. '29'
    peripheral_names.chest_blaze = prefixes.ender_chest .. '30'
    peripheral_names.chest_bone = prefixes.ender_chest .. '31'
    peripheral_names.chest_membrane = prefixes.ender_chest .. '32'
    peripheral_names.chest_rotten_flesh = prefixes.ender_chest .. '33'
    peripheral_names.chest_gold = prefixes.ender_chest .. '34'
    peripheral_names.chest_gunpowder = prefixes.ender_chest .. '35'
    peripheral_names.chest_wither_star = prefixes.ender_chest .. '36'
    peripheral_names.chest_magma_cream = prefixes.ender_chest .. '37'
    peripheral_names.chest_wool = prefixes.ender_chest .. '38'
    peripheral_names.chest_mutton = prefixes.ender_chest .. '39'
    peripheral_names.chest_feather = prefixes.ender_chest .. '40'
    peripheral_names.chest_chicken = prefixes.ender_chest .. '41'
    peripheral_names.chest_leather = prefixes.ender_chest .. '42'
    peripheral_names.chest_beef = prefixes.ender_chest .. '43'
    peripheral_names.chest_porkchop = prefixes.ender_chest .. '44'

    peripheral_names.fabricator_heart = prefixes.loot_fabricator .. '0'
    peripheral_names.fabricator_skull = prefixes.loot_fabricator .. '3'
    peripheral_names.fabricator_redstone = prefixes.loot_fabricator .. '1'
    peripheral_names.fabricator_glowstone = prefixes.loot_fabricator .. '2'
    peripheral_names.fabricator_emerald = prefixes.loot_fabricator .. '4'
    peripheral_names.fabricator_undying = prefixes.loot_fabricator .. '5'
    peripheral_names.fabricator_iron = prefixes.loot_fabricator .. '6'
    peripheral_names.fabricator_blaze = prefixes.loot_fabricator .. '7'
    peripheral_names.fabricator_bone = prefixes.loot_fabricator .. '8'
    peripheral_names.fabricator_membrane = prefixes.loot_fabricator .. '9'
    peripheral_names.fabricator_rotten_flesh = prefixes.loot_fabricator .. '10'
    peripheral_names.fabricator_gold = prefixes.loot_fabricator .. '11'
    peripheral_names.fabricator_gunpowder = prefixes.loot_fabricator .. '12'
    peripheral_names.fabricator_wither_star = prefixes.loot_fabricator .. '13'
    peripheral_names.fabricator_magma_cream = prefixes.loot_fabricator .. '14'
    peripheral_names.fabricator_wool = prefixes.loot_fabricator .. '15'
    peripheral_names.fabricator_mutton = prefixes.loot_fabricator .. '16'
    peripheral_names.fabricator_feather = prefixes.loot_fabricator .. '17'
    peripheral_names.fabricator_chicken = prefixes.loot_fabricator .. '18'
    peripheral_names.fabricator_leather = prefixes.loot_fabricator .. '19'
    peripheral_names.fabricator_beef = prefixes.loot_fabricator .. '20'
    peripheral_names.fabricator_porkchop = prefixes.loot_fabricator .. '21'
    
    peripheral_names.sim_piglich = prefixes.sim .. '0'
    peripheral_names.sim_wither_skeleton = prefixes.sim .. '1'
    peripheral_names.sim_witch = prefixes.sim .. '2'
    peripheral_names.sim_evoker = prefixes.sim .. '3'
    peripheral_names.golem = prefixes.sim .. '4'
    peripheral_names.blaze = prefixes.sim .. '5'
    peripheral_names.skeleton = prefixes.sim .. '6'
    peripheral_names.phantom = prefixes.sim .. '7'
    peripheral_names.zombie = prefixes.sim .. '8'
    peripheral_names.zombie_piglin = prefixes.sim .. '9'
    peripheral_names.creeper = prefixes.sim .. '10'
    peripheral_names.wither = prefixes.sim .. '11'
    peripheral_names.magma_cube = prefixes.sim .. '12'
    peripheral_names.sheep = prefixes.sim .. '13'
    peripheral_names.chicken = prefixes.sim .. '14'
    peripheral_names.cow = prefixes.sim .. '15'
    peripheral_names.pig = prefixes.sim .. '16'
    peripheral_names.all_sim = {
        peripheral_names.sim_piglich,
        peripheral_names.sim_wither_skeleton,
        peripheral_names.sim_witch,
        peripheral_names.sim_evoker,
        peripheral_names.golem,
        peripheral_names.blaze,
        peripheral_names.skeleton,
        peripheral_names.phantom,
        peripheral_names.zombie,
        peripheral_names.zombie_piglin,
        peripheral_names.creeper,
        peripheral_names.wither,
        peripheral_names.magma_cube,
        peripheral_names.sheep,
        peripheral_names.chicken,
        peripheral_names.cow,
        peripheral_names.pig,
    }

    item_names.predict_matrix = prefixes.mod.hostile_networks .. 'prediction_matrix'
    item_names.predict_end = prefixes.mod.hostile_networks .. 'end_prediction'
    item_names.predict_nether = prefixes.mod.hostile_networks .. 'nether_prediction'
    item_names.predict_overworld = prefixes.mod.hostile_networks .. 'overworld_prediction'
    item_names.predict_mob = prefixes.mod.hostile_networks .. 'prediction'

    routes = {}
    routes[#routes+1] = {from = peripheral_names.chest_predict_matrix, to = peripheral_names.all_sim, item = item_names.predict_matrix}
    
    create_full_path(
        peripheral_names.sim_witch,
        peripheral_names.chest_predict_overworld,
        {peripheral_names.fabricator_redstone, peripheral_names.fabricator_glowstone},
        {peripheral_names.chest_redstone, peripheral_names.chest_glowstone},
        item_names.predict_overworld
    )
    create_full_path(
        peripheral_names.sim_evoker,
        peripheral_names.chest_predict_overworld,
        {peripheral_names.fabricator_emerald, peripheral_names.fabricator_undying},
        {peripheral_names.chest_emerald, peripheral_names.chest_undying},
        item_names.predict_overworld
    )
    create_full_path(
        peripheral_names.sheep, 
        peripheral_names.chest_predict_overworld, 
        {peripheral_names.fabricator_wool, peripheral_names.fabricator_mutton},
        {peripheral_names.chest_wool, peripheral_names.chest_mutton},
        item_names.predict_overworld
    )
    create_full_path(peripheral_names.sim_piglich, peripheral_names.chest_predict_end, peripheral_names.fabricator_heart, peripheral_names.chest_heart, item_names.predict_end)
    create_full_path(peripheral_names.sim_wither_skeleton, peripheral_names.chest_predict_nether, peripheral_names.fabricator_skull, peripheral_names.chest_skull, item_names.predict_nether)
    create_full_path(peripheral_names.golem, peripheral_names.chest_predict_overworld, peripheral_names.fabricator_iron, peripheral_names.chest_iron)
    create_full_path(peripheral_names.blaze, peripheral_names.chest_predict_nether, peripheral_names.fabricator_blaze, peripheral_names.chest_blaze, item_names.predict_nether)
    create_full_path(peripheral_names.skeleton, peripheral_names.chest_predict_overworld, peripheral_names.fabricator_bone, peripheral_names.chest_bone, item_names.predict_overworld)
    create_full_path(peripheral_names.phantom, peripheral_names.chest_predict_overworld, peripheral_names.fabricator_membrane, peripheral_names.chest_membrane, item_names.predict_overworld)
    create_full_path(peripheral_names.zombie, peripheral_names.chest_predict_overworld, peripheral_names.fabricator_rotten_flesh, peripheral_names.chest_rotten_flesh, item_names.predict_overworld)
    create_full_path(peripheral_names.zombie_piglin, peripheral_names.chest_predict_overworld, peripheral_names.fabricator_gold, peripheral_names.chest_gold, item_names.predict_nether)
    create_full_path(peripheral_names.creeper, peripheral_names.chest_predict_overworld, peripheral_names.fabricator_gunpowder, peripheral_names.chest_gunpowder, item_names.predict_overworld)
    create_full_path(peripheral_names.wither, peripheral_names.chest_predict_overworld, peripheral_names.fabricator_wither_star, peripheral_names.chest_wither_star, item_names.predict_end)
    create_full_path(peripheral_names.magma_cube, peripheral_names.chest_predict_overworld, peripheral_names.fabricator_magma_cream, peripheral_names.chest_magma_cream, item_names.predict_nether)
    create_full_path(peripheral_names.chicken, peripheral_names.chest_predict_overworld, peripheral_names.fabricator_feather, peripheral_names.chest_feather, item_names.predict_overworld)
    create_full_path(peripheral_names.cow, peripheral_names.chest_predict_overworld, peripheral_names.fabricator_beef, peripheral_names.chest_beef, item_names.predict_overworld)
    create_full_path(peripheral_names.pig, peripheral_names.chest_predict_overworld, peripheral_names.fabricator_porkchop, peripheral_names.chest_porkchop, item_names.predict_overworld)
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
            route_item(route.from, route.to, route.item, route.condition_function, route.item_blacklist)
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
    exec_route_list(routes, false)
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