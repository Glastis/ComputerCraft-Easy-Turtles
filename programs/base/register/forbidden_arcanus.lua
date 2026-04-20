local prefix = require 'common.const.prefixes'

return function(register_new_item)
    register_new_item({
        ['full_name'] = 'forbidden_arcanus:ender_pearl_fragment',
        ['compactable'] = 4,
        ['compact_to'] = prefix.mod.minecraft .. 'ender_pearl',
    })
end
