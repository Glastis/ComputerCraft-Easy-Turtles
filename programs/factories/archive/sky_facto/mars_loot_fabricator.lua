---
--- User: glastis.
--- Date: 26-Feb-23
---

package.path = package.path .. ';/ComputerCraft/*/?.lua'
package.path = package.path .. ';/ComputerCraft/common/?.lua'

local refined_storage = require 'mods.refined_storage'
local periph = require 'mods.periph'

local item_to_craft
local item_to_craft_names

local function init()
    local loot_fabricator_name_prefix
    local simulation_chamber_name_prefix

    loot_fabricator_name_prefix = 'hostilenetworks:loot_fabricator_'
    simulation_chamber_name_prefix = 'hostilenetworks:sim_chamber_'

    refined_storage.init(rsBridge_4)

    item_to_craft = {}
    item_to_craft['minecraft:redstone'] = {
        name = 'minecraft:redstone',
        amount_wanted = 10000,
        loot_fabricators = periph.wrap_peripheral_range(loot_fabricator_name_prefix, 0, 5),
        simulation_chambers = periph.wrap_peripheral_range(simulation_chamber_name_prefix, 0, 63)
    }
    for _, item in pairs(item_to_craft) do
        item_to_craft_names[#item_to_craft_names + 1] = item.name
    end
end

local function pipe_item(item)
    
end

local function run_factories()
    local found

    found = refined_storage.search_items_with_condition_exec(
            item_to_craft_names,
            function(item)
                return item.amount < item_to_craft[item.name].amount_wanted
            end,
            nil,
            false,
            function(item)
                pipe_item(item_to_craft[item.name])
            end
    )
    return found > 0
end

local function main()
    while true do
        if run_factories() then
            sleep(30)
        else
            sleep(120)
        end
    end
end

init()
main()