local constants = require 'constants'
local utilities = require 'utils'

local parsing = {}

local function _parse_inventory_init(inventory_info)
    if not inventory_info then
        inventory_info = {}
    end
    if not inventory_info.inventory_size then
        inventory_info.inventory_size = constants.TURTLE_INVENTORY_SIZE
    end
    if not inventory_info.from_slot then
        inventory_info.from_slot = 1
    end
    if not inventory_info.to_slot then
        inventory_info.to_slot = inventory_info.inventory_size
    end
    if not inventory_info.step then
        inventory_info.step = 1
    end
    if inventory_info.step == 0 or
       (inventory_info.step > 0 and inventory_info.from_slot > inventory_info.to_slot) or
       (inventory_info.step < 0 and inventory_info.from_slot < inventory_info.to_slot) then
        print('from_slot: ' .. from_slot .. ', to_slot: ' .. to_slot .. ', step: ' .. step)
        error('Error: _parse_inventory_init: step is set to 0 or is incompatible with other arguments')
    end
    return inventory_info
end

local function parse_inventory(f_condition, f_get_slot_details, inventory_info, return_on_success, callback, callback_args)
    local detail
    local i
    local retval

    inventory_info = _parse_inventory_init(inventory_info)
    i = inventory_info.from_slot
    while i <= inventory_info.inventory_size and i > 0 and
          (     ((inventory_info.step > 0) and i <= inventory_info.to_slot) or
                ((inventory_info.step < 0) and i >= inventory_info.to_slot)) do
        detail = f_get_slot_details(i)
        if f_condition(detail) then
            retval = true
            if callback_args then
                retval = callback(i, table.unpack(callback_args))
            else
                retval = callback(i)
            end
            if return_on_success then
                return retval
            end
        end
        i = i + inventory_info.step
    end
    return false
end
parsing.parse_inventory = parse_inventory

return parsing