-- Mine A Cube

package.path = package.path .. ';/ComputerCraft/*/?.lua'
package.path = package.path .. ';/ComputerCraft/common/?.lua'

local sides = require 'sides'
local move = require 'move'
local inventory = require "inventory"

local energy_per_block = 1.005
local empty_slots_before_depot = 5

local function store_to_depot(x, y, z, cube, comeback)
    if not cube.storage then
        return
    end
    move.move_to(0, 0, 0, true)
    move.rotate(cube.storage)
    inventory.drop_all(cube.storage)
    if comeback == nil or comeback then
        move.move_to(x, y, z, true)
    end
end

local function store_on_full_inventory(x, y, z, cube)
    inventory.defragment_inventory()
    if inventory.count_empty_slots() < empty_slots_before_depot then
        store_to_depot(x, y, z, cube)
    end
end

local function moved_z(cube, z, starting_direction)
    if cube.direction_z == sides.right then
        return z + (starting_direction and 1 or -1)
    else
        return z + (starting_direction and -1 or 1)
    end
end

local function mine_cube(cube)
    local x, y, z = 0, 0, 0
    local starting_direction = true

    cube.y = cube.y + (cube.y > 0 and -1 or 1)
    cube.z = cube.z + (cube.z > 0 and -1 or 1)
    while x < cube.x do
        y = (y == cube.y and 0 or cube.y)
        move.move_to(x, y, z, true)
        if cube.z == 0 then
            x = x + 1
            if x == cube.x then
                store_to_depot(x, y, z, cube, false)
                return
            end
        else
            z = moved_z(cube, z, starting_direction)
        end
        if z == cube.z and starting_direction or z == 0 and not starting_direction then
            move.move_to(x, y, z, true)
            y = (y == cube.y and 0 or cube.y)
            move.move_to(x, y, z, true)
            x = x + 1
            if x == cube.x then
                store_to_depot(x, y, z, cube, false)
                return
            end
            move.move_to(x, y, z, true)
            starting_direction = not starting_direction
        else
            move.move_to(x, y, z, true)
        end
        store_on_full_inventory(x, y, z, cube)
    end
end

local function check_if_energy_is_available(cube)
    local energy_required

    energy_required = cube.x * cube.y * cube.z * energy_per_block
    energy_required = energy_required < 0 and -energy_required or energy_required
    if turtle.getFuelLevel() < energy_required then
        print("Not enough energy to mine the cube.")
        print("Energy required: " .. energy_required)
        print("Energy available: " .. turtle.getFuelLevel())
        print("Missing: " .. energy_required - turtle.getFuelLevel())
        print("Refuel and try again.")
        return false
    end
    print("Energy required: " .. energy_required)
    print("Energy available: " .. turtle.getFuelLevel())
    print("Left after mining: " .. turtle.getFuelLevel() - energy_required)
    return true
end

local function parse_args(args)
    local parsed = {}
    for i, arg in ipairs(args) do
        if arg == '-x' then
            parsed.x = tonumber(args[i + 1])
            if parsed.x < 1 then
                print("Invalid x. Must be greater than 0.")
                return nil
            end
        elseif arg == '-y' then
            parsed.y = tonumber(args[i + 1])
            if parsed.y < 1 then
                print("Invalid y. Must be greater than 0.")
                return nil
            end
        elseif arg == '-z' then
            parsed.z = tonumber(args[i + 1])
            if parsed.z < 1 then
                print("Invalid z. Must be greater than 0.")
                return nil
            end
        elseif arg =='-dz' or arg == '--direction-z' then
            parsed.direction_z = sides.get_side_from_label(tostring(args[i + 1]))
            if parsed.direction_z ~= sides.right and parsed.direction_z ~= sides.left then
                print("Invalid direction-z. Use right or left.")
                return nil
            end
        elseif arg == '-dy' or arg == '--direction-y' then
            parsed.direction_y = sides.get_side_from_label(tostring(args[i + 1]))
            if parsed.direction_y ~= sides.up and parsed.direction_y ~= sides.down then
                print("Invalid direction-y. Use up or down.")
                return nil
            end
        elseif arg == '-s' or arg == '--storage' then
            parsed.storage = sides.get_side_from_label(tostring(args[i + 1]))
            if not parsed.storage then
                print("Invalid storage side. Use top/up, bottom/down, back, left or right.")
                return nil
            end
        elseif arg == '-h' or arg == '--help' or arg == '?' then
            print("Usage: mac")
            print("  -x <x> depth")
            print("  -y <y> height")
            print("  -z <z> width")
            print("  [-dz] <direction-z> right or left")
            print("  [-dy] <direction-y> up or down")
            print("  [-s] <side> storage side at the beginning")
            return nil
        end
    end
            if not parsed.x or not parsed.y or not parsed.z then
            print("Missing x, y or z.")
            return nil
        end
        if not parsed.direction_z and parsed.z > 1 then
            print("Missing direction-z.")
            return nil
        end
        if not parsed.direction_y and parsed.y > 1 then
            print("Missing direction-y.")
            return nil
        end
        if (parsed.storage == sides.left and parsed.direction_z == sides.left) or
           (parsed.storage == sides.right and parsed.direction_z == sides.right) or
           (parsed.storage == sides.up and parsed.direction_y == sides.up) or
           (parsed.storage == sides.down and parsed.direction_y == sides.down) then
            print("Storage cannot be on the same side as the mining direction.")
            return nil
        end
        if not parsed.direction_y then
            parsed.direction_y = sides.up
        end
        if not parsed.direction_z then
            parsed.direction_z = sides.right
        end
        if parsed.direction_y == sides.down then
            parsed.y = -parsed.y
        end
        if parsed.direction_z == sides.left then
            parsed.z = -parsed.z
        end

    return parsed
end

local function main(args)
    local parsed

    parsed = parse_args(args)
    if not parsed or not check_if_energy_is_available(parsed) then
        return
    end
    mine_cube(parsed)
end

main({...})