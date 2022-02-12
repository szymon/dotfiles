vim.cmd [[source ~/.vimrc]]

require "plugins"
require "lsp_configs"
require "statusline"

--
vim.opt.signcolumn = "yes"
vim.opt.wrap = false
vim.opt.spell = true

local opts = {noremap = true, silent = true}
vim.api.nvim_set_keymap("n", "<c-p>", "<cmd>lua require('telescope.builtin').find_files()<cr>", opts)
vim.api.nvim_set_keymap("n", "<leader>rr", "<cmd>lua require('telescope.builtin').live_grep()<cr>", opts)
vim.api.nvim_set_keymap("n", "<leader>gr", "<cmd>lua require('telescope.builtin').grep_string()<cr>", opts)
vim.api.nvim_set_keymap("n", "<leader>;", "<cmd>lua require('telescope.builtin').buffers({sort_lastused = true, ignore_current_buffer = true })<cr>",
                        opts)
-- vim.api.nvim_set_keymap("n", "<leader>j", "<cmd>cn<cr>", opts)
-- vim.api.nvim_set_keymap("n", "<leader>k", "<cmd>cp<cr>", opts)

vim.cmd [[
" call submode#enter_with('grow/shrink', 'n', '', '<leader><up>', '<C-w>+')
" call submode#enter_with('grow/shrink', 'n', '', '<leader><down>', '<C-w>-')
" call submode#map('grow/shrink', 'n', '', '<down>', '<C-w>-')
" call submode#map('grow/shrink', 'n', '', '<up>', '<C-w>+')

call submode#enter_with('quickfixlist', 'n', '', '<leader>j', '<cmd>cn<cr>')
call submode#enter_with('quickfixlist', 'n', '', '<leader>k', '<cmd>cp<cr>')
call submode#map('quickfixlist', 'n', '', 'j', '<cmd>cn<cr>')
call submode#map('quickfixlist', 'n', '', 'k', '<cmd>cp<cr>')
]]

vim.g.submode_timeout = 0
vim.g.submode_keep_leaving_key = 1

vim.cmd [[colorscheme gruvbox]]

local telescope_actions = require("telescope.actions")
require("telescope").setup({
    defaults = {
        mappings = {
            i = {
                ["<c-k>"] = "move_selection_previous",
                ["<c-j>"] = "move_selection_next",
                ["<c-h>"] = "which_key",
                ["<esc>"] = telescope_actions.close
            }
        }
    }
})

require("gitsigns").setup {
    signs = {
        add = {hl = "SignAdd", text = "+"},
        change = {hl = "SignChange", text = "~"},
        delete = {hl = "SignDelete", text = "-"},
        topdelete = {hl = "SignDelete", text = "-"},
        changedelete = {hl = "SignChange", text = "~"}
    },
    keymaps = {
        noremap = true,
        buffer = true,
        ["n <leader>hs"] = "<cmd>lua require('gitsigns').stage_hunk()<cr>",
        ["n <leader>hu"] = "<cmd>lua require('gitsigns').undo_stage_hunk()<cr>",
        ["n <leader>hr"] = "<cmd>lua require('gitsigns').reset_hunk()<cr>",
        ["n <leader>hR"] = "<cmd>lua require('gitsigns').reset_buffer()<cr>",
        ["n <leader>hp"] = "<cmd>lua require('gitsigns').preview_hunk()<cr>",
        ["n <leader>hb"] = "<cmd>lua require('gitsigns').blame_line()<cr>"
    },
    watch_index = {interval = 1000}
}

-- insert mode refresh completions (at word, at function call)
-- scrolling window with completions
--
-- some way to define actions on save (format, sort imports...)
vim.g.Illuminate_delay = 300
vim.api.nvim_command [[ hi def link LspReferenceText CursorLine ]]
vim.api.nvim_command [[ hi def link LspReferenceWrite CursorLine ]]
vim.api.nvim_command [[ hi def link LspReferenceRead CursorLine ]]

-- popup window for diagnostic is unreadable, now sure how to change it
-- so instead change text color to pink
vim.api.nvim_command [[ hi DiagnosticFloatingError guifg=Pink ]]

local cb = require'diffview.config'.diffview_callback

