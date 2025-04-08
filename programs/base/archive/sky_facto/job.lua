---
--- User: glastis.
--- Date: 07-Feb-23
---

local job = {}

package.path = package.path .. ';/ComputerCraft/*/?.lua'

local applied_energistics = require 'mods.applied_energistics'
local item_registry = require 'programs.base.item_registry'

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
    applied_energistics.search_items_with_condition_exec(
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
    applied_energistics.search_items_with_condition_exec(
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
        local ret = applied_energistics.move_item_to(item.name, amount_to_trash, job.factories.trash.name)
        print(ret)
    end
end

local function check_ingredients(recipe_shape, amount_to_produce)
    for _, ingredient in pairs(recipe_shape) do
        local ingredient_amount = applied_energistics.get_item_amount(ingredient)
        if not ingredient_amount or ingredient_amount < amount_to_produce then
            print('Missing ingredient:', ingredient)
            return false
        end
    end
    return true
end

local function transfer_ingredients(recipe_shape, amount_to_produce, factory_name)
    for _, ingredient in pairs(recipe_shape) do
        applied_energistics.move_item_to(ingredient, amount_to_produce, factory_name)
    end
end

local function produce_with_recipe(item_info, amount_to_produce, factory)
    if not check_ingredients(item_info.recipe.shape, amount_to_produce) then
        return
    end
    transfer_ingredients(item_info.recipe.shape, amount_to_produce, factory.name)
    sleep(5)
    applied_energistics.import_items_from(factory.name)
end

local function produce_automatically(factory)
    sleep(5)
    applied_energistics.import_items_from(factory.name)
end

local function produce_missing()
    for _, item in pairs(job.to_produce) do
        print('Producing', item.name)
        local item_info = item_registry[item.name]
        if not item_info or not item_info.recipe or not item_info.recipe.factory then
            print('No recipe found for item:', item.name)
            goto continue
        end

        local factory = job.factories[item_info.recipe.factory]
        if not factory then
            print('Factory not found:', item_info.recipe.factory)
            goto continue
        end

        local amount_to_produce = item_info.wanted_min - item.amount
        if amount_to_produce <= 0 then
            goto continue
        end

        print('Need to produce', amount_to_produce, 'of', item.name)
        if item_info.recipe.shape then
            produce_with_recipe(item_info, amount_to_produce, factory)
        else
            produce_automatically(factory)
        end

        ::continue::
    end
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