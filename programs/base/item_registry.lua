---
--- User: glastis.
--- Date: 06-Feb-23
---

local item_registry = {}

local WANTED_MIN_DEFAULT = 10000
local WANTED_MAX_DEFAULT = 50000
local TRASHABLE_DEFAULT = true

local function register_new_item(args)
    local item = {}
    item.mod = args.mod
    item.name = args.name
    if args.full_name then
        item.full_name = args.full_name
    else
        item.full_name = item.mod .. ':' .. item.name
    end
    item.wanted_min = args.wanted_min or WANTED_MIN_DEFAULT
    item.wanted_max = args.wanted_max or WANTED_MAX_DEFAULT
    item.compactable = args.compactable
    item.compact_to = args.compact_to
    item.recipe = {}
    item.recipe.factory = args.factory
    item.recipe.amount = args.amount_per_craft
    item.recipe.shape = args.recipe_shape
    item.recipe.coproducts = args.coproducts
    item.recipe.count_per_craft = args.count_per_craft
    if next(item.recipe) == nil then
        item.recipe = nil
    end
    item.trashable = args.trashable or TRASHABLE_DEFAULT
    item_registry[item.full_name] = item
end

local function build_purge_registry()
    item_registry.purgeable_overflow_list = {}
    for item_name, item in pairs(item_registry) do
        if item.wanted_max then
            item_registry.purgeable_overflow_list[#item_registry.purgeable_overflow_list + 1] = item_name
        end
    end
end

local function build_list_registry()
    item_registry.list = {}
    for item_name, item in pairs(item_registry) do
        if item.full_name then
            item_registry.list[#item_registry.list + 1] = item_name
        end
    end
end

local function build_craftable_list()
    item_registry.craftable_list = {}
    for item_name, item in pairs(item_registry) do
        if item.recipe then
            item_registry.craftable_list[#item_registry.craftable_list + 1] = item_name
        end
    end
end

local function build_compactable_list()
    item_registry.compactable_list = {}
    for item_name, item in pairs(item_registry) do
        if item.compactable then
            item_registry.compactable_list[#item_registry.compactable_list + 1] = item_name
        end
    end
end

local function init()
    register_new_item({
        ['full_name'] = 'minecraft:coal',
        ['compactable'] = 9,
        ['compact_to'] = 'minecraft:coal_block'
    })
    register_new_item({
        ['full_name'] = 'minecraft:iron_ingot',
        ['compactable'] = 9,
        ['compact_to'] = 'minecraft:iron_block'
    })
    register_new_item({
        ['full_name'] = 'minecraft:gold_ingot',
        ['compactable'] = 9,
        ['compact_to'] = 'minecraft:gold_block'
    })
    register_new_item({
        ['full_name'] = 'minecraft:diamond',
        ['compactable'] = 9,
        ['compact_to'] = 'minecraft:diamond_block'
    })
    register_new_item({
        ['full_name'] = 'minecraft:emerald',
        ['compactable'] = 9,
        ['compact_to'] = 'minecraft:emerald_block'
    })
    register_new_item({
        ['full_name'] = 'minecraft:quartz',
        ['compactable'] = 4,
        ['compact_to'] = 'minecraft:quartz_block'
    })
    register_new_item({
        ['full_name'] = 'minecraft:redstone',
        ['compactable'] = 9,
        ['compact_to'] = 'minecraft:redstone_block'
    })
    register_new_item({
        ['full_name'] = 'minecraft:lapis_lazuli',
        ['compactable'] = 9,
        ['compact_to'] = 'minecraft:lapis_block'
    })
    register_new_item({
        ['full_name'] = 'minecraft:clay_ball',
        ['compactable'] = 4,
        ['compact_to'] = 'minecraft:clay'
    })
    register_new_item({
        ['full_name'] = 'minecraft:charcoal',
        ['factory'] = 'furnace',
        ['recipe_shape'] = { 'minecraft:birch_log' },
        ['count_per_craft'] = 1,
        ['compactable'] = 9,
        ['compact_to'] = 'mekanism:block_charcoal'
    })
    register_new_item({
        ['full_name'] = 'minecraft:cobblestone',
        ['factory'] = 'cobble_generator',
    })
    register_new_item({
        ['full_name'] = 'minecraft:stone',
        ['factory'] = 'smelter',
        ['recipe_shape'] = { 'minecraft:cobblestone' },
        ['count_per_craft'] = 1
    })
    register_new_item({
        ['full_name'] = 'minecraft:glass',
        ['factory'] = 'smelter',
        ['recipe_shape'] = { 'minecraft:sand' },
        ['count_per_craft'] = 1
    })
    build_purge_registry()
    build_compactable_list()
    build_list_registry()
    build_craftable_list()
    print('len craftable_list', #item_registry.craftable_list)
end

if not item_registry.init then
    init()
    item_registry.init = true
end

return item_registry