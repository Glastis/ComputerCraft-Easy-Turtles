
local IDLE_WAIT_TIME = 10

local function get_empty_bucket()
    while not turtle.suckUp(1) do
        sleep(IDLE_WAIT_TIME)
    end
end

local function main()
    while true do
        get_empty_bucket()
        turtle.place()
        turtle.dropDown()
    end
end

turtle.dropDown(1)
main()