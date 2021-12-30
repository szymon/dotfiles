vim.cmd [[source ~/.vimrc]]

require "plugins"
require "lsp_configs"
require "statusline"

--
vim.opt.signcolumn = "yes"
vim.opt.wrap = false

local opts = {noremap = true, silent = true}
vim.api.nvim_set_keymap("n", "<c-p>", "<cmd>lua require('telescope.builtin').find_files()<cr>", opts)
vim.api.nvim_set_keymap("n", "<leader>rr", "<cmd>lua require('telescope.builtin').live_grep()<cr>", opts)
vim.api.nvim_set_keymap("n", "<leader>gr", "<cmd>lua require('telescope.builtin').grep_string()<cr>", opts)
vim.api.nvim_set_keymap("n", "<leader>;", "<cmd>lua require('telescope.builtin').buffers()<cr>", opts)
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
local actions = require("telescope.actions")
require("telescope").setup({
    defaults = {
        file_ignore_patterns = {".git/", "venv", ".venv"},
        mappings = {
            i = {["<c-k>"] = "move_selection_previous", ["<c-j>"] = "move_selection_next", ["<c-h>"] = "which_key", ["<esc>"] = actions.close}
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
