---
--- User: glastis.
--- Date: 06-Feb-23
---

local item_registry = {}

local factories = require 'programs.base.factories'

local function register_new_item(args)
    item = {}
    item.mod = args.mod
    item.name = args.name
    if args.full_name then
        item.full_name = args.full_name
    else
        item.full_name = item.mod .. ':' .. item.name
    end
    item.wanted_min = args.wanted_min
    item.wanted_max = args.wanted_max
    item.compactable = args.compactable
    item.recipe = {}
    item.recipe.factory = args.factory
    item.recipe.amount = args.amount_per_craft
    item.recipe.shape = args.recipe_shape
    item.recipe.coproducts = args.coproducts
    item.recipe.importable = args.importable
    item.recipe.exportable = args.exportable
    item_registry[item.full_name] = item
end

local function build_purge_registry()
    item_registry.purge = {}
    for item_name, item in pairs(item_registry) do
        if item.wanted_max then
            item_registry.purge[#item_registry.purge + 1] = item_name
        end
    end
end

register_new_item({
    ['full_name'] = 'minecraft:cobblestone',
    ['wanted_min'] = 2500,
    ['wanted_max'] = 5000
})
register_new_item({
    ['full_name'] = 'minecraft:coal',
    ['wanted_min'] = 2500,
    ['wanted_max'] = 3000,
    ['compactable'] = 9
})
register_new_item({
    ['full_name'] = 'minecraft:iron_ingot',
    ['wanted_min'] = 2500,
    ['wanted_max'] = 5000,
    ['compactable'] = 9
})
register_new_item({
    ['full_name'] = 'minecraft:gold_ingot',
    ['wanted_min'] = 2500,
    ['wanted_max'] = 5000,
    ['compactable'] = 9
})
register_new_item({
    ['full_name'] = 'minecraft:diamond',
    ['wanted_min'] = 2500,
    ['wanted_max'] = 5000,
    ['compactable'] = 9
})
register_new_item({
    ['full_name'] = 'minecraft:emerald',
    ['wanted_min'] = 2500,
    ['wanted_max'] = 5000,
    ['compactable'] = 9
})
register_new_item({
    ['full_name'] = 'minecraft:quartz',
    ['wanted_min'] = 2500,
    ['wanted_max'] = 5000,
    ['compactable'] = 4
})
register_new_item({
    ['full_name'] = 'minecraft:redstone',
    ['wanted_min'] = 2500,
    ['wanted_max'] = 5000,
    ['compactable'] = 9
})

build_purge_registry()

return item_registry