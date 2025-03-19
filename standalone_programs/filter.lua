local blacklist = {
    'minecraft:cobblestone',
    'minecraft:cobbled_deepslate',
    'minecraft:netherrack',
}

local function is_blacklisted(item)
    for i = 1, #blacklist do
        if item.name == blacklist[i] then
            return true
        end
    end
    return false
end

local function main()
    turtle.dropDown()
    while true do
        turtle.suckDown()
        local item = turtle.getItemDetail()
        if not item then
            sleep(60)
        elseif is_blacklisted(item) then
            turtle.drop()
        else
            turtle.dropUp()
        end
    end
end

main()