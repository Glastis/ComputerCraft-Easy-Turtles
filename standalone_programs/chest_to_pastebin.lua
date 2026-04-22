local PASTEBIN_URL = 'https://pastebin.com/api/api_post.php'
local PASTEBIN_DEV_KEY = '0ec2eb25b6166c0c27a394ae118ad829'
local PASTEBIN_EXPIRE = '10M'
local OUTPUT_FILE = 'chest_contents.txt'

local function find_chest()
    local names = peripheral.getNames()
    local i

    for i = 1, #names do
        if peripheral.hasType(names[i], 'inventory') then
            return peripheral.wrap(names[i]), names[i]
        end
    end
    return nil, nil
end

local function collect_item_names(chest)
    local items = {}
    local seen = {}

    for _, item in pairs(chest.list()) do
        if not seen[item.name] then
            seen[item.name] = true
            table.insert(items, item.name)
        end
    end
    table.sort(items)
    return items
end

local function write_items_file(items, path)
    local file = fs.open(path, 'w')
    local i

    for i = 1, #items do
        file.writeLine(items[i])
    end
    file.close()
end

local function read_file_content(path)
    local file = fs.open(path, 'r')
    local content = file.readAll()

    file.close()
    return content
end

local function url_encode(str)
    local encoded = str:gsub('([^%w%-%._~])', function(c)
        return string.format('%%%02X', string.byte(c))
    end)
    return encoded
end

local function build_pastebin_body(content)
    return 'api_option=paste'
        .. '&api_dev_key=' .. PASTEBIN_DEV_KEY
        .. '&api_paste_expire_date=' .. PASTEBIN_EXPIRE
        .. '&api_paste_private=1'
        .. '&api_paste_name=' .. url_encode(OUTPUT_FILE)
        .. '&api_paste_code=' .. url_encode(content)
end

local function upload_to_pastebin(content)
    local response = http.post(PASTEBIN_URL, build_pastebin_body(content))
    local result

    if not response then
        return nil
    end
    result = response.readAll()
    response.close()
    return result
end

local function main()
    local chest, chest_name = find_chest()
    local items
    local content
    local result

    if not chest then
        print('No inventory peripheral attached')
        return
    end
    print('Wrapped peripheral: ' .. chest_name)
    items = collect_item_names(chest)
    write_items_file(items, OUTPUT_FILE)
    print('Wrote ' .. #items .. ' unique item name(s) to ' .. OUTPUT_FILE)
    content = read_file_content(OUTPUT_FILE)
    result = upload_to_pastebin(content)
    if not result then
        print('Pastebin upload failed (no response)')
        return
    end
    print('Pastebin: ' .. result)
end

main()
