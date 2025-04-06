package.path = package.path .. ';/ComputerCraft/*/?.lua'
package.path = package.path .. ';/ComputerCraft/common/?.lua'

local container = require "common.container"
local inventory = require "common.inventory"

local PERIPHERAL_NAMES = {}
local ITEM_NAMES = {}
local routes = {}

local MAIN_LOOP_DELAY = 30

local function init()
    local prefixes = {}
    prefixes.redstone = 'redstoneIntegrator_'
    prefixes.barrel = 'minecraft:barrel_'
    prefixes.dropper = 'minecraft:dropper_'
    prefixes.turtle = 'turtle_'
    prefixes.generator = 'thermal:dynamo_stirling_'
    prefixes.dissolver = 'alchemistry:dissolver_block_entity_'
    prefixes.compactor = 'alchemistry:compactor_block_entity_'
    prefixes.extruder = 'thermal:device_rock_gen_'
    prefixes.pulverizer = 'thermal:machine_pulverizer_'

    PERIPHERAL_NAMES.fuel_chest = prefixes.barrel .. '10'
    PERIPHERAL_NAMES.silicium_chest = prefixes.barrel .. '11'
    PERIPHERAL_NAMES.andesite_chest = prefixes.barrel .. '12'
    PERIPHERAL_NAMES.diorite_chest = prefixes.barrel .. '13'
    PERIPHERAL_NAMES.cobblestone_chest = prefixes.barrel .. '14'
    PERIPHERAL_NAMES.flint_chest = prefixes.barrel .. '17'
    PERIPHERAL_NAMES.sand_chest = prefixes.barrel .. '18'
    PERIPHERAL_NAMES.dissolver = prefixes.dissolver .. '0'
    PERIPHERAL_NAMES.compactor = prefixes.compactor .. '0'
    PERIPHERAL_NAMES.extruder = prefixes.extruder .. '4'
    PERIPHERAL_NAMES.turtle = prefixes.turtle .. '3'
    PERIPHERAL_NAMES.pulverizer = prefixes.pulverizer .. '0'

    ITEM_NAMES.fuel = {}
    ITEM_NAMES.fuel.oak_log = 'minecraft:oak_log'
    ITEM_NAMES.fuel.spruce_log = 'minecraft:spruce_log'
    ITEM_NAMES.fuel.birch_log = 'minecraft:birch_log'
    ITEM_NAMES.fuel.oak_sapling = 'minecraft:oak_sapling'
    ITEM_NAMES.fuel.spruce_sapling = 'minecraft:spruce_sapling'
    ITEM_NAMES.fuel.birch_sapling = 'minecraft:birch_sapling'
    ITEM_NAMES.fuel.oak_planks = 'minecraft:oak_planks'
    ITEM_NAMES.fuel.spruce_planks = 'minecraft:spruce_planks'
    ITEM_NAMES.fuel.birch_planks = 'minecraft:birch_planks'
    ITEM_NAMES.fuel.stick = 'minecraft:stick'
    ITEM_NAMES.fuel.apple = 'minecraft:apple'
    ITEM_NAMES.fuel.coal = 'minecraft:coal'
    ITEM_NAMES.fuel.charcoal = 'minecraft:charcoal'
    ITEM_NAMES.fuel.blaze_powder = 'minecraft:blaze_powder'
    ITEM_NAMES.fuel.blaze_rod = 'minecraft:blaze_rod'
    ITEM_NAMES.fuel.charcoal_block = 'thermal:charcoal_block'

    ITEM_NAMES.silicium = 'chemlib:silicon_dioxide'
    ITEM_NAMES.andesite = 'minecraft:andesite'
    ITEM_NAMES.diorite = 'minecraft:diorite'
    ITEM_NAMES.gravel = 'minecraft:gravel'
    ITEM_NAMES.flint = 'minecraft:flint'
    ITEM_NAMES.sand = 'minecraft:sand'
    ITEM_NAMES.cobblestone = 'minecraft:cobblestone'

    routes[#routes+1] = {from = PERIPHERAL_NAMES.extruder, to = PERIPHERAL_NAMES.pulverizer}
    routes[#routes+1] = {from = PERIPHERAL_NAMES.extruder, to = PERIPHERAL_NAMES.cobblestone_chest}
    routes[#routes+1] = {from = PERIPHERAL_NAMES.dissolver, to = PERIPHERAL_NAMES.compactor, item = ITEM_NAMES.silicium}
    routes[#routes+1] = {from = PERIPHERAL_NAMES.dissolver, to = PERIPHERAL_NAMES.silicium_chest, item = ITEM_NAMES.silicium}
    routes[#routes+1] = {from = PERIPHERAL_NAMES.compactor, to = PERIPHERAL_NAMES.diorite_chest, item = ITEM_NAMES.diorite}
end

local function transfer_all_turtle_item(item, to)
    local slot

    slot = inventory.get_item_slot(item)
    while slot and
          container.transfer_item_from_turtle(PERIPHERAL_NAMES.turtle, slot, to, item) > 0 do
            slot = inventory.get_item_slot(item)
    end
end

local function clean_inventory()
    local i
    local item

    transfer_all_turtle_item(ITEM_NAMES.diorite, PERIPHERAL_NAMES.diorite_chest)
    transfer_all_turtle_item(ITEM_NAMES.cobblestone, PERIPHERAL_NAMES.cobblestone_chest)
    transfer_all_turtle_item(ITEM_NAMES.andesite, PERIPHERAL_NAMES.andesite_chest)
    transfer_all_turtle_item(ITEM_NAMES.silicium, PERIPHERAL_NAMES.silicium_chest)
    transfer_all_turtle_item(ITEM_NAMES.flint, PERIPHERAL_NAMES.flint_chest)
    transfer_all_turtle_item(ITEM_NAMES.sand, PERIPHERAL_NAMES.sand_chest)
    i = 1
    while i <= 16 do
        item = turtle.getItemDetail(i)
        if item then
            turtle.select(i)
            turtle.dropDown()
        end
        i = i + 1
    end
end

local function trash_all(peripheral_from, item_name)
    local i

    i = 1
    while i > 0 do
        print('Trashing ' .. string.match(item_name, ':(.*)') .. ' from ' .. string.match(peripheral_from, '_(.*)'))
        i = container.transfer_item_to_turtle(peripheral_from, PERIPHERAL_NAMES.turtle, item_name)
        while inventory.select_item(item_name) do
            turtle.dropDown()
        end
    end
end

local function make_flint()
    local i
    local is_flint_full

    if turtle.detect() then
        turtle.dig()
    end
    clean_inventory()
    is_flint_full = container.is_full(PERIPHERAL_NAMES.flint_chest, true)
    if is_flint_full and container.is_full(PERIPHERAL_NAMES.sand_chest, true) then
        print('Sand and flint chests are full, no need to make more')
        return
    end
    print('Transferring gravel to turtle')
    container.transfer_item_to_turtle(PERIPHERAL_NAMES.pulverizer, PERIPHERAL_NAMES.turtle, ITEM_NAMES.gravel)
    container.transfer_item_to_turtle(PERIPHERAL_NAMES.pulverizer, PERIPHERAL_NAMES.turtle, ITEM_NAMES.sand)
    container.transfer_item_to_turtle(PERIPHERAL_NAMES.pulverizer, PERIPHERAL_NAMES.turtle, ITEM_NAMES.flint)
    if is_flint_full then
        print('Flint chest is full, no need to make more')
        return
    end
    while inventory.select_item(ITEM_NAMES.gravel) do
        while turtle.place() do
            turtle.dig()
        end
    end
    print('Transferring flint to dissolver')
    transfer_all_turtle_item(ITEM_NAMES.flint, PERIPHERAL_NAMES.dissolver)
    clean_inventory()
end

local function make_andesite()
    local i

    if container.is_full(PERIPHERAL_NAMES.andesite_chest, true) then
        print('Andesite chest is full, no need to make more')
        return
    end
    clean_inventory()
    print('Transferring diorite and cobblestone to turtle')
    if container.transfer_item_to_turtle(PERIPHERAL_NAMES.diorite_chest, PERIPHERAL_NAMES.turtle, ITEM_NAMES.diorite, 64, 1) > 0 and
       container.transfer_item_to_turtle(PERIPHERAL_NAMES.cobblestone_chest, PERIPHERAL_NAMES.turtle, ITEM_NAMES.cobblestone, 64, 2) > 0 then
        turtle.craft()
    end
    clean_inventory()
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

local function main()
    local i

    init()
    clean_inventory()
    while true do
        i = 1
        while i <= #routes do
            route_item(routes[i].from, routes[i].to, routes[i].item)
            i = i + 1
        end
        make_flint()
        make_andesite()
        print('Waiting for ' .. MAIN_LOOP_DELAY .. ' seconds')
        sleep(MAIN_LOOP_DELAY)
    end
end

main()

