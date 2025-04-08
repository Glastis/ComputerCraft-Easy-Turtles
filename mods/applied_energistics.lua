local applied_energistics = {}

local constant = require('common/constants')

local function refresh_item_list(force)
    if force or not applied_energistics.system_item_list then
        applied_energistics.system_item_list = applied_energistics.ae.listItems()
    end
end
applied_energistics.refresh_item_list = refresh_item_list

local function init(ae_peripheral_name)
    applied_energistics.ae = peripheral.wrap(ae_peripheral_name)
    refresh_item_list()
end
applied_energistics.init = init

local function search_items_with_condition_exec(item_name_list, condition_callback, condition_callback_data, on_true_return, on_true_callback, ...)
    local on_true_count

    on_true_count = 0
    refresh_item_list()
    for _, system_item in pairs(applied_energistics.system_item_list) do
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
applied_energistics.search_items_with_condition_exec = search_items_with_condition_exec

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
applied_energistics.search_items_with_condition = search_items_with_condition

local function search_items(item_name_list, minimum_amount, maximum_amount)
    return search_items_with_condition(item_name_list, function(item, min, max)
        return  (not min or min <= item.amount) and
                (not max or max >  item.amount)
    end, minimum_amount, maximum_amount)
end
applied_energistics.search_items = search_items

local function send_item_to(item_full_name, amount, peripheral_name)
    return applied_energistics.ae.exportItemToPeripheral({ ['name'] = item_full_name, ['count'] = amount }, peripheral_name)
end
applied_energistics.send_item_to = send_item_to
applied_energistics.move_item_to = send_item_to
applied_energistics.export_item_to = send_item_to

local function get_item_from(item_full_name, amount, peripheral_name)
    return applied_energistics.ae.importItemFromPeripheral({ ['name'] = item_full_name, ['count'] = amount }, peripheral_name)
end
applied_energistics.get_item_from = get_item_from

local function get_all_item_from(peripheral)
    local items_in_peripheral
    if type(peripheral) ~= 'string' then
        peripheral = peripheral.name
    end
    items_in_peripheral = factory.peripheral.list()
    for _, item in pairs(items_in_peripheral) do
        applied_energistics.ae.importItemFromPeripheral(item, peripheral)
    end
end
applied_energistics.get_all_item_from = get_all_item_from

return applied_energistics

