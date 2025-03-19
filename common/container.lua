local constants = require 'constants'
local utils = require 'utils'

local container = {}

local function safe_wrap_container(name, require_list, require_pull)
    local wrap

    if not name then
        print('safe_wrap_container: No peripheral name provided')
        return false
    end
    wrap = peripheral.wrap(name)
    if not wrap then
        print('Peripheral ' .. name .. ' not found')
        return false
    end
    if require_list and not wrap.list then
        print('Peripheral ' .. name .. ' is not a container')
        return false
    end
    if  require_pull and not wrap.pullItems then
        print('Peripheral ' .. name .. ' is not a container with pullItems method')
        return false
    end
    return wrap
end
container.safe_wrap_container = safe_wrap_container

local function transfer_all(from, to, item_blacklist)
    local from_wrap
    local to_wrap
    local moved_count
    local total_moved_count
    local list

    from_wrap = safe_wrap_container(from, true, true)
    to_wrap = safe_wrap_container(to, true, true)
    if not from_wrap or not to_wrap then
        return 0
    end
    total_moved_count = 0
    list = from_wrap.list()
    if not list then
        print('Could not get chest item list')
        return 0
    end
    for i, item in pairs(list) do
        if not item_blacklist or not utils.is_elem_in_table(item_blacklist, item.name) then
            moved_count = to_wrap.pullItems(from, i)
            total_moved_count = total_moved_count + moved_count
        end
    end
    return total_moved_count
end
container.transfer_all = transfer_all

--[[
---- Transfer an item from one inventory to another
----
---- @param from      peripheral, the peripheral name from which the item is taken
---- @param to        peripheral, the peripheral name to which the item is sent
---- @param item      table, the item to transfer
---- @param quantity  number, the quantity of the item to transfer
---- @return          number, the quantity of the item transferred
--]]
local function transfer_item(from, to, item_name, quantity, item_blacklist)
    local from_wrap
    local to_wrap
    local moved_count
    local total_moved_count
    local quantity_left
    local list

    from_wrap = safe_wrap_container(from, true, true)
    to_wrap = safe_wrap_container(to, false, false)
    if not from_wrap or not to_wrap then
        return 0
    end

    quantity_left = quantity or constants.MAX_STACK_SIZE_IN_MODPACK
    total_moved_count = 0
    list = from_wrap.list()
    if not list then
        print('Could not get chest item list')
        return 0
    end
    for i, item in pairs(list) do
        if item and (item.name == item_name or not item_name) and (not item_blacklist or not utils.is_elem_in_table(item_blacklist, item.name)) then
            if quantity then
                moved_count = to_wrap.pullItems(from, i, quantity_left)
            else
                return to_wrap.pullItems(from, i)
            end
            if moved_count ~= item.count then
                return total_moved_count + moved_count
            end
            quantity_left = quantity_left - moved_count
            total_moved_count = total_moved_count + moved_count
        end
        i = i + 1
    end
    return total_moved_count
end
container.transfer_item = transfer_item

local function transfer_item_to_turtle(from, turtle, item, quantity, slot)
    local from_wrap
    local chest_size
    local moved_count
    local moved_total
    local i

    from_wrap = safe_wrap_container(from, true, true)
    if not from_wrap then
        return 0
    end
    chest_size = from_wrap.size()
    if not chest_size then
        print('Could not get ' .. from .. ' size')
        return 0
    end
    if not quantity then
        quantity = constants.MAX_STACK_SIZE_IN_MODPACK
    end
    i = 1
    moved_total = 0
    while i <= chest_size do
        local chest_item = from_wrap.getItemDetail(i)
        if chest_item and (chest_item.name == item or not item) then
            moved_count = from_wrap.pushItems(turtle, i, quantity - moved_total, slot)
            moved_total = moved_total + moved_count
            if moved_count == 0 or moved_total >= quantity then
                return moved_total
            end
        end
        i = i + 1
    end
    return moved_total
end
container.transfer_item_to_turtle = transfer_item_to_turtle

local function transfer_item_from_turtle(turtle, from_slot, to, item, quantity, to_slot)
    local to_wrap
    local chest_size
    local moved_count
    local moved_total
    local i

    to_wrap = safe_wrap_container(to, true, true)
    if not to_wrap then
        return 0
    end
    if to_slot then
        return to_wrap.pullItems(turtle, from_slot, quantity, to_slot)
    end
    chest_size = to_wrap.size()
    if not chest_size then
        print('Could not get ' .. to .. ' size')
        return 0
    end
    if not quantity then
        quantity = constants.MAX_STACK_SIZE_IN_MODPACK
    end
    i = 1
    moved_total = 0
    while i <= chest_size do
        local chest_item = to_wrap.getItemDetail(i)
        if not chest_item or (chest_item.name == item and chest_item.count < constants.MAX_STACK_SIZE_IN_MODPACK) then
            moved_count = to_wrap.pullItems(turtle, from_slot, quantity - moved_total, i)
            moved_total = moved_total + moved_count
            if moved_count == 0 or moved_total >= quantity then
                return moved_total
            end
        end
        i = i + 1
    end
    return moved_total
end
container.transfer_item_from_turtle = transfer_item_from_turtle

local function count_empty_slots(peripheral_name)
    local wrap
    local count
    local chest_size

    wrap = safe_wrap_container(peripheral_name, true, false)
    if not wrap then
        return 0
    end
    count = 0
    chest_size = wrap.size()
    for i = 1, chest_size do
        if not wrap.getItemDetail(i) then
            count = count + 1
        end
    end
    return count
end
container.count_empty_slots = count_empty_slots

local function is_full(peripheral_name, require_filled_stack)
    local wrap
    local chest_size
    local item

    if require_filled_stack == nil then
        require_filled_stack = false
    end
    wrap = safe_wrap_container(peripheral_name, true, false)
    if not wrap then
        return false
    end
    chest_size = wrap.size()
    for i = 1, chest_size do
        item = wrap.getItemDetail(i)
        if not item or
        (require_filled_stack and item.count < item.maxCount) then
            return false
        end
    end
    return true
end
container.is_full = is_full

local function is_empty(peripheral_name)
    local wrap
    local chest_size
    local item

    wrap = safe_wrap_container(peripheral_name, true, false)
    if not wrap then
        return false
    end
    chest_size = wrap.size()
    for i = 1, chest_size do
        item = wrap.getItemDetail(i)
        if item then
            return false
        end
    end
    return true
end
container.is_empty = is_empty

local function get_all_items(peripheral_name)
    local contents
    local wrap
    local items

    wrap = safe_wrap_container(peripheral_name, true, false)
    if not wrap then
        return {}
    end
    contents = wrap.list()
    items = {}
    for slot, item in pairs(contents) do
        if not items[item.name] then
            items[item.name] = item.count
        else
            items[item.name] = items[item.name] + item.count
        end
    end
    return items
end
container.get_all_items = get_all_items

local function count_item(peripheral_name, item_name)
    local contents
    local wrap
    local count

    wrap = safe_wrap_container(peripheral_name, true, false)
    if not wrap then
        return 0
    end
    contents = wrap.list()
    count = 0
    for slot, item in pairs(contents) do
        if item.name == item_name then
            count = count + item.count
        end
    end
    return count
end
container.count_item = count_item

return container