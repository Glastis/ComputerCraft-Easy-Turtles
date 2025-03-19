local gs = peripheral.find('geoScanner')

package.path = package.path .. ';/ComputerCraft/common/?.lua'

local utilities = require 'utils'
local file = require 'file'

local function find_ore(ore)
    local all_ores

    all_ores = gs.chunkAnalyze()
    if not all_ores[ore] then
        all_ores[ore] = 0
    end
    print('Ore: ' .. ore .. ', count: ' .. all_ores[ore])
end

--find_ore('allthemodium:allthemodium_ore')
--find_ore('allthemodium:vibranium_ore')

local test = gs.scan(8)

local i

i = 1
while i <= #test do
    if test[i].name == 'allthemodium:vibranium_ore' then
        print('Found allthemodium at: ' .. test[i].x .. ', ' .. test[i].y .. ', ' .. test[i].z)
    end
    --print(test[i].name)

    i = i + 1
end
--file.write('test.txt', utilities.var_dump(test, true))