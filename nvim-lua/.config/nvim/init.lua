vim.cmd [[source ~/.vimrc]]

require "plugins"
require "lsp_configs"

vim.opt.signcolumn = "yes"
vim.opt.wrap = false

vim.cmd [[
    nnoremap <c-p> <cmd>lua require('telescope.builtin').find_files()<cr>
    nnoremap <leader>rr <cmd>lua require('telescope.builtin').live_grep()<cr>
    nnoremap <leader>gr <cmd>lua require('telescope.builtin').grep_string()<cr>
    nnoremap <leader>; <cmd>lua require('telescope.builtin').buffers()<cr>
]]

require("telescope").setup({
    defaults = {mappings = {i = {["<c-k>"] = "move_selection_previous", ["<c-j>"] = "move_selection_next", ["<c-h>"] = "which_key"}}}
})

-- insert mode refresh completions (at word, at function call)
-- scrolling window with completions
--
-- some way to define actions on save (format, sort imports...)
-- highlight symbold on CursorHold (aucmd CursorHold * silent call CocActionAsync('highlight'))
