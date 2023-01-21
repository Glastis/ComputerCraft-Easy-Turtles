local sides = require 'sides'

local red = {}

--- Pulse a redstone signal on a given side
-- @param side The side to pulse the redstone signal on
-- @int duration The duration of the pulse in seconds
-- @int power The power of the pulse, 0-15, default 15
local function pulse(side, duration, power)
    if not power then
        power = 15
    end
    red.setOutput(sides.labels[side], power)
    sleep(duration)
    red.setOutput(side, 0)
end
red.pulse = pulse

return red