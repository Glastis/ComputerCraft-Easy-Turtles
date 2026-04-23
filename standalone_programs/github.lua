local GITHUB_API_BASE = "https://api.github.com/repos/"
local GITHUB_RAW_BASE = "https://raw.githubusercontent.com/"
local DEFAULT_BRANCHES = {"master", "main"}
local MANIFEST_NAME = ".github_manifest"

local function print_usage()
    print("Usage:")
    print("  github clone author/repo [branch] [-o output_dir]")
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

local function get_header(headers, name)
    if not headers then return nil end
    return headers[name] or headers[name:lower()]
end

local function http_json(url, headers)
    local response, _, failing = http.get(url, headers)
    if response then
        local body = response.readAll()
        local resp_headers = response.getResponseHeaders and response.getResponseHeaders() or {}
        response.close()
        return textutils.unserialiseJSON(body), resp_headers, 200
    end
    if failing then
        local code = failing.getResponseCode and failing.getResponseCode() or 0
        local resp_headers = failing.getResponseHeaders and failing.getResponseHeaders() or {}
        if failing.close then failing.close() end
        return nil, resp_headers, code
    end
    return nil, {}, 0
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

local function ensure_parent_dir(file_path)
    local dir_path = file_path:match("(.*[/\\])")
    if dir_path and not fs.exists(dir_path) then
        fs.makeDir(dir_path)
    end
end

local function download_paths(repo, commit_sha, output_dir, paths)
    local downloaded, failed = 0, 0
    for _, path in ipairs(paths) do
        local file_path = fs.combine(output_dir, path)
        ensure_parent_dir(file_path)
        local url = GITHUB_RAW_BASE .. repo .. "/" .. commit_sha .. "/" .. path
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

local function fetch_commit(repo, branch)
    local url = GITHUB_API_BASE .. repo .. "/commits/" .. branch
    local data = http_json(url)
    if not data or not data.sha then return nil end
    local tree_sha = data.commit and data.commit.tree and data.commit.tree.sha
    return data.sha, tree_sha
end

local function resolve_branch(repo, preferred)
    local candidates = preferred and {preferred} or DEFAULT_BRANCHES
    for _, branch in ipairs(candidates) do
        local commit_sha, tree_sha = fetch_commit(repo, branch)
        if commit_sha then
            return branch, commit_sha, tree_sha
        end
    end
    return nil
end

local function fetch_tree(repo, tree_ref)
    local url = GITHUB_API_BASE .. repo .. "/git/trees/" .. tree_ref .. "?recursive=1"
    local data = http_json(url)
    return data and data.tree
end

local function collect_blob_paths(tree)
    local paths = {}
    for _, item in ipairs(tree) do
        if item.type == "blob" and not item.path:match("%.git") then
            table.insert(paths, item.path)
        end
    end
    return paths
end

local function clone(repo, output_dir, preferred_branch)
    if not fs.exists(output_dir) then
        fs.makeDir(output_dir)
    end

    print("Resolving branch...")
    local branch, commit_sha, tree_sha = resolve_branch(repo, preferred_branch)
    if not branch then
        print("Error: no suitable branch found")
        return
    end
    print("Branch: " .. branch .. " @ " .. commit_sha:sub(1, 7))

    local tree = fetch_tree(repo, tree_sha or branch)
    if not tree then
        print("Error: failed to fetch repository tree")
        return
    end
    local paths = collect_blob_paths(tree)
    print(string.format("Found %d files to download", #paths))

    local downloaded, failed = download_paths(repo, commit_sha, output_dir, paths)
    write_manifest(output_dir, {repo = repo, branch = branch, commit_sha = commit_sha})
    print(string.format("Clone complete. Success: %d, Failed: %d", downloaded, failed))
end

local function delete_path(output_dir, path)
    local file_path = fs.combine(output_dir, path)
    if fs.exists(file_path) then
        fs.delete(file_path)
        print("Deleted: " .. path)
    end
end

local function apply_diff(repo, commit_sha, output_dir, files)
    local to_download, to_delete = {}, {}
    for _, f in ipairs(files) do
        local status = f.status
        if status == "removed" then
            table.insert(to_delete, f.filename)
        elseif status == "renamed" then
            if f.previous_filename then
                table.insert(to_delete, f.previous_filename)
            end
            table.insert(to_download, f.filename)
        else
            table.insert(to_download, f.filename)
        end
    end

    print(string.format("Changed: %d, Removed: %d", #to_download, #to_delete))

    for _, path in ipairs(to_delete) do
        delete_path(output_dir, path)
    end

    local downloaded, failed = download_paths(repo, commit_sha, output_dir, to_download)
    return downloaded, failed, #to_delete
end

local function pull(output_dir)
    local manifest = read_manifest(output_dir)
    if not manifest then
        print("Error: no manifest found in " .. output_dir .. ". Use 'clone' first.")
        return
    end
    if not manifest.commit_sha then
        print("Error: manifest predates SHA tracking. Re-clone to upgrade.")
        return
    end

    local repo = manifest.repo
    local branch = manifest.branch
    print("Repo: " .. repo .. " (" .. branch .. ")")

    local url = GITHUB_API_BASE .. repo .. "/compare/" .. manifest.commit_sha .. "..." .. branch
    local headers = manifest.etag and {["If-None-Match"] = manifest.etag} or nil
    local data, resp_headers, code = http_json(url, headers)

    if code == 304 then
        print("Already up to date (304).")
        return
    end
    if not data then
        print("Error: compare request failed (HTTP " .. tostring(code) .. ")")
        return
    end

    local new_etag = get_header(resp_headers, "ETag") or manifest.etag
    local status = data.status or "unknown"
    local head_sha = manifest.commit_sha
    if data.commits and #data.commits > 0 then
        head_sha = data.commits[#data.commits].sha
    end

    if status == "identical" or not data.files or #data.files == 0 then
        print("Already up to date.")
        write_manifest(output_dir, {repo = repo, branch = branch, commit_sha = head_sha, etag = new_etag})
        return
    end

    print("Status: " .. status .. " -> " .. head_sha:sub(1, 7))

    local downloaded, failed, removed = apply_diff(repo, head_sha, output_dir, data.files)
    write_manifest(output_dir, {repo = repo, branch = branch, commit_sha = head_sha, etag = new_etag})
    print(string.format("Pull complete. Updated: %d, Failed: %d, Removed: %d", downloaded, failed, removed))
end

local function parse_clone_args(args)
    local repo, branch, output_dir
    local i = 2
    while i <= #args do
        local a = args[i]
        if a == "-o" then
            output_dir = args[i + 1]
            i = i + 2
        elseif not repo then
            repo = a
            i = i + 1
        elseif not branch then
            branch = a
            i = i + 1
        else
            i = i + 1
        end
    end
    return repo, branch, output_dir
end

local args = {...}
local command = args[1]

if command == "clone" then
    local repo, branch, output_dir = parse_clone_args(args)
    if not repo then print_usage() return end
    repo = clean_repo_name(repo)
    output_dir = output_dir or repo:match("([^/]+)$")
    clone(repo, output_dir, branch)
elseif command == "pull" then
    if #args < 2 then print_usage() return end
    pull(args[2])
else
    print_usage()
end
