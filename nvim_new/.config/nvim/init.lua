vim.cmd [[ source ~/.vimrc ]]

require "szymon"

local formatters = require("szymon.format")

local Remap = require("szymon.keymap")
local vnoremap = Remap.vnoremap
local xnoremap = Remap.xnoremap
local nnoremap = Remap.nnoremap

vim.opt.guicursor = ""
vim.opt.signcolumn = "yes"
vim.opt.wrap = false
vim.opt.spell = false
vim.opt.relativenumber = true
vim.opt.number = true
vim.opt.colorcolumn = "88"
vim.opt.laststatus = 3
vim.opt.background = "dark"
vim.g.mouse = "a"

vim.g.gruvbox_flat_style = "hard"
vim.g.Illuminate_delay = 300
vim.g.undotree_DiffAutoOpen = false

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. '/.vim/undo'
vim.opt.undofile = true

vim.opt.updatetime = 50

vnoremap("J", ":m '>+1<cr>gv=gv")
vnoremap("L", ":m '<-2<cr>gv=gv")

nnoremap("Y", "yg$")

xnoremap("<leader>p", '"_dP')

-- disable ex mode
nnoremap("Q", "<nop>")

-- keep cursor inplace when joining lines
nnoremap("J", "mzJ`z")

-- keep cursor in the center when jumping half page
nnoremap("<c-d>", "<c-d>zz")
nnoremap("<c-u>", "<c-u>zz")
-- keep cursor in the center when searching with n/N
nnoremap("n", "nzzzv")
nnoremap("N", "Nzzzv")

nnoremap("<leader>gs", vim.cmd.Git)
nnoremap("<leader>u", vim.cmd.UndotreeToggle)

vim.cmd [[ 
    colorscheme gruvbox-material

    hi WinSeperator guibg=none
    hi def link LspReferenceText CursorLine
    hi def link LspReferenceWrite CursorLine
    hi def link LspReferenceRead CursorLine
]]

vim.cmd [[
    command! GoImports lua require("szymon.golang").ord_imports()
		command! SqlFormat lua require("szymon.format").format_dat_sql()
]]

local overwrite_filetype_defaults = vim.api.nvim_create_augroup("overwrite_filetype_defaults", {clear = true});
vim.api.nvim_create_autocmd("FileType", {pattern = "yaml", command = "setlocal ts=12 sts=2 sw=2 expandtab indentkeys-=<:>", group = overwrite_filetype_defaults})
vim.api.nvim_create_autocmd("FileType", {pattern = "go", command = "setlocal noexpandtab ts=4 sts=4 sw=4", group = overwrite_filetype_defaults})
vim.api.nvim_create_autocmd("FileType", {pattern = "lua", command = "setlocal noexpandtab ts=2 sts=2 sw=2", group = overwrite_filetype_defaults})

local hightlight_group = vim.api.nvim_create_augroup("YankHi", {clear = true})
vim.api.nvim_create_autocmd("TextYankPost", {callback = function() vim.highlight.on_yank() end, group = hightlight_group, pattern = "*"})

local custom_formatting = vim.api.nvim_create_augroup("custom_on_write", {clear = true});
vim.api.nvim_create_autocmd("BufWritePre", {pattern = "*.py,*.lua", callback = function() formatters.format({async = true}) end, group = custom_formatting})
vim.api.nvim_create_autocmd("BufWritePre", {pattern = "*.go", callback = function() formatters.format({async = false}) end, group = custom_formatting})
vim.api.nvim_create_autocmd("BufWritePre", {pattern = "*.py,*.sql", callback = function() formatters.format_dat_sql() end, group = custom_formatting})
