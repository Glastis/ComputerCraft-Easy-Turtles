---
--- User: glastis.
--- Date: 06-Feb-23
---

local factories = {}

package.path = package.path .. ';/ComputerCraft/*/?.lua'
package.path = package.path .. ';/ComputerCraft/common/?.lua'

local module_init = false
local item_registry = require 'programs.base.item_registry'
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
create_factory(prefixes.ender_chest .. '16', 'furnace', 'smelter', 'mekanism_smelter')
create_factory(prefixes.ender_chest .. '2', 'crusher_create', 'crusher_wheel')
create_factory(prefixes.ender_chest .. '0', 'crusher', 'crusher_mekanism')
create_factory(prefixes.ender_chest .. '', 'enricher', 'enricher_mekanism')
create_factory(prefixes.ender_chest .. '', 'infuser_red')
create_factory(prefixes.ender_chest .. '', 'infuser_blue')
create_factory(prefixes.ender_chest .. '', 'infuser_violet')
create_factory(prefixes.ender_chest .. '', 'purificator')
create_factory(prefixes.ender_chest .. '', 'injector')
create_factory(prefixes.ender_chest .. '', 'cobble_generator')
create_factory(prefixes.ender_chest .. '3', 'smelter_create')
create_factory(prefixes.ender_chest .. '1', 'smoker_create')
create_factory(prefixes.ender_chest .. '14', 'ore_purifier', 'ore_purificator', 'ore_purification')

-- No precursors crafts
create_factory(prefixes.ender_chest .. '20', 'redstone')
create_factory(prefixes.ender_chest .. '22', 'overworld_prediction')
create_factory(prefixes.ender_chest .. '19', 'wither_skull_fragment')
create_factory(prefixes.ender_chest .. '21', 'piglich_heart')
create_factory(prefixes.ender_chest .. '26', 'end_prediction')
create_factory(prefixes.ender_chest .. '24', 'nether_prediction')
create_factory(prefixes.ender_chest .. '28', 'emerald')
create_factory(prefixes.ender_chest .. '27', 'glowstone')
create_factory(prefixes.ender_chest .. '23', 'undying_totem')
create_factory(prefixes.ender_chest .. '15', 'rotten_flesh')
create_factory(prefixes.ender_chest .. '18', 'iron')
create_factory(prefixes.ender_chest .. '17', 'blaze_rod')
create_factory(prefixes.ender_chest .. '45', 'membrane')
create_factory(prefixes.ender_chest .. '46', 'bone')
create_factory(prefixes.ender_chest .. '47', 'gunpowder')
create_factory(prefixes.ender_chest .. '48', 'gold')
create_factory(prefixes.ender_chest .. '49', 'beef')
create_factory(prefixes.ender_chest .. '50', 'wool')
create_factory(prefixes.ender_chest .. '51', 'nether_star')
create_factory(prefixes.ender_chest .. '52', 'feather')
create_factory(prefixes.ender_chest .. '53', 'porkchop')
create_factory(prefixes.ender_chest .. '54', 'magma_cream')

create_factory(prefixes.ender_chest .. '25', 'prediction_matrix')

return factories