package.path = package.path .. ';/ComputerCraft/*/?.lua'
package.path = package.path .. ';/ComputerCraft/common/?.lua'

local applied_energistics = require 'mods.applied_energistics'

local overflow_handlers = {}

function overflow_handlers.move_to(item, amount, args)
    return applied_energistics.move_item_to(item.name, amount, args.peripheral)
end

function overflow_handlers.craft_ae(item, amount, args)
    local count = math.ceil(amount / (args.ratio or 1))
    return applied_energistics.ae.craftItem({ name = args.target, count = count })
end

return overflow_handlers
