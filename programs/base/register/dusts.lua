local overflow_handlers = require 'programs.base.overflow_handlers'
local factories = require 'programs.base.factories'

local DUSTS = {
    'alltheores:aluminum_dust',
    'alltheores:copper_dust',
    'alltheores:gold_dust',
    'alltheores:iridium_dust',
    'alltheores:iron_dust',
    'alltheores:lead_dust',
    'alltheores:nickel_dust',
    'alltheores:osmium_dust',
    'alltheores:platinum_dust',
    'alltheores:silver_dust',
    'alltheores:steel_dust',
    'alltheores:tin_dust',
    'alltheores:uranium_dust',
    'alltheores:zinc_dust',
}

return function(register_new_item)
    for _, full_name in ipairs(DUSTS) do
        register_new_item({
            ['full_name'] = full_name,
            ['wanted_max'] = 2500,
            ['on_overflow'] = {
                fn = overflow_handlers.move_to,
                args = { peripheral = factories.smelter.name },
            },
        })
    end
end
