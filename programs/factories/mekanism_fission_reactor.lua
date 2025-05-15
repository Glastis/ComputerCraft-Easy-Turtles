package.path = package.path .. ';/ComputerCraft/*/?.lua'
package.path = package.path .. ';/ComputerCraft/common/?.lua'

local container = require 'common.container'
local prefixes = require 'common.const.prefixes'

local peripheral_names = {}
local item_names = {}
local routes = {}

local MAIN_LOOP_DELAY = 5
local last_state = false

local function check_peripheral_connection(peripheral_name)
    if type(peripheral_name) == 'table' then
        for _, p in pairs(peripheral_name) do
            check_peripheral_connection(p)
        end
        return
    end
    if not peripheral.wrap(peripheral_name) then
        print('Peripheral ' .. peripheral_name .. ' not found')
        error()
    end
end

local function init()
    peripheral_names.fission_reactor_rs = 'redstoneIntegrator_0'
    peripheral_names.turbine = 'turbineValve_0'
end

local function set_reactor_state(state)
    if last_state == state then
        return
    end
    last_state = state
    print(os.date("%H:%M") .. ": " .. (state and "ON" or "OFF"))
    local rs = peripheral.wrap(peripheral_names.fission_reactor_rs)
    rs.setOutput("back", not state)
end

local function is_turbine_full()
    local turbine = peripheral.wrap(peripheral_names.turbine)
    return turbine.getEnergy() >= turbine.getMaxEnergy() * 0.90
end

local function manage_reactor()
    if is_turbine_full() then
        set_reactor_state(false)
    else
        set_reactor_state(true)
    end
end

local function main()
    init()
    check_peripheral_connection(peripheral_names)
    set_reactor_state(false)
    while true do
        manage_reactor()
        sleep(MAIN_LOOP_DELAY)
    end
end

main()