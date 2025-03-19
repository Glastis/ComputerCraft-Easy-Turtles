local trash
local hopper
local storage

local SLEEP_BETWEEN_STORAGE = 15

local function p_name(periph)
    return peripheral.getName(periph)
end

local function init()
    local trash_list

    trash = peripheral.wrap('trashcans:item_trash_can_tile_0')
    hopper = peripheral.wrap('mob_grinding_utils:absorption_hopper_0')
    storage = {}
    storage['minecraft:gunpowder'] =                    peripheral.wrap('minecraft:barrel_7')
    storage['ars_nouveau:wilden_wing'] =                peripheral.wrap('minecraft:barrel_8')
    storage['minecraft:bone'] =                         peripheral.wrap('minecraft:barrel_9')
    storage['minecraft:arrow'] =                        peripheral.wrap('minecraft:barrel_10')
    storage['minecraft:rotten_flesh'] =                 peripheral.wrap('minecraft:barrel_11')
    storage['elementalcraft:earth_shard'] =             peripheral.wrap('minecraft:barrel_12')
    storage['elementalcraft:powerful_earth_shard'] =    peripheral.wrap('minecraft:barrel_13')
    storage['elementalcraft:fire_shard'] =              peripheral.wrap('minecraft:barrel_14')
    storage['elementalcraft:powerful_fire_shard'] =     peripheral.wrap('minecraft:barrel_15')
    storage['bhc:red_heart'] =                          peripheral.wrap('minecraft:barrel_16')
    storage['everlastingabilities:ability_totem'] =     peripheral.wrap('minecraft:barrel_17')
    storage['minecraft:ender_pearl'] =                  peripheral.wrap('minecraft:barrel_18')
    storage['ars_nouveau:wilden_horn'] =                peripheral.wrap('minecraft:barrel_19')
    storage['elementalcraft:air_shard'] =               peripheral.wrap('minecraft:barrel_20')
    storage['elementalcraft:powerful_air_shard'] =      peripheral.wrap('minecraft:barrel_21')

    trash_list = {
        'supplementaries:quiver',
        'minecraft:leather_boots',
        'minecraft:leather_chestplate',
        'minecraft:leather_helmet',
        'minecraft:leather_leggings',
        'minecraft:bow',
        'minecraft:iron_ingot',
        'forcecraft:pile_of_gunpowder',
        'minecraft:golden_leggings',
        'minecraft:golden_boots',
        'minecraft:golden_helmet',
        'minecraft:golden_chestplate',
        'minecraft:glass_bottle',
        'mekanismtools:lapis_lazuli_helmet',
        'mekanismtools:lapis_lazuli_boots',
        'mekanismtools:lapis_lazuli_sword',
        'mekanismtools:osmium_sword',
        'mekanismtools:osmium_pickaxe',
        'mekanismtools:osmium_axe',
        'mekanismtools:osmium_shovel',
        'mekanismtools:osmium_hoe',
        'mekanismtools:osmium_helmet',
        'mekanismtools:osmium_boots',
        'mekanismtools:osmium_chestplate',
        'mekanismtools:osmium_leggings',
        'mekanismtools:steel_helmet',
        'mekanismtools:steel_boots',
        'mekanismtools:steel_chestplate',
        'mekanismtools:steel_leggings',
        'mekanismtools:steel_sword',
        'mekanismtools:steel_pickaxe',
        'mekanismtools:steel_axe',
        'mekanismtools:steel_shovel',
        'mekanismtools:refined_obsidian_helmet',
        'mekanismtools:refined_obsidian_boots',
        'mekanismtools:refined_obsidian_chestplate',
        'mekanismtools:refined_obsidian_leggings',
        'mekanismtools:refined_obsidian_sword',
        'mekanismtools:refined_obsidian_pickaxe',
        'mekanismtools:refined_obsidian_axe',
        'minecraft:iron_boots',
        'minecraft:iron_sword',
        'minecraft:iron_helmet',
        'minecraft:iron_chestplate',
        'minecraft:iron_leggings',
        'minecraft:golden_sword',
        'minecraft:golden_pickaxe',
        'minecraft:golden_axe',
        'minecraft:golden_shovel',
        'minecraft:golden_hoe',
        'minecraft:stone_sword',
        'minecraft:stone_pickaxe',
        'minecraft:stone_axe',
        'minecraft:stone_shovel',
        'minecraft:stone_hoe',
        'minecraft:wooden_sword',
        'minecraft:wooden_pickaxe',
        'minecraft:wooden_axe',
        'minecraft:wooden_shovel',
        'minecraft:wooden_hoe',
        'minecraft:chainmail_boots',
        'minecraft:chainmail_leggings',
        'minecraft:chainmail_chestplate',
        'minecraft:chainmail_helmet',
        'minecraft:potion',
        'minecraft:redstone',
        'minecraft:glowstone_dust',
        'minecraft:carrot',
        'minecraft:potato',
        'minecraft:stick',
        'minecraft:sugar',
        'minecraft:iron_shovel'
    }
    for _, item in pairs(trash_list) do
        storage[item] = trash
    end
end

local function store_items()
    local i
    local size
    local item

    size = hopper.size()
    i = 2
    while i <= size do
        item = hopper.getItemDetail(i)
        if item and storage[item.name] then
            if hopper.pushItems(p_name(storage[item.name]), i) == 0 then
                storage[item.name].pushItems(p_name(trash), i)
            end
            print('Stored ' .. item.name)
        end
        i = i + 1
    end
end

local function main()
    while true do
        store_items()
        os.sleep(SLEEP_BETWEEN_STORAGE)
    end
end

init()
main()