local GITHUB_API_BASE = "https://api.github.com/repos/"
local GITHUB_RAW_BASE = "https://raw.githubusercontent.com/"
local DEFAULT_BRANCHES = {"master", "main"}
local MANIFEST_NAME = ".github_manifest"

local function print_usage()
    print("Usage:")
    print("  github clone author/repo output_dir")
    print("  github pull output_dir")
end

local function clean_repo_name(repo)
    return repo:gsub("%.git$", "")
end

local function manifest_path(output_dir)
    return fs.combine(output_dir, MANIFEST_NAME)
end

local function read_manifest(output_dir)
    local path = manifest_path(output_dir)
    if not fs.exists(path) then return nil end
    local file = fs.open(path, "r")
    local data = textutils.unserialise(file.readAll())
    file.close()
    return data
end

local function write_manifest(output_dir, manifest)
    local file = fs.open(manifest_path(output_dir), "w")
    file.write(textutils.serialise(manifest))
    file.close()
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

local function check_branch_exists(repo, branch)
    local url = GITHUB_API_BASE .. repo .. "/git/trees/" .. branch
    local response = http.get(url)
    if response then
        response.close()
        return true
    end
    return false
end

local function get_default_branch(repo)
    local response = http.get(GITHUB_API_BASE .. repo)
    if response then
        local data = textutils.unserialiseJSON(response.readAll())
        response.close()
        if data and data.default_branch then
            return data.default_branch
        end
    end

    for _, branch in ipairs(DEFAULT_BRANCHES) do
        if check_branch_exists(repo, branch) then
            return branch
        end
    end

    return DEFAULT_BRANCHES[1]
end

local function get_repo_tree(repo, branch)
    local url = GITHUB_API_BASE .. repo .. "/git/trees/" .. branch .. "?recursive=1"
    local response = http.get(url)
    if not response then return nil end

    local data = textutils.unserialiseJSON(response.readAll())
    response.close()
    return data and data.tree
end

local function tree_to_map(tree)
    local map = {}
    for _, item in ipairs(tree) do
        if item.type == "blob" and not item.path:match("%.git") then
            map[item.path] = item.sha
        end
    end
    return map
end

local function ensure_parent_dir(file_path)
    local dir_path = file_path:match("(.*[/\\])")
    if dir_path and not fs.exists(dir_path) then
        fs.makeDir(dir_path)
    end
end

local function download_paths(repo, branch, output_dir, paths)
    local downloaded, failed = 0, 0
    for _, path in ipairs(paths) do
        local file_path = fs.combine(output_dir, path)
        ensure_parent_dir(file_path)
        local url = GITHUB_RAW_BASE .. repo .. "/" .. branch .. "/" .. path
        if download_file(url, file_path) then
            downloaded = downloaded + 1
            print("Downloaded: " .. path)
        else
            failed = failed + 1
            print("Failed: " .. path)
        end
    end
    return downloaded, failed
end

local function fetch_tree_map(repo)
    print("Fetching repository metadata...")
    local branch = get_default_branch(repo)
    print("Using branch: " .. branch)

    local tree = get_repo_tree(repo, branch)
    if not tree then
        print("Error: Failed to fetch repository tree")
        return nil
    end
    return branch, tree_to_map(tree)
end

local function clone(repo, output_dir)
    if not fs.exists(output_dir) then
        fs.makeDir(output_dir)
    end

    local branch, files_map = fetch_tree_map(repo)
    if not files_map then return end

    local paths = {}
    for path in pairs(files_map) do
        table.insert(paths, path)
    end
    print(string.format("Found %d files to download", #paths))

    local downloaded, failed = download_paths(repo, branch, output_dir, paths)
    write_manifest(output_dir, {repo = repo, branch = branch, files = files_map})
    print(string.format("Clone complete. Success: %d, Failed: %d", downloaded, failed))
end

local function pull(output_dir)
    local manifest = read_manifest(output_dir)
    if not manifest then
        print("Error: no manifest found in " .. output_dir .. ". Use 'clone' first.")
        return
    end

    local repo = manifest.repo
    print("Repo: " .. repo)

    local branch, remote_map = fetch_tree_map(repo)
    if not remote_map then return end

    local to_download, to_delete = {}, {}
    for path, sha in pairs(remote_map) do
        if manifest.files[path] ~= sha then
            table.insert(to_download, path)
        end
    end
    for path in pairs(manifest.files) do
        if not remote_map[path] then
            table.insert(to_delete, path)
        end
    end

    print(string.format("Changed: %d, Removed: %d", #to_download, #to_delete))

    for _, path in ipairs(to_delete) do
        local file_path = fs.combine(output_dir, path)
        if fs.exists(file_path) then
            fs.delete(file_path)
            print("Deleted: " .. path)
        end
    end

    local downloaded, failed = download_paths(repo, branch, output_dir, to_download)
    write_manifest(output_dir, {repo = repo, branch = branch, files = remote_map})
    print(string.format("Pull complete. Updated: %d, Failed: %d, Removed: %d", downloaded, failed, #to_delete))
end

local args = {...}
local command = args[1]

if command == "clone" then
    if #args < 3 then print_usage() return end
    clone(clean_repo_name(args[2]), args[3])
elseif command == "pull" then
    if #args < 2 then print_usage() return end
    pull(args[2])
else
    print_usage()
end
