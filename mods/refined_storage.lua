local refined_storage = {}

local constant = require('common/constants')

local function refresh_item_list(force)
    if force or not refined_storage.system_item_list then
        refined_storage.system_item_list = refined_storage.rs.listItems()
    end
end
refined_storage.refresh_item_list = refresh_item_list

local function init(rs_peripheral_name)
    refined_storage.rs = peripheral.wrap(rs_peripheral_name)
    refresh_item_list()
end
refined_storage.init = init

local function search_items_with_condition_exec(item_name_list, condition_callback, condition_callback_data, on_true_return, on_true_callback, ...)
    local on_true_count

    on_true_count = 0
    refresh_item_list()
    for _, system_item in pairs(refined_storage.system_item_list) do
        for _, provided_item_name in pairs(item_name_list) do
            if  system_item.name == provided_item_name and
                ((type(condition_callback_data) == 'table') and condition_callback(system_item, table.unpack(condition_callback_data)) or
                ( type(condition_callback_data) ~= 'table') and condition_callback(system_item, condition_callback_data)) then
                system_item.amount = tonumber(system_item.amount)
                if on_true_return then
                    return on_true_callback(system_item, ...)
                end
                on_true_callback(system_item, ...)
            end
        end
    end
    return on_true_count
end
refined_storage.search_items_with_condition_exec = search_items_with_condition_exec

local function search_items_with_condition(item_name_list, condition_callback, ...)
    local found_items
    local found_amount

    found_items = {}
    found_amount = search_items_with_condition_exec(item_name_list, condition_callback, {...}, true, function(item, ...)
        found_items[item.name] = {}
        found_items[item.name].name = item.name
        found_items[item.name].count = item.amount
        found_items[item.name].fingerprint = item.fingerprint
    end)
    return found_items, found_amount == #item_name_list
end
refined_storage.search_items_with_condition = search_items_with_condition

local function search_items(item_name_list, minimum_amount, maximum_amount)
    return search_items_with_condition(item_name_list, function(item, min, max)
        return  (not min or min <= item.amount) and
                (not max or max >  item.amount)
    end, minimum_amount, maximum_amount)
end
refined_storage.search_items = search_items

local function send_item_to(item_full_name, amount, peripheral_name)
    return refined_storage.rs.exportItemToPeripheral({ ['name'] = item_full_name, ['count'] = amount }, peripheral_name)
end
refined_storage.send_item_to = send_item_to
refined_storage.move_item_to = send_item_to
refined_storage.export_item_to = send_item_to

local function get_item_from(item_full_name, amount, peripheral_name)
    return refined_storage.rs.importItemFromPeripheral({ ['name'] = item_full_name, ['count'] = amount }, peripheral_name)
end
refined_storage.get_item_from = get_item_from

local function get_all_item_from(peripheral)
    local items_in_peripheral
    if type(peripheral) ~= 'string' then
        peripheral = peripheral.name
    end
    items_in_peripheral = factory.peripheral.list()
    for _, item in pairs(items_in_peripheral) do
        refined_storage.importItemFromPeripheral(item, peripheral)
    end
end
refined_storage.get_all_item_from = get_all_item_from


return refined_storage