---
--- User: glastis.
--- Date: 07-Feb-23
---

local job = {}

package.path = package.path .. ';/ComputerCraft/*/?.lua'

local refined_storage = require 'mods.refined_storage'
local item_registry = require 'programs.base.item_registry'

local function init(rs_peripheral_name, factories)
    refined_storage.init(rs_peripheral_name)
    job.factories = factories
end
job.init = init

local function build_job_list()
    refined_storage.refresh_item_list(true)
    job.to_purge = {}
    job.to_produce = {}
    job.to_compact = {}
    job.to_import = {}
    job.to_export = {}
    refined_storage.search_items_with_condition_exec(
            item_registry.purge,
            function(item)
                return item.amount > item_registry[item.name].wanted_max and not item_registry[item.name].compactable
            end,
            nil,
            false,
            function(item)
                job.to_purge[#job.to_purge + 1] = item
            end
    )
    refined_storage.search_items_with_condition_exec(
            item_registry.purge,
            function(item)
                return item.amount < item_registry[item.name].wanted_min
            end,
            nil,
            false,
            function(item)
                job.to_produce[#job.to_produce + 1] = item
            end
    )
    refined_storage.search_items_with_condition_exec(
            item_registry.purge,
            function(item)
                return item.amount > item_registry[item.name].wanted_min and item.amount < item_registry[item.name].wanted_max and item_registry[item.name].compactable
            end,
            nil,
            false,
            function(item)
                job.to_compact[#job.to_compact + 1] = item
            end
    )

end
job.build_job_list = build_job_list

local function trash_overflow()
    local amount_to_trash

    for _, item in pairs(job.to_purge) do
        require('utils').var_dump(item, true)
        amount_to_trash = tonumber(item.amount - item_registry[item.name].wanted_max)
        print(job.factories.trash.name)
        local ret = refined_storage.move_item_to(item.name, amount_to_trash, job.factories.trash.name)
        print(ret)
    end
end

local function produce_missing()

end

local function compact()

end

local function exec_job_list()
    trash_overflow()
    compact()
    produce_missing()
end
job.exec_job_list = exec_job_list

return job