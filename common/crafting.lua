local inventory = require 'inventory'
local constants = require 'constants'
local transfer = require 'item_transfer'
local sides = require 'sides'

local crafting = {}

--[[
---- Recipes are defined as a table of shape and result. Nil values are allowed in the shape table, it means that the slot
---- is not used in the recipe. The result table contains the name of the item to craft and the quantity to craft.
----
---- recipes[#recipes + 1] = {
----      shape = {
----          { item = 'pamhc2foodcore:backewareitem', is_consumed = false},
----          { item = 'farmersdelight:wheat_dough', is_consumed = true}
----      },
----      result = {
----          name = 'minecraft:bread',
----          quantity = 1
----      }
----  }
--]]

local recipes_list = {}
local crafting_buffer_side = nil

function _crafting_table_slot_to_turtle_slot(slot)
    return slot + math.floor((slot - 1) / constants.CRAFTING_TABLE_LINE)
end

function _turtle_slot_to_crafting_table_slot(slot)
    return slot - math.floor(slot / constants.TURTLE_INVENTORY_LINE)
end

function crafting.append_recipe(recipe)
    recipes_list[#recipes_list + 1] = recipe
end

function crafting.get_recipe(item_name)
    for _, recipe in pairs(recipes_list) do
        if recipe and recipe.result and recipe.result.name == item_name then
            return recipe
        end
    end
    return nil
end

function crafting.set_recipes(recipes)
    recipes_list = recipes
end

function crafting.set_crafting_buffer(side)
    crafting_buffer_side = side
end

function _clean_crafting_area()
    inventory.defragment_inventory()
    if inventory.count_empty_slots() < constants.TURTLE_INVENTORY_SIZE - constants.CRAFTING_TABLE_SIZE then
        print('Not enough empty slots to craft')
        return false
    end
    return true
end

function _arrange_items(recipe)
    local i
    local item_details
    local item_required

    i = 1
    while i <= constants.CRAFTING_TABLE_SIZE do
        item_required = recipe.shape[i]
        if item_required and item_required.item then
            turtle.select(_crafting_table_slot_to_turtle_slot(i))
            turtle.transferTo(inventory.get_last_empty_slot())
            if not inventory._select_item_in_slot_range(item_required.item, _crafting_table_slot_to_turtle_slot(i) + 1, constants.TURTLE_INVENTORY_SIZE) then
                print('Item ' .. item .. ' not found')
                return false
            end
            turtle.transferTo(_crafting_table_slot_to_turtle_slot(i))
            sleep(1)
        end
        i = i + 1
    end
    return true
end

function _prepare_table(recipe)
    return _clean_crafting_area() and _arrange_items(recipe)
end

function _is_item_consumed(item_name)
    for _, recipe in pairs(recipes_list) do
        if recipe and recipe.shape and recipe.shape.item == item_name then
            return recipe.result.is_consumed
        end
    end
    return nil
end

function compute_max_craft(recipe)
    local bottle_neck
    local i

    i = 1
    bottle_neck = 64
    while i <= constants.CRAFTING_TABLE_SIZE do
        item_details = turtle.getItemDetail(_crafting_table_slot_to_turtle_slot(i))
        if item_details and _is_item_consumed(item_details.name) and item_count < bottle_neck then
            bottle_neck = item_count
        end
        i = i + 1
    end
    return bottle_neck
end

function do_recipe_contains_unconsumed_item(recipe)
    for _, item in pairs(recipe.shape) do
        if item and not item.is_consumed then
            return true
        end
    end
    return false
end

function _craft_loop_using_buffer(max_craft)
    local i

    i = 0
    print('Crafting ' .. max_craft .. ' items')
    while i < max_craft do
        if not turtle.craft(1) then
            sides.suck[crafting_buffer_side]()
            return i ~= 0
        end
        i = i + 1
        if not sides.drop[crafting_buffer_side]() then
            sides.suck[crafting_buffer_side]()
            return i ~= 0
        end
    end
    sides.suck[crafting_buffer_side]()
    return i ~= 0
end

--[[
---- Perform a craft using the given pattern.
---- Items are taken from the inventory in front of the turtle, and the result is placed in the inventory on top of the turtle.
----
---- Args:  `pattern`       table of 1, 4 or 9 items with each slot containing a string or nil.
----        `limit`         number, the maximum number of crafts to perform.
----
---- Returns the number of crafts performed, and the reason why the craft stopped on failure.
--]]
function craft(item, limit)
    local recipe
    local max_craft

    if not limit then
        limit = 64
    end
    recipe = crafting.get_recipe(item)
    if not recipe then
        print('Recipe not found for item ' .. item)
        return 0
    end
    if not _prepare_table(recipe) then
        print('Failed to prepare table')
        return 0
    end
    max_craft = compute_max_craft(recipe)
    turtle.select(constants.TURTLE_INVENTORY_SIZE)
    if not max_craft or max_craft == 0 then
        print('No item to craft')
        return 0
    end
    if limit and limit < max_craft then
        max_craft = limit
    end
    if do_recipe_contains_unconsumed_item(recipe) then
        if not crafting_buffer_side then
            print('Crafting buffer not set, craft may be limited to 1')
            return turtle.craft()
        end
        print('Crafting using buffer (1 per 1)')
        return _craft_loop_using_buffer(max_craft)
    end
    return turtle.craft(max_craft)
end
crafting.craft = craft

return crafting