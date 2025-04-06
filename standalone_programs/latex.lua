local function select_birch()
    for i = 1, 16 do
        local item = turtle.getItemDetail(i)
        if item and item.name == "minecraft:birch_log" then
            turtle.select(i)
            return true
        end
    end
    return false
end

local function manage_inventory()
    while not select_birch() do
        for i = 1, 16 do
            turtle.select(i)
            turtle.dropDown()
        end
        turtle.select(1)
        turtle.suckUp(64)
        sleep(60)
    end
end

local function handle_log()
    local block

    if turtle.place() then
        repeat
            sleep(10)
            _, block = turtle.inspect()
        until block and block.name == "minecraft:stripped_birch_log"
        turtle.dig()
    end
end

local function main()
    turtle.dig()
    while true do
        manage_inventory()
        handle_log()
    end
end

main() 