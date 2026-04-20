local prefix = require 'common.const.prefixes'

return function(register_new_item)
    register_new_item({
        ['full_name'] = prefix.mod.minecraft .. 'coal',
        ['compactable'] = 9,
        ['compact_to'] = prefix.mod.minecraft .. 'coal_block'
    })
    register_new_item({
        ['full_name'] = prefix.mod.minecraft .. 'iron_ingot',
        ['factory'] = 'iron',
        ['compactable'] = 9,
        ['compact_to'] = prefix.mod.minecraft ..'iron_block'
    })
    register_new_item({
        ['full_name'] = prefix.mod.minecraft .. 'gold_ingot',
        ['factory'] = 'gold',
        ['compactable'] = 9,
        ['compact_to'] = prefix.mod.minecraft .. 'gold_block'
    })
    register_new_item({
        ['full_name'] = prefix.mod.minecraft .. 'diamond',
        ['compactable'] = 9,
        ['compact_to'] = prefix.mod.minecraft .. 'diamond_block'
    })
    register_new_item({
        ['full_name'] = prefix.mod.minecraft .. 'emerald',
        ['factory'] = 'emerald',
        ['compactable'] = 9,
        ['compact_to'] = prefix.mod.minecraft .. 'emerald_block'
    })
    register_new_item({
        ['full_name'] = prefix.mod.minecraft .. 'quartz',
        ['compactable'] = 4,
        ['compact_to'] = prefix.mod.minecraft .. 'quartz_block'
    })
    register_new_item({
        ['full_name'] = prefix.mod.minecraft .. 'redstone',
        ['factory'] = 'redstone',
        ['compactable'] = 9,
        ['compact_to'] = prefix.mod.minecraft .. 'redstone_block'
    })
    register_new_item({
        ['full_name'] = prefix.mod.minecraft .. 'lapis_lazuli',
        ['compactable'] = 9,
        ['compact_to'] = prefix.mod.minecraft .. 'lapis_block'
    })
    register_new_item({
        ['full_name'] = prefix.mod.minecraft .. 'clay_ball',
        ['compactable'] = 4,
        ['compact_to'] = prefix.mod.minecraft ..'clay'
    })
    register_new_item({
        ['full_name'] = prefix.mod.minecraft .. 'charcoal',
        ['factory'] = 'furnace',
        ['recipe_shape'] = { prefix.mod.minecraft .. 'birch_log' },
        ['compactable'] = 9,
        ['compact_to'] = prefix.mod.mekanism .. 'block_charcoal'
    })
    register_new_item({
        ['full_name'] = prefix.mod.minecraft .. 'cobblestone',
        ['wanted_max'] =  50000000
    })
    register_new_item({
        ['full_name'] = prefix.mod.minecraft .. 'stone',
        ['factory'] = 'smelter',
        ['recipe_shape'] = { prefix.mod.minecraft .. 'cobblestone' },
    })
    register_new_item({
        ['full_name'] = prefix.mod.minecraft .. 'glass',
        ['factory'] = 'smelter',
        ['recipe_shape'] = { prefix.mod.minecraft .. 'sand' },
    })
    register_new_item({
        ['full_name'] = prefix.mod.minecraft .. 'sand',
        ['factory'] = 'crusher_create',
        ['recipe_shape'] = { prefix.mod.minecraft .. 'gravel' },
    })
    register_new_item({
        ['full_name'] = prefix.mod.minecraft .. 'gravel',
        ['factory'] = 'crusher_create',
        ['recipe_shape'] = { prefix.mod.minecraft ..'cobblestone' },
    })
    register_new_item({
        ['full_name'] = prefix.mod.minecraft .. 'glowstone_dust',
        ['factory'] = 'glowstone',
    })
    register_new_item({
        ['full_name'] = prefix.mod.minecraft .. 'rotten_flesh',
        ['factory'] = 'rotten_flesh',
    })
    register_new_item({
        ['full_name'] = prefix.mod.minecraft .. 'blaze_rod',
        ['factory'] = 'blaze_rod',
    })
    register_new_item({
        ['full_name'] = prefix.mod.minecraft .. 'bone',
        ['factory'] = 'bone',
    })
    register_new_item({
        ['full_name'] = prefix.mod.minecraft .. 'gunpowder',
        ['factory'] = 'gunpowder',
    })
    register_new_item({
        ['full_name'] = prefix.mod.minecraft .. 'phantom_membrane',
        ['factory'] = 'membrane',
    })
    register_new_item({
        ['full_name'] = prefix.mod.minecraft .. 'beef',
        ['factory'] = 'beef',
    })
    register_new_item({
        ['full_name'] = prefix.mod.minecraft .. 'porkchop',
        ['factory'] = 'porkchop',
    })
    register_new_item({
        ['full_name'] = prefix.mod.minecraft .. 'white_wool',
        ['factory'] = 'wool',
    })
    register_new_item({
        ['full_name'] = prefix.mod.minecraft .. 'magma_cream',
        ['factory'] = 'magma_cream',
    })
    register_new_item({
        ['full_name'] = prefix.mod.minecraft .. 'nether_star',
        ['factory'] = 'nether_star',
    })
    register_new_item({
        ['full_name'] = prefix.mod.minecraft .. 'feather',
        ['factory'] = 'feather',
    })

    local register_stone = function(name)
        register_new_item({
            ['full_name'] = prefix.mod.minecraft .. name,
            ['compactable'] = 9,
            ['compact_to'] = prefix.mod.minecraft .. 'allthecompressed:' .. name .. '_1x'
        })
    end

    register_stone('granite')
    register_stone('diorite')
    register_stone('andesite')
    register_stone('tuff')
    register_stone('cobbled_deepslate')
end
