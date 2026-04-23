-- Easy installer for ComputerCraft-Easy-Turtles/github
-- https://github.com/Glastis/ComputerCraft-Easy-Turtles
-- Usage in CC: pastebin run <id> [branch]
local tree = select(1, ...) or "master"
local url = ("https://raw.githubusercontent.com/Glastis/ComputerCraft-Easy-Turtles/%s/standalone_programs/github.lua"):format(tree)
local response = http.get(url)
if not response then
    error("Failed to download: " .. url)
end
local file = fs.open("github", "w")
file.write(response.readAll())
file.close()
response.close()
print("Installed 'github' from " .. tree)
