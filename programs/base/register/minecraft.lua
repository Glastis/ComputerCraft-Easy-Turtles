local prefix = require 'common.const.prefixes'

return function(register_new_item)
    local function register_compactable(args)
        register_new_item({
            ['full_name'] = prefix.mod.minecraft .. args.name,
            ['compactable'] = args.count or 9,
            ['compact_to'] = args.compact_to or (prefix.mod.minecraft .. args.block),
            ['factory'] = args.factory,
            ['recipe_shape'] = args.recipe_shape,
        })
    end

    register_compactable({ name = 'coal',         block = 'coal_block' })
    register_compactable({ name = 'iron_ingot',   block = 'iron_block',     factory = 'iron' })
    register_compactable({ name = 'gold_ingot',   block = 'gold_block',     factory = 'gold' })
    register_compactable({ name = 'diamond',      block = 'diamond_block' })
    register_compactable({ name = 'emerald',      block = 'emerald_block',  factory = 'emerald' })
    register_compactable({ name = 'quartz',       block = 'quartz_block',   count = 4 })
    register_compactable({ name = 'redstone',     block = 'redstone_block', factory = 'redstone' })
    register_compactable({ name = 'lapis_lazuli', block = 'lapis_block' })
    register_compactable({ name = 'clay_ball',    block = 'clay',           count = 4 })
    register_compactable({
        name = 'charcoal',
        compact_to = prefix.mod.mekanism .. 'block_charcoal',
        factory = 'furnace',
        recipe_shape = { prefix.mod.minecraft .. 'birch_log' },
    })

    register_new_item({
        ['full_name'] = prefix.mod.minecraft .. 'cobblestone',
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
        register_compactable({
            name = name,
            compact_to = 'allthecompressed:' .. name .. '_1x',
        })
    end

    register_stone('granite')
    register_stone('diorite')
    register_stone('andesite')
    register_stone('tuff')
    register_stone('cobbled_deepslate')
end
