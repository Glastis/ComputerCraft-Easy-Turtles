---
--- User: glastis.
--- Date: 26-Jan-23
---

package.path = package.path .. ';/ComputerCraft/*/?.lua'
package.path = package.path .. ';/ComputerCraft/common/?.lua'

local utils = require 'common.utils'

local item_list
local item_list_short

local refined_storage

local IDLE_TIME_WHEN_NOTHING_TO_CRAFT = 60

local function register_new_item(mod, name, wanted_amount, factory, amount_per_craft, recipe_shape, coproducts)
    item = {}
    item.mod = mod
    item.name = name
    item.full_name = item.mod .. ':' .. item.name
    item.wanted_amount = wanted_amount
    item.recipe = {}
    item.recipe.factory = factory
    item.recipe.amount = amount_per_craft
    item.recipe.shape = recipe_shape
    item.recipe.coproducts = coproducts
    item_list[#item_list + 1] = item
    item_list_short[item.full_name] = {}
    item_list_short[item.full_name].wanted_amount = item.wanted_amount
    item_list_short[item.full_name].id = #item_list
end

local function init()
    refined_storage = peripheral.wrap('rsBridge_1')

    local element_binder = {}
    element_binder['air'] = {}
    element_binder['air'].name = 'elementalcraft:binder_0'
    element_binder['air'].peripheral = peripheral.wrap(element_binder['air'].name)
    element_binder['water'] = {}
    element_binder['water'].name = 'elementalcraft:binder_1'
    element_binder['water'].peripheral = peripheral.wrap(element_binder['water'].name)
    element_binder['earth'] = {}
    element_binder['earth'].name = 'elementalcraft:binder_2'
    element_binder['earth'].peripheral = peripheral.wrap(element_binder['earth'].name)

    local element_crystallizer = {}
    element_crystallizer['air'] = {}
    element_crystallizer['air'].name = 'elementalcraft:crystallizer_3'
    element_crystallizer['air'].peripheral = peripheral.wrap(element_crystallizer['air'].name)
    element_crystallizer['water'] = {}
    element_crystallizer['water'].name = 'elementalcraft:crystallizer_0'
    element_crystallizer['water'].peripheral = peripheral.wrap(element_crystallizer['water'].name)
    element_crystallizer['earth'] = {}
    element_crystallizer['earth'].name = 'elementalcraft:crystallizer_1'
    element_crystallizer['earth'].peripheral = peripheral.wrap(element_crystallizer['earth'].name)
    element_crystallizer['fire'] = {}
    element_crystallizer['fire'].name = 'elementalcraft:crystallizer_2'
    element_crystallizer['fire'].peripheral = peripheral.wrap(element_crystallizer['fire'].name)

    item_list_short = {}
    item_list = {}
    local item

    register_new_item(
            'elementalcraft',
            'swift_alloy_ingot',
            500,
            element_binder['air'],
            1,
            { 'minecraft:gold_ingot', 'elementalcraft:drenched_iron_ingot', 'minecraft:copper_ingot', 'minecraft:redstone', 'elementalcraft:aircrystal' }
    )
    register_new_item(
            'elementalcraft',
            'springaline_shard',
            500,
            element_binder['water'],
            1,
            { 'minecraft:amethyst_shard', 'minecraft:quartz', 'elementalcraft:watercrystal' }
    )
    register_new_item(
            'elementalcraft',
            'pristine_fire_gem',
            10,
            element_crystallizer['fire'],
            1,
            { 'minecraft:diamond', 'elementalcraft:firecrystal', 'elementalcraft:fire_shard', 'elementalcraft:fire_shard', 'elementalcraft:fire_shard' },
            { 'elementalcraft:crude_fire_gem', 'elementalcraft:fine_fire_gem' }
    )
    register_new_item(
            'elementalcraft',
            'pristine_water_gem',
            10,
            element_crystallizer['water'],
            1,
            { 'minecraft:diamond', 'elementalcraft:watercrystal', 'elementalcraft:water_shard', 'elementalcraft:water_shard', 'elementalcraft:water_shard' },
            { 'elementalcraft:crude_water_gem', 'elementalcraft:fine_water_gem' }
    )
    register_new_item(
            'elementalcraft',
            'pristine_air_gem',
            10,
            element_crystallizer['air'],
            1,
            { 'minecraft:diamond', 'elementalcraft:aircrystal', 'elementalcraft:air_shard', 'elementalcraft:air_shard', 'elementalcraft:air_shard' },
            { 'elementalcraft:crude_air_gem', 'elementalcraft:fine_air_gem' }
    )
    register_new_item(
            'elementalcraft',
            'pristine_earth_gem',
            10,
            element_crystallizer['earth'],
            1,
            { 'minecraft:diamond', 'elementalcraft:earthcrystal', 'elementalcraft:earth_shard', 'elementalcraft:earth_shard', 'elementalcraft:earth_shard' },
            { 'elementalcraft:crude_earth_gem', 'elementalcraft:fine_earth_gem' }
    )
end

local function search_items_from_rs(rs_items, item_name_list, minimum_amount)
    local rs_found_item_list
    local found_item_amount

    rs_found_item_list = {}
    found_item_amount = 0
    for _, item in pairs(rs_items) do
        for _, item_name in pairs(item_name_list) do
            if item.name == item_name then
                if item.amount < minimum_amount then
                    print('[' .. os.date() .. '] Not enough items to craft ' .. item_name .. ' (' .. item.amount .. '/' .. minimum_amount .. ')')
                    return nil
                end
                local new_item = {}
                new_item.name = item.name
                new_item.count = 1
                new_item.fingerprint = item.fingerprint
                rs_found_item_list[item.name] = new_item
                found_item_amount = found_item_amount + 1
            end
        end
    end
    if found_item_amount ~= #item_name_list then
        print('required items: ' .. #item_name_list .. ', found items: ' .. found_item_amount)
        for _, item in pairs(rs_found_item_list) do
            print('found item: ' .. item.name .. ', amount: ' .. item.amount)
        end
        return nil
    end
    return rs_found_item_list
end

local function find_items_need_crafted(rs_items)
    local not_found_items

    not_found_items = {}
    for k, item in pairs(item_list) do
        not_found_items[k] = item
    end
    for _, item in pairs(rs_items) do
        if item.name and item_list_short[item.name] then
            if item_list_short[item.name].wanted_amount > tonumber(item.amount) then
                return item_list[item_list_short[item.name].id], item_list_short[item.name].wanted_amount - item.amount
            end
            not_found_items[item_list_short[item.name].id] = nil
        end
    end
    for k, item in pairs(not_found_items) do
        if item then
            return item_list[item_list_short[item.full_name].id], item_list_short[item.full_name].wanted_amount
        end
    end
    return nil, nil
end

local function craft_item_insert(rs_items, result_item)
    local i

    i = 1
    while i <= #result_item.recipe.shape do
        refined_storage.exportItemToPeripheral(rs_items[result_item.recipe.shape[i]], result_item.recipe.factory.name)
        i = i + 1
    end
end

local function craft_wait_item(result_item, watch_every, timeout)
    local i
    local items_in_factory

    i = watch_every
    sleep(watch_every)
    while i < timeout do
        items_in_factory = result_item.recipe.factory.peripheral.list()
        for _, item in pairs(items_in_factory) do
            if item.name == result_item.full_name or result_item.recipe.coproducts and utils.is_elem_in_table(result_item.recipe.coproducts, item.name) then
                return true
            end
        end
        sleep(watch_every)
        i = i + watch_every
    end
    error('[' .. os.date() .. '] Timeout while crafting ' .. result_item.full_name)
    return false
end

local function empty_factory(factory)
    local items_in_factory

    items_in_factory = factory.peripheral.list()
    for _, item in pairs(items_in_factory) do
        refined_storage.importItemFromPeripheral(item, factory.name)
    end
end

local function craft_item(result_item, amount, rs_storage)
    local i
    local rs_items

    i = 0
    rs_items = search_items_from_rs(rs_storage, result_item.recipe.shape, amount)
    if not rs_items then
        print('[' .. os.date() .. '] Not enough items to craft ' .. result_item.full_name)
        return false
    end
    empty_factory(result_item.recipe.factory)
    while i < amount do
        craft_item_insert(rs_items, result_item)
        craft_wait_item(result_item, 5, 500)
        empty_factory(result_item.recipe.factory)
        i = i + 1
    end
    return true
end

local function main()
    local items
    local item_to_craft
    local amount

    while true do
        items = refined_storage.listItems()
        item_to_craft, amount = find_items_need_crafted(items)
        if not item_to_craft then
            print('[' .. os.date() .. '] Nothing to craft')
            sleep(IDLE_TIME_WHEN_NOTHING_TO_CRAFT)
        else
            print('[' .. os.date() .. '] Crafting ' .. amount .. ' ' .. item_to_craft.full_name)
            if not craft_item(item_to_craft, amount, items) then
                sleep(IDLE_TIME_WHEN_NOTHING_TO_CRAFT)
            end
        end
        sleep(0.1)
    end
end

init()
main()