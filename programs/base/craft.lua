local craft
craft = {}

local inventory = require('common/inventory')
local side = require('common/sides')
local constant = require('common/constants')

local function craft_item_insert(rs_items, result_item)
    local i

    i = 1
    while i <= #result_item.recipe.shape do
        refined_storage.exportItemToPeripheral(rs_items[result_item.recipe.shape[i]], result_item.recipe.factory.name)
        i = i + 1
    end
end
craft.craft_item_insert = craft_item_insert

local function empty_factory(factory)
    local items_in_factory

    items_in_factory = factory.peripheral.list()
    for _, item in pairs(items_in_factory) do
        refined_storage.importItemFromPeripheral(item, factory.name)
    end
end
craft.empty_factory = empty_factory

local function craft_wait_item(result_item, watch_every, timeout)
    local i
    local items_in_factory

    i = watch_every
    sleep(watch_every)
    while i < timeout do
        items_in_factory = result_item.recipe.factory.peripheral.list()
        for _, item in pairs(items_in_factory) do
            if item.name == result_item.full_name or result_item.recipe.coproducts and utils.is_elem_in_table(result_item.recipe.coproducts, item.name) then
                return true
            end
        end
        sleep(watch_every)
        i = i + watch_every
    end
    error('[' .. os.date() .. '] Timeout while crafting ' .. result_item.full_name)
    return false
end

local function turtle_store_inventory(peripheral_storage)
    if inventory.drop_all(side.labels.down) then
        refined_storage.get_all_item_from(peripheral_storage)
    end
end

local function compact(item, peripheral_in, peripheral_out)
    local i
    local line

    turtle_store_inventory(peripheral_out)
    refined_storage.send_item_to(item, 64 * item.compactable,peripheral_in)
    i = 1
    line = 0
    while line < item.compactable do
        turtle.select((line * constant.TURTLE_INVENTORY_COLUMN) + i)
        turtle.suck()
        if turtle.getItemCount() ~= 64 then
            turtle_store_inventory(peripheral_out)
        end
        i = i + 1
        if i >item.compactable then
            i = 1
            line = line + 1
        end
    end
end

local function craft_item(result_item, amount, rs_storage)
    local i
    local rs_items

    i = 0
    rs_items = search_items_from_rs(rs_storage, result_item.recipe.shape, amount)
    if not rs_items then
        print('[' .. os.date() .. '] Not enough items to craft ' .. result_item.full_name)
        return false
    end
    empty_factory(result_item.recipe.factory)
    while i < amount do
        craft_item_insert(rs_items, result_item)
        craft_wait_item(result_item, 5, 500)
        empty_factory(result_item.recipe.factory)
        i = i + 1
    end
    return true
end
craft.craft_item = craft_item

return craft