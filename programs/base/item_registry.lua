---
--- User: glastis.
--- Date: 06-Feb-23
---

package.path = package.path .. ';/ComputerCraft/*/?.lua'
package.path = package.path .. ';/ComputerCraft/common/?.lua'

local item_registry = {}

local WANTED_MIN_DEFAULT = 25000
local WANTED_MAX_DEFAULT = 500000
local TRASHABLE_DEFAULT = true
local DEFAULT_COUNT_PER_CRAFT = 1

local REGISTER_MODULES = {
    'minecraft',
    'hostile_networks',
    'forbidden_arcanus',
}

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
    item.on_overflow = args.on_overflow
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
    for _, module_name in ipairs(REGISTER_MODULES) do
        require('programs.base.register.' .. module_name)(register_new_item)
    end

    local lists_to_build = {
        { key = 'purgeable_overflow_list', field = 'wanted_max' },
        { key = 'compactable_list', field = 'compactable' },
        { key = 'list', field = 'full_name' },
        { key = 'craftable_list', field = 'recipe' },
        { key = 'sendable_list', field = 'send_to' },
        { key = 'on_overflow_list', field = 'on_overflow' }
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
