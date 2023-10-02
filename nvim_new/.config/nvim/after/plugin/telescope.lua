if not pcall(require, "telescope") then return end

local t = require("szymon.telescope")
local nnoremap = require("szymon.keymap").nnoremap
local actions = require("telescope.actions")

require("telescope").setup({
    defaults = {
        mappings = {
            i = {
                ["<c-f>"] = function(pbn) t.scroll_window(pbn, 1, 1) end,
                ["<c-b>"] = function(pbn) t.scroll_window(pbn, -1, 1) end,
                ["<c-e>"] = function(pbn) t.scroll_window(pbn, 1, t.get_window_height) end,
                ["<c-y>"] = function(pbn) t.scroll_window(pbn, -1, t.get_window_height) end,
                ["<c-k>"] = actions.move_selection_previous,
                ["<c-j>"] = actions.move_selection_next,
                ["<c-h>"] = actions.which_key,
                ["<esc>"] = actions.close

            }
        }
    }
})

if pcall(require, 'git-worktree') then
    require('telescope').load_extension('git_worktree')

    nnoremap("<leader>wl", require('telescope').extensions.git_worktree.git_worktrees)
    nnoremap("<leader>wc", require('telescope').extensions.git_worktree.create_git_worktree)
end

local telescope_actions = require("telescope.actions")

nnoremap("<c-p>", require('telescope.builtin').find_files)
nnoremap("<leader>rr", require('telescope.builtin').live_grep)
nnoremap("<leader>gr", function() require('telescope.builtin').grep_string { search = vim.fn.input("Grep > ") } end)
nnoremap("<leader>;",
    function() require('telescope.builtin').buffers({ sort_lastuse = true, ignore_current_buffer = true }) end)
-- nnoremap("<leader>fh", "<cmd>lua require('telescope.builtin').help_tags())
nnoremap("<leader>sk", require('telescope.builtin').keymaps)
nnoremap("<leader>=", require('telescope.builtin').spell_suggest)
nnoremap("<leader>sgc", require('telescope.builtin').git_commits)
nnoremap("<leader>sgb", require('telescope.builtin').git_bcommits)
nnoremap("<leader>sgs", require('telescope.builtin').git_status)

pcall(require("telescope").load_extension, "fzf")
