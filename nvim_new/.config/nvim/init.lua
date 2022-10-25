vim.cmd [[ source ~/.vimrc ]]

require "szymon"


vim.opt.signcolumn = "yes"
vim.opt.wrap = false
vim.opt.spell = false
vim.opt.relativenumber = true
vim.opt.number = true
vim.opt.colorcolumn = "88"
vim.opt.laststatus = 3
vim.opt.background = "dark"

vim.g.gruvbox_flat_style = "hard"

vim.cmd [[ colorscheme tokyonight-night ]]
vim.cmd [[ hi WinSeperator guibg=none ]]


vim.g.Illuminate_delay = 300
vim.api.nvim_command [[ hi def link LspReferenceText CursorLine ]]
vim.api.nvim_command [[ hi def link LspReferenceWrite CursorLine ]]
vim.api.nvim_command [[ hi def link LspReferenceRead CursorLine ]]
