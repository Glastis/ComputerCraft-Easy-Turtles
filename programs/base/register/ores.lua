local prefix = require 'common.const.prefixes'
local overflow_handlers = require 'programs.base.overflow_handlers'
local factories = require 'programs.base.factories'

return function(register_new_item)
    local function register_ore(full_name)
        register_new_item({
            ['full_name'] = full_name,
            ['wanted_max'] = 1000,
            ['on_overflow'] = {
                fn = overflow_handlers.move_to,
                args = { peripheral = factories.ore_purifier.name },
            },
        })
    end

    register_ore('allthemodium:raw_allthemodium')
    register_ore('allthemodium:raw_unobtainium')
    register_ore('allthemodium:raw_vibranium')
    register_ore('alltheores:raw_aluminum')
    register_ore('alltheores:raw_iridium')
    register_ore('alltheores:raw_lead')
    register_ore('alltheores:raw_nickel')
    register_ore('alltheores:raw_osmium')
    register_ore('alltheores:raw_platinum')
    register_ore('alltheores:raw_silver')
    register_ore('alltheores:raw_tin')
    register_ore('alltheores:raw_uranium')
    register_ore('alltheores:raw_zinc')
    register_ore(prefix.mod.minecraft .. 'raw_copper')
    register_ore(prefix.mod.minecraft .. 'raw_gold')
    register_ore(prefix.mod.minecraft .. 'raw_iron')
    register_ore('modern_industrialization:raw_antimony')
    register_ore('modern_industrialization:raw_tungsten')
    register_ore('oritech:raw_uranium')
    register_ore('powah:uraninite_raw')
    register_ore('silentgear:raw_crimson_iron')
end
