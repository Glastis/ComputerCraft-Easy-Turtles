---
--- User: glastis.
--- Date: 26-Feb-23
---

local periph = {}

local function is_containing_item(storage, item_name)
    local items

    items = storage.list()
    if not items or #items == 0 then
        return false
    end
    for _, item in ipairs(items) do
        if item.name == item_name then
            return true
        end
    end
    return false
end
periph.is_containing_item = is_containing_item

local function wrap_peripheral_range(prefix, from, to)
    local peripherals

    peripherals = {}
    for i = from, to do
        peripherals[#peripherals + 1] = peripheral.wrap(prefix .. i)
    end
    return peripherals
end
periph.wrap_peripheral_range = wrap_peripheral_range

return periph