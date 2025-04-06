local job = {}

package.path = package.path .. ';/ComputerCraft/*/?.lua'

local applied_energistics = require 'mods.applied_energistics'
local item_registry = require 'programs.base.item_registry'
local utils = require 'common.utils'

local function init(rs_peripheral_name, factories)
    applied_energistics.init(rs_peripheral_name)
    job.factories = factories
end
job.init = init

local function build_job_list()
    applied_energistics.refresh_item_list(true)
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
            item_registry.list,
            function(item)
                return item.count < item_registry[item.name].wanted_min and
                    #item_registry[item.name].recipe > 0
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
                print('item', item_registry[item.name].full_name)
                return item.count > item_registry[item.name].wanted_max
            end,
            nil,
            false,
            function(item)
                job.to_compact[#job.to_compact + 1] = item
            end
    )
    print('len to_purge', #job.to_purge)
    print('len to_produce', #job.to_produce)
    print('len to_compact', #job.to_compact)
end
job.build_job_list = build_job_list

local function trash_overflow()
    local amount_to_trash

    for _, item in pairs(job.to_purge) do
        print('Trashing', item.name)
        amount_to_trash = tonumber(item.count - item_registry[item.name].wanted_max)
        local ret = applied_energistics.move_item_to(item.name, amount_to_trash, job.factories.trash.name)
        print(ret)
    end
end

local function produce_missing()
    for _, item in pairs(job.to_produce) do
        print('Producing', item.name)
        local tocraft = {
            name = item.name,
            count = item.count
        }
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

local function exec_job_list()
    produce_missing()
    compact()
    trash_overflow()
end
job.exec_job_list = exec_job_list

return job