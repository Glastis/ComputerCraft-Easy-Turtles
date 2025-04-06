
package.path = package.path .. ';/ComputerCraft/*/?.lua'
package.path = package.path .. ';/ComputerCraft/common/?.lua'

local job = require 'programs.base.job'
local factories = require 'programs.base.factories'

local DELAY_BUILD_JOB_LIST = 5
local DELAY_EXEC_JOB_LIST = 6

local function init()
    local events

    job.init('meBridge_0', factories)
    events = {}
    events[#events + 1] = { ['callback'] = job.build_job_list, ['delay'] = DELAY_BUILD_JOB_LIST }
    events[#events + 1] = { ['callback'] = job.exec_job_list, ['delay'] = DELAY_EXEC_JOB_LIST }
    return events
end

local function main()
    local clock
    local events

    clock = 0
    events = init()
    while true do
        for _, event in pairs(events) do
            if clock % event.delay == 0 then
                event.callback()
            end
        end
        clock = clock + 1
        os.sleep(1)
    end
end

main()