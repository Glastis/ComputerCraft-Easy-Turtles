local buttons = {}

local function create_button(x, y, width, height, text, color)
    local button = {}

    button.x = x
    button.y = y
    button.width = width
    button.height = height
    button.text = text
    button.color = color
    return button
end
buttons.create_button = create_button

local function draw_button(button, monitor, background_color)
    if not monitor then
        monitor = term
    elseif type(monitor) == 'table' and #monitor > 0 then
        for i = 1, #monitor do
            draw_button(button, monitor[i])
        end
        return
    end
    local old_color = monitor.getBackgroundColor()
    if background_color then
        monitor.setBackgroundColor(background_color)
    else
        monitor.setBackgroundColor(button.color)
    end
    monitor.setCursorPos(button.x, button.y)
    for i = 1, button.height do
        monitor.write(string.rep(' ', button.width))
        monitor.setCursorPos(button.x, button.y + i)
    end
    monitor.setCursorPos(
            button.x + button.width / 2 - #button.text / 2,
            button.y + button.height / 2
    )
    monitor.write(button.text)
    monitor.setBackgroundColor(old_color)
end
buttons.draw_button = draw_button

local function create_and_draw_button(x, y, width, height, text, color, monitor)
    local button

    button = create_button(x, y, width, height, text, color)
    draw_button(button, monitor)
    return button
end
buttons.create_and_draw_button = create_and_draw_button

local function is_clicked(button, click_x, click_y)
    return  click_x >= button.x and click_x <= button.x + button.width and
            click_y >= button.y and click_y <= button.y + button.height
end
buttons.is_clicked = is_clicked

local function exec_if_clicked(button, click_x, click_y, callback, ...)
    if is_clicked(button, click_x, click_y) then
        callback(...)
    end
end
buttons.exec_if_clicked = exec_if_clicked

return buttons