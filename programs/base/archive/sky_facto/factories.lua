---
--- User: glastis.
--- Date: 06-Feb-23
---

local factories = {}

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

create_factory('trashcans:item_trash_can_tile_1', 'trash', 'bin', 'trashcan', 'trash_bin')
create_factory('minecraft:brewing_stand_0', 'brewing_stand', 'brewing', 'brewer', 'still')
create_factory('thermal:machine_chiller_0', 'chiller', 'chiller', 'cryo_chiller', 'machine_chiller', 'freezer')
create_factory('minecraft:barrel_22', 'turtle_output', 'output', 'turtle_output', 'turtle_out', 'out', 'barrel_output', 'barrel_out')
create_factory('minecraft:barrel_23', 'turtle_input', 'input', 'turtle_input', 'turtle_in', 'in', 'barrel_input', 'barrel_in')

return factories