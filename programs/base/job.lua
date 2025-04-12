local job = {}

package.path = package.path .. ';/ComputerCraft/*/?.lua'
package.path = package.path .. ';/ComputerCraft/common/?.lua'

local applied_energistics = require 'mods.applied_energistics'
local item_registry = require 'programs.base.item_registry'
local utils = require 'common.utils'
local factories = require 'programs.base.factories'

local function init(storage_peripheral_name, factories)
    applied_energistics.init(storage_peripheral_name)
    job.factories = factories
end
job.init = init

local function add_missing_items(item_name_list)
    local found

    applied_energistics.refresh_item_list(true)
    for _, item in pairs(item_name_list) do
        found = false
        for _, system_item in pairs(applied_energistics.system_item_list) do
            if system_item.name == item then
                found = true
                break
            end
        end
        if not found then
            applied_energistics.system_item_list[#applied_energistics.system_item_list + 1] = {
                name = item,
                count = 0
            }
        end
    end
end

local function right_align(text, width)
    local spaces = width - #text
    return string.rep(" ", spaces) .. text
end

local function print_aligned(left_text, right_text)
    local width = term.getSize()
    local padding = width - #left_text - #right_text
    print(left_text .. string.rep(" ", padding) .. right_text)
end

local function build_job_list()
    applied_energistics.refresh_item_list(true)
    add_missing_items(item_registry.list)
    job.to_purge = {}
    job.to_produce = {}
    job.to_compact = {}
    job.to_import = {}
    job.to_export = {}
    applied_energistics.search_items_with_condition_exec(
            item_registry.purgeable_overflow_list,
            function(item)
                return item.count > item_registry[item.name].wanted_max and 
                    not item_registry[item.name].compactable
            end,
            nil,
            false,
            function(item)
                job.to_purge[#job.to_purge + 1] = item
            end
    )
    applied_energistics.search_items_with_condition_exec(
            item_registry.craftable_list,
            function(item)
                print_aligned(
                    item_registry[item.name].full_name,
                    item.count .. '/' .. item_registry[item.name].wanted_min
                )
                return item.count < item_registry[item.name].wanted_min and
                    item_registry[item.name].recipe
            end,
            nil,
            false,
            function(item)
                job.to_produce[#job.to_produce + 1] = item
            end
    )
    applied_energistics.search_items_with_condition_exec(
            item_registry.compactable_list,
            function(item)
                return item.count > item_registry[item.name].wanted_max
            end,
            nil,
            false,
            function(item)
                job.to_compact[#job.to_compact + 1] = item
            end
    )
    print('To purge', #job.to_purge, ' | To produce', #job.to_produce, ' | To compact', #job.to_compact)
end
job.build_job_list = build_job_list

local function trash_overflow()
    local amount_to_trash

    for _, item in pairs(job.to_purge) do
        print('Trashing', item.name)
        amount_to_trash = tonumber(item.count - item_registry[item.name].wanted_max)
        local ret = applied_energistics.move_item_to(item.name, amount_to_trash, job.factories.trash.name)
    end
end

local function produce_missing()
    local tocraft
    local ret

    for _, item in pairs(job.to_produce) do
        print('Producing', item.name)
        tocraft = {
            name = item.name,
            count = item_registry[item.name].wanted_min - item.count
        }
        ret = job.factories.craft(item.name, item_registry[item.name].wanted_min - item.count)
        if ret then
            item.count = item_registry[item.name].wanted_min
        elseif ret == nil then
            print('Recipe does not exist')
        else
            print('Recipe exists but failed')
        end
    end
end

local function compact()
    local tocraft
    local ret

    for _, item in pairs(job.to_compact) do
        print('Compacting', item.name)
        tocraft = {
            name = item_registry[item.name].compact_to,
            count = math.ceil((item.count - item_registry[item.name].wanted_max) / item_registry[item.name].compactable)
        }
        ret = applied_energistics.ae.craftItem(tocraft)
        if ret then
            item.count = item.count - tocraft.count * item_registry[item.name].compactable
        elseif ret == nil then
            print('Recipe does not exist')
        else
            print('Recipe exists but failed')
        end
    end
end

local function route_items()
    for _, item in pairs(item_registry.sendable_list) do
        print('Routing', item)
        while applied_energistics.move_item_to(item, 64, factories[item_registry[item].send_to].name) > 0 do end
    end
end

local function exec_job_list()
    produce_missing()
    compact()
    route_items()
    trash_overflow()
end
job.exec_job_list = exec_job_list

return job