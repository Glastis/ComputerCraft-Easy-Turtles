local PROGRAMS_SOURCE = '/' .. fs.combine(shell.dir(), "programs/unix")
local COMMON_SOURCE = '/' .. fs.combine(shell.dir(), "common")
local STARTUP_FILE = "startup.lua"

local function is_path_in_startup(content)
    return content:find(PROGRAMS_SOURCE) ~= nil and content:find(COMMON_SOURCE) ~= nil
end

local function generate_startup()
    local startup_content = [[
package.path = "]] .. COMMON_SOURCE .. [[/?.lua;" .. package.path
shell.setPath(shell.path() .. ":]] .. PROGRAMS_SOURCE .. [[")
]]

    local existing_content = ""
    if fs.exists(STARTUP_FILE) then
        local existing_file = fs.open(STARTUP_FILE, "r")
        if existing_file then
            existing_content = existing_file.readAll()
            existing_file.close()
            
            if is_path_in_startup(existing_content) then
                print("Unix programs and common paths already in startup.lua")
                return true
            end
        end
    end

    local startup_file = fs.open(STARTUP_FILE, "w")
    if not startup_file then
        print("Error: Failed to create " .. STARTUP_FILE)
        return false
    end

    startup_file.write(startup_content)
    if existing_content ~= "" then
        startup_file.write("\n" .. existing_content)
    end
    startup_file.close()
    return true
end

local function main()
    print("Starting installation of Unix programs and common...")
    print("Programs directory: " .. PROGRAMS_SOURCE)
    print("Common directory: " .. COMMON_SOURCE)
    
    if not generate_startup() then
        print("Installation failed")
        return
    end
    
    print("Installation completed successfully")
    print("Unix programs and common modules will be available after next reboot")
end

main() 