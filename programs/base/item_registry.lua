---
--- User: glastis.
--- Date: 06-Feb-23
---

package.path = package.path .. ';/ComputerCraft/*/?.lua'
package.path = package.path .. ';/ComputerCraft/common/?.lua'

local prefix = require 'common.const.prefixes'

local item_registry = {}

local WANTED_MIN_DEFAULT = 10000
local WANTED_MAX_DEFAULT = 50000
local TRASHABLE_DEFAULT = true
local DEFAULT_COUNT_PER_CRAFT = 1

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
    item.recipe.count_per_craft = args.count_per_craft or DEFAULT_COUNT_PER_CRAFT
    if next(item.recipe) == nil then
        item.recipe = nil
    end
    item.send_to = args.send_to
    item.trashable = args.trashable or TRASHABLE_DEFAULT
    item_registry[item.full_name] = item
end

local function build_list(registry_key, condition)
    item_registry[registry_key] = {}
    for item_name, item in pairs(item_registry) do
        if condition(item) then
            item_registry[registry_key][#item_registry[registry_key] + 1] = item_name
        end
    end
end

local function init()
    register_new_item({
        ['full_name'] = prefix.mod.minecraft .. 'coal',
        ['compactable'] = 9,
        ['compact_to'] = 'minecraft:coal_block'
    })
    register_new_item({
        ['full_name'] = prefix.mod.minecraft .. 'iron_ingot',
        ['factory'] = 'iron',
        ['compactable'] = 9,
        ['compact_to'] = 'minecraft:iron_block'
    })
    register_new_item({
        ['full_name'] = prefix.mod.minecraft .. 'gold_ingot',
        ['factory'] = 'gold',
        ['compactable'] = 9,
        ['compact_to'] = 'minecraft:gold_block'
    })
    register_new_item({
        ['full_name'] = prefix.mod.minecraft .. 'diamond',
        ['compactable'] = 9,
        ['compact_to'] = 'minecraft:diamond_block'
    })
    register_new_item({
        ['full_name'] = prefix.mod.minecraft .. 'emerald',
        ['factory'] = 'emerald',
        ['compactable'] = 9,
        ['compact_to'] = 'minecraft:emerald_block'
    })
    register_new_item({
        ['full_name'] = prefix.mod.minecraft .. 'quartz',
        ['compactable'] = 4,
        ['compact_to'] = 'minecraft:quartz_block'
    })
    register_new_item({
        ['full_name'] = prefix.mod.minecraft .. 'redstone',
        ['factory'] = 'redstone',
        ['compactable'] = 9,
        ['compact_to'] = 'minecraft:redstone_block'
    })
    register_new_item({
        ['full_name'] = prefix.mod.minecraft .. 'lapis_lazuli',
        ['compactable'] = 9,
        ['compact_to'] = 'minecraft:lapis_block'
    })
    register_new_item({
        ['full_name'] = prefix.mod.minecraft .. 'clay_ball',
        ['compactable'] = 4,
        ['compact_to'] = 'minecraft:clay'
    })
    register_new_item({
        ['full_name'] = prefix.mod.minecraft .. 'charcoal',
        ['factory'] = 'furnace',
        ['recipe_shape'] = { 'minecraft:birch_log' },
        ['compactable'] = 9,
        ['compact_to'] = 'mekanism:block_charcoal'
    })
    register_new_item({
        ['full_name'] = prefix.mod.minecraft .. 'cobblestone',
        ['wanted_max'] =  50000000
    })
    register_new_item({
        ['full_name'] = prefix.mod.minecraft .. 'stone',
        ['factory'] = 'smelter',
        ['recipe_shape'] = { 'minecraft:cobblestone' },
    })
    register_new_item({
        ['full_name'] = prefix.mod.minecraft .. 'glass',
        ['factory'] = 'smelter',
        ['recipe_shape'] = { 'minecraft:sand' },
    })
    register_new_item({
        ['full_name'] = prefix.mod.minecraft .. 'sand',
        ['factory'] = 'crusher_create',
        ['recipe_shape'] = { 'minecraft:gravel' },
    })
    register_new_item({
        ['full_name'] = prefix.mod.minecraft .. 'gravel',
        ['factory'] = 'crusher_create',
        ['recipe_shape'] = { 'minecraft:cobblestone' },
    })
    register_new_item({
        ['full_name'] = prefix.mod.minecraft .. 'glowstone_dust',
        ['factory'] = 'glowstone',
    })
    register_new_item({
        ['full_name'] = prefix.mod.hostile_networks .. 'prediction_matrix',
        ['wanted_min'] = 1000,
        ['send_to'] = 'prediction_matrix',
    })
    register_new_item({
        ['full_name'] = prefix.mod.minecraft .. 'rotten_flesh',
        ['factory'] = 'rotten_flesh',
    })
    register_new_item({
        ['full_name'] = prefix.mod.minecraft .. 'blaze_rod',
        ['factory'] = 'blaze_rod',
    })
    register_new_item({
        ['full_name'] = prefix.mod.minecraft .. 'bone',
        ['factory'] = 'bone',
    })
    register_new_item({
        ['full_name'] = prefix.mod.minecraft .. 'gunpowder',
        ['factory'] = 'gunpowder',
    })
    register_new_item({
        ['full_name'] = prefix.mod.minecraft .. 'phantom_membrane',
        ['factory'] = 'membrane',
    })
    

    local lists_to_build = {
        { key = 'purgeable_overflow_list', field = 'wanted_max' },
        { key = 'compactable_list', field = 'compactable' },
        { key = 'list', field = 'full_name' },
        { key = 'craftable_list', field = 'recipe' },
        { key = 'sendable_list', field = 'send_to' }
    }
    
    for _, list_config in ipairs(lists_to_build) do
        build_list(list_config.key, function(item) return item[list_config.field] end)
    end
end

if not item_registry.init then
    init()
    item_registry.init = true
end

return item_registry