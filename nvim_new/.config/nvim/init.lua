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
vim.g.Illuminate_delay = 300

vim.cmd [[ 
    colorscheme gruvbox-material

    hi WinSeperator guibg=none
    hi def link LspReferenceText CursorLine
    hi def link LspReferenceWrite CursorLine
    hi def link LspReferenceRead CursorLine
]]
