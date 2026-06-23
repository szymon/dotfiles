---@param remote string
local urlFromRemote = function(remote)
    if vim.startswith(remote, "git") then
        remote = remote:gsub("git@", "")
        remote = remote:gsub(":", "/")
        return "https://" .. remote
    elseif vim.startswith(remote, "https") then
        return remote
    end
    error("unsupported remote: " .. remote)
end

---@param base string
---@param branch string
---@param file string
---@param line number
local function formatUrl(base, branch, file, line)
    if base:find("github") then
        return base .. "/blob/" .. branch .. "/" .. file .. "#L" .. line
    elseif base:find("gitlab") then
        return base .. "/-/blob/" .. branch .. "/" .. file .. "#L" .. line
    end
    error("unsupported remote: " .. base)
end

vim.keymap.set("n", "gl", function()
    local remoteResult = vim.system({ "git", "remote", "get-url", "origin" }, { text = true }):wait()
    local url = urlFromRemote(remoteResult.stdout:gsub("%s+", ""))

    local branchResult = vim.system({ "git", "rev-parse", "--abbrev-ref", "HEAD" }, { text = true }):wait()
    local branch = branchResult.stdout:gsub("%s+", "")

    local repoResult = vim.system({ "git", "rev-parse", "--show-toplevel" }, { text = true }):wait()
    local repo = repoResult.stdout:gsub("%s+", "")

    local bn = vim.api.nvim_buf_get_name(0)
    local line = vim.api.nvim_win_get_cursor(0)[1]

    local file = bn:gsub(repo .. "/", "")

    local fileUrl = formatUrl(url, branch, file, line)
    vim.system({ "open", fileUrl }, { detach = true })
end, { noremap = true, silent = true })
