---
--- User: glastis.
--- Date: 31-Dec-22
---

package.path = package.path .. ';/ComputerCraft/*/?.lua'

local sides = require 'common.sides'
local buttons = require 'graphics.button'

local BUTTON_WIDTH = 13
local BUTTON_HEIGHT = 1

local stairs
local elevator
local control_panels
local click_button

local function init()
    stairs = {}
    local tmp

    tmp = {}
    tmp.label = 'Complex lvl 1'
    tmp.display = peripheral.wrap('monitor_3')
    tmp.command = peripheral.wrap('monitor_5')
    tmp.detector = peripheral.wrap('redstoneIntegrator_2')
    stairs[#stairs + 1] = tmp

    tmp = {}
    tmp.label = 'Complex lvl 2'
    tmp.display = peripheral.wrap('monitor_2')
    tmp.command = peripheral.wrap('monitor_8')
    tmp.detector = peripheral.wrap('redstoneIntegrator_3')
    stairs[#stairs + 1] = tmp

    tmp = {}
    tmp.label = 'Complex lvl 3'
    tmp.display = peripheral.wrap('monitor_1')
    tmp.command = peripheral.wrap('monitor_6')
    tmp.detector = peripheral.wrap('redstoneIntegrator_4')
    stairs[#stairs + 1] = tmp

    tmp = {}
    tmp.label = 'Surface'
    tmp.display = peripheral.wrap('monitor_4')
    tmp.command = peripheral.wrap('monitor_7')
    tmp.detector = peripheral.wrap('redstoneIntegrator_5')
    stairs[#stairs + 1] = tmp
    current_stair = -1

    control_panels = {}
    for i = 1, #stairs do
        control_panels[i] = stairs[i].command
        control_panels[i].clear()
        control_panels[i].setTextScale(0.5)
    end

    elevator = {}
    elevator._direction = peripheral.wrap('redstoneIntegrator_6')
    elevator._movement = peripheral.wrap('redstoneIntegrator_7')
    elevator.move = function (direction)
        if direction == sides.up then
            elevator._direction.setOutput(sides.labels[sides.back], false)
        elseif direction == sides.down then
            elevator._direction.setOutput(sides.labels[sides.back], true)
        end
        elevator._movement.setOutput(sides.labels[sides.back], false)
    end
    elevator.stop = function ()
        elevator._movement.setOutput(sides.labels[sides.back], true)
    end

    click_button = {}
end

local function write_on_middle_of_line(monitor, line, str)
    local x
    local y

    x, y = monitor.getSize()
    if not line then
        line = math.floor(y / 2)
    end
    x = math.floor((x - #str) / 2) + 1
    monitor.setCursorPos(x, line)
    monitor.write(str)
end

local function update_stair_monitoring(moving_direction, last_stair_id)
    local i
    local x
    local y

    i = 1
    while i <= #stairs do
        stairs[i].display.clear()
        stairs[i].display.setTextScale(0.5)
        stairs[i].display.setCursorPos(1, 1)
        x, y = stairs[i].display.getSize()
        if moving_direction == sides.up then
            write_on_middle_of_line(stairs[i].display, 2, '^')
            write_on_middle_of_line(stairs[i].display, 3, '^')
        end
        write_on_middle_of_line(stairs[i].display, nil, stairs[last_stair_id].label)
        if moving_direction == sides.down then
            write_on_middle_of_line(stairs[i].display, y - 3, 'v')
            write_on_middle_of_line(stairs[i].display, y - 2, 'v')
        end
        i = i + 1
    end
    return true
end

local function draw_buttons_grid(count, columns_count)
    local terminal_width
    local terminal_height

    terminal_width, terminal_height = control_panels[1].getSize()
    terminal_width = terminal_width + 1
    for i = 1, count do
        click_button[i] = buttons.create_and_draw_button(
                math.floor((terminal_width / columns_count) * ((i - 1) % columns_count)) + math.floor((terminal_width / columns_count - BUTTON_WIDTH) / 2) + 1,
                math.floor((terminal_height / math.ceil(count / columns_count)) * math.floor((i - 1) / columns_count)) + math.floor((terminal_height / math.ceil(count / columns_count) - BUTTON_HEIGHT) / 2) + 2,
                BUTTON_WIDTH,
                BUTTON_HEIGHT,
                stairs[#stairs - i + 1].label,
                colors.green,
                control_panels
        )
    end
end

local function wait_stair_event(stair_id, timeout)
    local waited_time

    waited_time = 0
    while not stairs[stair_id].detector.getInput(sides.labels[sides.back]) and waited_time < timeout do
        sleep(0.1)
        waited_time = waited_time + 0.1
    end
    print('Stair ' .. stair_id .. ' event after ' .. waited_time .. ' seconds')
    if waited_time < timeout then
        current_stair = stair_id
    end
    return waited_time < timeout
end

local function move_elevator_to(from_stair_id, to_stair_id)
    local increment
    local moving_direction

    if from_stair_id == to_stair_id then
        return false
    elseif from_stair_id < to_stair_id then
        increment = 1
        moving_direction = sides.up
    else
        increment = -1
        moving_direction = sides.down
    end
    elevator.move(moving_direction)
    while from_stair_id ~= to_stair_id and
          update_stair_monitoring(moving_direction, from_stair_id) and
          moving_direction ~= nil do
        if not wait_stair_event(from_stair_id + increment, 45) then
            moving_direction = nil
        end
        from_stair_id = from_stair_id + increment
        current_stair = current_stair + increment
    end
    elevator.stop()
    update_stair_monitoring(nil, from_stair_id, nil)
    return moving_direction ~= nil
end

local function reset_position()
    elevator_set_direction(sides.up)
    elevator_set_movement(true)
    return wait_stair_event(4, 60)
end

local function detect_stair()
    local i

    i = 1
    while i <= #stairs do
        if stairs[i].detector.getInput(sides.labels[sides.back]) then
            return i
        end
        i = i + 1
    end
    return false
end

local function redraw_control_panels(current_stair_id)
    local i

    i = 1
    while i <= #control_panels do
        control_panels[i].clear()
        i = i + 1
    end
    i = 1
    while i <= #click_button do
        if (#stairs - i + 1) == current_stair_id then
            buttons.draw_button(click_button[i], control_panels[current_stair_id], colors.red)
        else
            buttons.draw_button(click_button[i], control_panels[current_stair_id], colors.green)
        end
        i = i + 1
    end
end

local function main()
    local current_stair_id
    local requested_stair_id

    current_stair_id = detect_stair()
    if not current_stair_id then
        if not reset_position() then
            print('Error: cannot reset position')
            return
        end
        current_stair_id = 4
    end
    print('Current stair: ' .. current_stair_id)
    update_stair_monitoring(nil, current_stair_id, nil)
    draw_buttons_grid(#stairs, 1)
    redraw_control_panels(current_stair_id)
    while true do
        local _, _, x, y = os.pullEvent('monitor_touch')

        for i = 1, #stairs do
            buttons.exec_if_clicked(click_button[i], x, y, move_elevator_to, current_stair_id, #stairs - i + 1)
        end
        current_stair_id = detect_stair()
        redraw_control_panels(current_stair_id)
    end
end

init()
sleep(0.5)
main()
