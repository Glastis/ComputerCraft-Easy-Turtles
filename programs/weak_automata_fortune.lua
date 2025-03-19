package.path = package.path .. ';/ComputerCraft/common/?.lua'

local weak_automata = peripheral.find('endAutomata')
local sides = require('sides')
local inventory = require('inventory')

local PICKAXE_SLOT = 1
local ORE_SLOT = 2

local function place_and_dig()
    turtle.select(ORE_SLOT)
    while turtle.getItemCount(ORE_SLOT) > 0 do
        turtle.select(ORE_SLOT)
        if not turtle.place() then
            print(os.date() .. ': Failed to place ore')
            sleep(1)
        end
        turtle.select(PICKAXE_SLOT)
        weak_automata.digBlock()
    end
end

local function main()
    turtle.select(ORE_SLOT)
    inventory.drop_item_list({ 'allthemodium:allthemodium_pickaxe' }, sides.down, true)
    print(os.date() .. ': Waiting for ore')
    while true do
        turtle.select(ORE_SLOT)
        while turtle.suckUp() do
            place_and_dig()
            inventory.drop_item_list({ 'allthemodium:allthemodium_pickaxe' }, sides.down, true)
            turtle.select(ORE_SLOT)
        end
        sleep(10)
    end
end

weak_automata.setFuelConsumptionRate(10)
main()