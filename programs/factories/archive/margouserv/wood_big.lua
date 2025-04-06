package.path = package.path .. ';/ComputerCraft/*/?.lua'
package.path = package.path .. ';/ComputerCraft/common/?.lua'

local container = require 'common.container'
local inventory = require 'common.inventory'
local prefixes = require 'common.const.prefixes'

local peripheral_names = {}
local item_names = {}
local routes = {}

local MAIN_LOOP_DELAY = 30

local function check_peripheral_connection()
    for _, name in pairs(peripheral_names) do
        if not peripheral.wrap(name) then
            print('Peripheral ' .. name .. ' not found')
            error()
        end
    end
end

local function init()
    peripheral_names.redstone_clutch = prefixes.redstone .. '4'
    peripheral_names.storage_interface = prefixes.portable_storage_interface .. '1'
    peripheral_names.ender_chest = prefixes.ender_chest .. '3'
    peripheral_names.inventory_connector = prefixes.inventory_connector .. '3'

    item_names = {}
    item_names.birch_log = 'minecraft:birch_log'
    item_names.birch_sapling = 'minecraft:birch_sapling'
    item_names.stick = 'minecraft:stick'
    item_names.charcoal = 'minecraft:charcoal'
    item_names.charcoal_block = 'thermal:charcoal_block'

    check_peripheral_connection()
end

local function route_item(from, to)
    local transfered_count

    transfered_count = 1
    print('Routing all items from ' .. string.match(from, '_(.*)') .. ' to ' .. string.match(to, '_(.*)'))
    while transfered_count > 0 do
        transfered_count = container.transfer_all(from, to)
    end
end

local function transfer_to_ender_chest(dont_wait)
    if not dont_wait then
        sleep(2)
    end
    route_item(peripheral_names.inventory_connector, peripheral_names.ender_chest)
end

local function wait_storage_interface()
    os.pullEvent('redstone')
    if not rs.getInput('bottom') then
        route_item(peripheral_names.storage_interface, peripheral_names.inventory_connector)
        transfer_to_ender_chest(true)
    end
end

local function main()
    local portable_storage

    init()

    while true do
        parallel.waitForAny(wait_storage_interface, transfer_to_ender_chest)
    end
end

main()