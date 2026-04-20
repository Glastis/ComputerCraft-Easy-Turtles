local prefix = require 'common.const.prefixes'

return function(register_new_item)
    register_new_item({
        ['full_name'] = prefix.mod.hostile_networks .. 'prediction_matrix',
        ['wanted_min'] = 1000,
        ['send_to'] = 'prediction_matrix',
    })
end
