local GITHUB_API_BASE = "https://api.github.com/repos/"
local GITHUB_RAW_BASE = "https://raw.githubusercontent.com/"
local DEFAULT_BRANCHES = {"master", "main"}

local args = {...}

if #args < 2 then
    print("Usage: github author/repo output_dir")
    return
end

local function clean_repo_name(repo)
    return repo:gsub("%.git$", "")
end

local repo = clean_repo_name(args[1])
local output_dir = args[2]

if not fs.exists(output_dir) then
    fs.makeDir(output_dir)
end

local function download_file(url, path)
    local response = http.get(url)
    if response then
        local file = fs.open(path, "w")
        file.write(response.readAll())
        file.close()
        response.close()
        return true
    end
    return false
end

local function check_branch_exists(branch)
    local url = GITHUB_API_BASE .. repo .. "/git/trees/" .. branch
    local response = http.get(url)
    if response then
        response.close()
        return true
    end
    return false
end

local function get_default_branch()
    local api_url = GITHUB_API_BASE .. repo
    local response = http.get(api_url)
    if response then
        local data = textutils.unserialiseJSON(response.readAll())
        response.close()
        if data and data.default_branch then
            return data.default_branch
        end
    end

    for _, branch in ipairs(DEFAULT_BRANCHES) do
        if check_branch_exists(branch) then
            return branch
        end
    end

    return DEFAULT_BRANCHES[1]
end

local function get_repo_tree(branch)
    local api_url = GITHUB_API_BASE .. repo .. "/git/trees/" .. branch .. "?recursive=1"
    local response = http.get(api_url)
    if not response then return nil end
    
    local data = textutils.unserialiseJSON(response.readAll())
    response.close()
    return data and data.tree
end

local function get_files_to_download(tree, branch)
    local files = {}
    for _, item in ipairs(tree) do
        if item.type == "blob" and not item.path:match("%.git") then
            table.insert(files, {
                path = item.path,
                url = GITHUB_RAW_BASE .. repo .. "/" .. branch .. "/" .. item.path
            })
        end
    end
    return files
end

local function download_files(files)
    local downloaded = 0
    local failed = 0

    for _, file in ipairs(files) do
        local file_path = fs.combine(output_dir, file.path)
        local dir_path = file_path:match("(.*[/\\])")
        
        if dir_path and not fs.exists(dir_path) then
            fs.makeDir(dir_path)
        end
        
        local success = download_file(file.url, file_path)
        if success then
            downloaded = downloaded + 1
            print("Downloaded: " .. file.path)
        else
            failed = failed + 1
            print("Failed: " .. file.path)
        end
    end

    return downloaded, failed
end

local function main()
    print("Fetching repository metadata...")
    local branch = get_default_branch()
    print("Using branch: " .. branch)
    
    local tree = get_repo_tree(branch)
    if not tree then
        print("Error: Failed to fetch repository tree")
        return
    end

    print("Analyzing files to download...")
    local files = get_files_to_download(tree, branch)
    print(string.format("Found %d files to download", #files))

    print("Starting download...")
    local downloaded, failed = download_files(files)
    print(string.format("Download complete. Success: %d, Failed: %d", downloaded, failed))
end

main() 