---
--- User: glastis.
--- Date: 06-Feb-23
---

local factories = {}

package.path = package.path .. ';/ComputerCraft/*/?.lua'
package.path = package.path .. ';/ComputerCraft/common/?.lua'

local module_init = false
local applied_energistics = require 'mods.applied_energistics'
local prefixes = require 'common.const.prefixes'

local function create_factory(peripheral_name, ...)
    local args
    local factory

    args = {...}
    factory = {}
    factory.name = peripheral_name
    factory.peripheral = peripheral.wrap(peripheral_name)
    factories[factory.name] = factory
    for _, arg in ipairs(args) do
        factories[arg] = factory
    end
end

local function craft(item_name, count)
    local item_registry = require 'programs.base.item_registry'
    local item = item_registry[item_name]
    local count_per_craft = item.recipe.count_per_craft or 1
    count = count * count_per_craft
    if item.recipe then
        if item.recipe.factory and not item.recipe.shape then
            print('Getting', item_name, count, factories[item.recipe.factory].name)
            return applied_energistics.get_item_from(item_name, count, factories[item.recipe.factory].name)
        elseif item.recipe.factory and item.recipe.shape then
            print('Sending', item.recipe.shape[1], count, factories[item.recipe.factory].name)
            return applied_energistics.send_item_to(item.recipe.shape[1], count, factories[item.recipe.factory].name)
        else
            print('Crafting', item_name, count)
            return applied_energistics.ae.craftItem({['name'] = item_name, ['count'] = count})
        end
    else
        print('Factory not found for', item_name)
        return nil
    end
end
factories.craft = craft

create_factory(prefixes.trash_item .. '1', 'trash', 'bin', 'trashcan', 'trash_bin')
create_factory(prefixes.ender_chest .. '', 'furnace', 'smelter', 'mekanism_smelter')
create_factory(prefixes.ender_chest .. '', 'crusher_create', 'crusher_wheel')
create_factory(prefixes.ender_chest .. '', 'crusher', 'crusher_mekanism')
create_factory(prefixes.ender_chest .. '', 'enricher', 'enricher_mekanism')
create_factory(prefixes.ender_chest .. '', 'infuser_red')
create_factory(prefixes.ender_chest .. '', 'infuser_blue')
create_factory(prefixes.ender_chest .. '', 'infuser_violet')
create_factory(prefixes.ender_chest .. '', 'purificator')
create_factory(prefixes.ender_chest .. '', 'injector')
create_factory(prefixes.ender_chest .. '', 'cobble_generator')
create_factory(prefixes.ender_chest .. '0', 'ore_purifier', 'ore_purificator', 'ore_purification')

return factories