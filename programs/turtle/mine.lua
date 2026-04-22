local BLOC_TO_MINE = "minecraft:stone"  -- À adapter selon vos besoins

local function check_and_mine()
    -- Vérifier le bloc devant
    if turtle.detect() then
        local block = turtle.inspect()
        if block.name == BLOC_TO_MINE then
            turtle.dig()
        end
    end

    -- Vérifier le bloc en dessous
    if turtle.detectDown() then
        local block = turtle.inspectDown()
        if block.name == BLOC_TO_MINE then
            turtle.digDown()
        end
    end
end

local function place_in_chest()
    -- Vérifier s'il y a un coffre au-dessus
    if turtle.detectUp() then
        local block = turtle.inspectUp()
        if block.name == "minecraft:chest" then
            -- Placer tous les items dans le coffre
            for i = 1, 16 do
                turtle.select(i)
                if turtle.getItemCount() > 0 then
                    turtle.dropUp()
                end
            end
        end
    end
end

local function main()
    print("Starting mining turtle...")
    
    while true do
        check_and_mine()
        place_in_chest()
        os.sleep(1)  -- Attendre 1 seconde entre chaque cycle
    end
end

main() 