require'diffview'.setup {
    diff_binaries = false, -- Show diffs for binaries
    enhanced_diff_hl = false, -- See ':h diffview-config-enhanced_diff_hl'
    file_panel = {
        position = "left", -- One of 'left', 'right', 'top', 'bottom'
        width = 35, -- Only applies when position is 'left' or 'right'
        height = 10, -- Only applies when position is 'top' or 'bottom'
        listing_style = "tree", -- One of 'list' or 'tree'
        tree_options = { -- Only applies when listing_style is 'tree'
            flatten_dirs = true, -- Flatten dirs that only contain one single dir
            folder_statuses = "only_folded" -- One of 'never', 'only_folded' or 'always'.
        }
    },
    file_history_panel = {
        position = "bottom",
        width = 35,
        height = 16,
        log_options = {
            max_count = 256, -- Limit the number of commits
            follow = false, -- Follow renames (only for single file)
            all = false, -- Include all refs under 'refs/' including HEAD
            merges = false, -- List only merge commits
            no_merges = false, -- List no merge commits
            reverse = false -- List commits in reverse order
        }
    },
    default_args = { -- Default args prepended to the arg-list for the listed commands
        DiffviewOpen = {},
        DiffviewFileHistory = {}
    },
    hooks = {}, -- See ':h diffview-config-hooks'
    key_bindings = {
        disable_defaults = false, -- Disable the default key bindings
        -- The `view` bindings are active in the diff buffers, only when the current
        -- tabpage is a Diffview.
        view = {
            ["<tab>"] = cb("select_next_entry"), -- Open the diff for the next file
            ["<s-tab>"] = cb("select_prev_entry"), -- Open the diff for the previous file
            ["gf"] = cb("goto_file"), -- Open the file in a new split in previous tabpage
            ["<C-w><C-f>"] = cb("goto_file_split"), -- Open the file in a new split
            ["<C-w>gf"] = cb("goto_file_tab"), -- Open the file in a new tabpage
            ["<leader>e"] = cb("focus_files"), -- Bring focus to the files panel
            ["<leader>b"] = cb("toggle_files") -- Toggle the files panel.
        },
        file_panel = {
            ["j"] = cb("next_entry"), -- Bring the cursor to the next file entry
            ["<down>"] = cb("next_entry"),
            ["k"] = cb("prev_entry"), -- Bring the cursor to the previous file entry.
            ["<up>"] = cb("prev_entry"),
            ["<cr>"] = cb("select_entry"), -- Open the diff for the selected entry.
            ["o"] = cb("select_entry"),
            ["<2-LeftMouse>"] = cb("select_entry"),
            ["-"] = cb("toggle_stage_entry"), -- Stage / unstage the selected entry.
            ["S"] = cb("stage_all"), -- Stage all entries.
            ["U"] = cb("unstage_all"), -- Unstage all entries.
            ["X"] = cb("restore_entry"), -- Restore entry to the state on the left side.
            ["R"] = cb("refresh_files"), -- Update stats and entries in the file list.
            ["<tab>"] = cb("select_next_entry"),
            ["<s-tab>"] = cb("select_prev_entry"),
            ["gf"] = cb("goto_file"),
            ["<C-w><C-f>"] = cb("goto_file_split"),
            ["<C-w>gf"] = cb("goto_file_tab"),
            ["i"] = cb("listing_style"), -- Toggle between 'list' and 'tree' views
            ["f"] = cb("toggle_flatten_dirs"), -- Flatten empty subdirectories in tree listing style.
            ["<leader>e"] = cb("focus_files"),
            ["<leader>b"] = cb("toggle_files")
        },
        file_history_panel = {
            ["g!"] = cb("options"), -- Open the option panel
            ["<C-A-d>"] = cb("open_in_diffview"), -- Open the entry under the cursor in a diffview
            ["y"] = cb("copy_hash"), -- Copy the commit hash of the entry under the cursor
            ["zR"] = cb("open_all_folds"),
            ["zM"] = cb("close_all_folds"),
            ["j"] = cb("next_entry"),
            ["<down>"] = cb("next_entry"),
            ["k"] = cb("prev_entry"),
            ["<up>"] = cb("prev_entry"),
            ["<cr>"] = cb("select_entry"),
            ["o"] = cb("select_entry"),
            ["<2-LeftMouse>"] = cb("select_entry"),
            ["<tab>"] = cb("select_next_entry"),
            ["<s-tab>"] = cb("select_prev_entry"),
            ["gf"] = cb("goto_file"),
            ["<C-w><C-f>"] = cb("goto_file_split"),
            ["<C-w>gf"] = cb("goto_file_tab"),
            ["<leader>e"] = cb("focus_files"),
            ["<leader>b"] = cb("toggle_files")
        },
        option_panel = {["<tab>"] = cb("select"), ["q"] = cb("close")}
    }
}

