local BLOC_TO_MINE = 'extendedae:entro_cluster'

local directions = {
    front = { inspect = turtle.inspect, dig = turtle.dig },
    down = { inspect = turtle.inspectDown, dig = turtle.digDown }
}

local function check_and_mine(dir)
    local _, block = dir.inspect()
    if block and block.name == BLOC_TO_MINE then
        dir.dig()
    end
end

local function place_in_chest()
    for i = 1, 16 do
        if turtle.getItemCount(i) > 0 then
            turtle.select(i)
            turtle.dropUp()
        end
    end
end

local function main()
    print("Starting mining turtle...")
    
    place_in_chest()
    while true do
        check_and_mine(directions.front)
        check_and_mine(directions.down)
        place_in_chest()
        os.sleep(30)
    end
end

main()

