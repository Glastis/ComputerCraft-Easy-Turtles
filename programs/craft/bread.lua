package.path = package.path .. ';/ComputerCraft/*/?.lua'
package.path = package.path .. ';/ComputerCraft/common/?.lua'

local container = require 'common.container'
local crafting = require 'common.crafting'
local sides = require 'common.sides'
local inventory = require 'common.inventory'
local constants = require 'common.constants'

local crafting_buffer_side = sides.up
local water_side = sides.down

local chest_prefix = 'minecraft:chest_'
local crating_buffer_name = chest_prefix .. '4'
local chest_bread = chest_prefix .. '0'
local chest_wheat = chest_prefix .. '1'
local crafting_buffer_name = chest_prefix .. '4'

local SLEEP_SEC_BETWEEN_CRAFTS = 100

local recipes = {}

local item_names = {
    dough = 'farmersdelight:wheat_dough',
    wheat = 'minecraft:wheat',
    bread = 'minecraft:bread',
    bucket = 'minecraft:bucket',
    water_bucket = 'minecraft:water_bucket',
    bake_ware = 'pamhc2foodcore:bakewareitem'
}

function init_recipes()

    recipes[#recipes + 1] = {
        shape = {
            { item = item_names.bake_ware, is_consumed = false},
            { item = item_names.dough, is_consumed = true}
        },
        result = {
            name = item_names.bread,
            quantity = 1
        }
    }

    recipes[#recipes + 1] = {
        shape = {
            { item = item_names.water_bucket, is_consumed = true},
            { item = item_names.wheat, is_consumed = true},
            { item = item_names.wheat, is_consumed = true},
            { item = item_names.wheat, is_consumed = true}
        },
        result = {
            name = item_names.dough,
            quantity = 3
        }
    }
end

function move_items_to_buffer()
    local item_name = item_names.wheat
    local moved
    local i

    i = 0
    while i < 3 do
        moved = container.transfer_item(chest_wheat, crating_buffer_name, item_name)
        if moved == 0 then
            print('Failed to move items to buffer')
            return
        end
        i = i + 1
    end
end

function clean_buffer()
    while sides.suck[crafting_buffer_side]() do
        sleep(.1)
    end
    inventory.drop_all_except({ item_names.water_bucket, item_names.bucket, item_names.bake_ware }, crafting_buffer_side)
    while container.transfer_item(crafting_buffer_name, chest_bread, item_names.bread, 64) > 0 do
        sleep(.1)
    end
    while container.transfer_item(crafting_buffer_name, chest_wheat, item_names.wheat, 64) > 0 do
        sleep(.1)
    end
end

function init()
    init_recipes()
    crafting.set_recipes(recipes)
    --crafting.set_crafting_buffer(crafting_buffer_side)
end

function get_water()
    if inventory.select_item(item_names.bucket) then
        turtle.placeDown()
    end
    return inventory.select_item(item_names.water_bucket)
end

function make_dough()
    inventory.suck_all(crafting_buffer_side)
    inventory.drop_all_except({ item_names.wheat, item_names.water_bucket, item_names.bucket }, crafting_buffer_side)
    get_water()
    crafting.craft(item_names.dough, 1)
    sides.drop[crafting_buffer_side]()
    get_water()
    turtle.select(constants.TURTLE_INVENTORY_SIZE)
    while turtle.craft() do
        sides.drop[crafting_buffer_side]()
        get_water()
        turtle.select(constants.TURTLE_INVENTORY_SIZE)
    end
end

function bake_bread()
    local dough_slots_count

    inventory.suck_all(crafting_buffer_side)
    inventory.drop_all_except({ item_names.dough, item_names.bake_ware }, crafting_buffer_side)
    dough_slots_count = inventory.count_item_slots(item_names.dough)
    if dough_slots_count == 0 then
        return
    end
    while inventory.count_item_slots(item_names.dough) > 1 do
        inventory.select_item(item_names.dough)
        sides.drop[crafting_buffer_side]()
    end
    print('Crafting bread')
    crafting.craft(item_names.bread)
    return bake_bread()
end

function craft_bread()
    move_items_to_buffer()
    print('Making dough')
    make_dough()
    print('Baking bread')
    bake_bread()
    clean_buffer()
end

function main()
    init()
    clean_buffer()
    while true do
        craft_bread()
        print('Sleeping for ' .. SLEEP_SEC_BETWEEN_CRAFTS .. ' seconds')
        sleep(SLEEP_SEC_BETWEEN_CRAFTS)
    end
end

main()