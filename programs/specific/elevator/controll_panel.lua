package.path = package.path .. ';/ComputerCraft/*/?.lua'

local buttons = require 'graphics.button'

local BUTTON_WIDTH = 17
local BUTTON_HEIGHT = 5

local click_button

--- Draw a grid of buttons, each with a callback function, using the whole screen.
-- @int count The number of buttons to draw.
local function draw_buttons_grid(count, columns_count)
    local terminal_width
    local terminal_height

    terminal_width, terminal_height = term.getSize()
    click_button = {}
    term.clear()
    for i = 1, count do
        click_button[i] = buttons.create_and_draw_button(
                math.floor((terminal_width / columns_count) * ((i - 1) % columns_count)) + math.floor((terminal_width / columns_count - BUTTON_WIDTH) / 2) + 1,
                math.floor((terminal_height / math.ceil(count / columns_count)) * math.floor((i - 1) / columns_count)) + math.floor((terminal_height / math.ceil(count / columns_count) - BUTTON_HEIGHT) / 2) + 2,
                BUTTON_WIDTH,
                BUTTON_HEIGHT,
                'Button ' .. i,
                colors.green,
                function()
                    print('Button ' .. i .. ' clicked')
                end
        )
    end
end

local function main()
    draw_buttons_grid(4, 2)
    while true do
        local event, button, x, y = os.pullEvent('mouse_click')
        for i = 1, 4 do
            buttons.exec_if_clicked(click_button[i], x, y)
        end
    end
end

main()