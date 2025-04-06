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

local ender_chest_prefix = 'enderstorage:ender_chest_'

create_factory('trashcans:item_trash_can_tile_0', 'trash', 'bin', 'trashcan', 'trash_bin')
create_factory(ender_chest_prefix .. '0', 'furnace', 'smelter')
create_factory(ender_chest_prefix .. '1', 'crusher_create', 'crusher_wheel')
create_factory(ender_chest_prefix .. '2', 'crusher', 'crusher_mekanism')
create_factory(ender_chest_prefix .. '3', 'enricher', 'enricher_mekanism')
create_factory(ender_chest_prefix .. '4', 'infuser_red')
create_factory(ender_chest_prefix .. '5', 'infuser_blue')
create_factory(ender_chest_prefix .. '6', 'infuser_violet')
create_factory(ender_chest_prefix .. '7', 'purificator')
create_factory(ender_chest_prefix .. '8', 'injector')
create_factory(ender_chest_prefix .. '9', 'cobble_generator')
create_factory(ender_chest_prefix .. '10', 'smelter_create')
create_factory(ender_chest_prefix .. '11', 'smoker_create')

return factories