local Remap = require "szymon.keymap"
local nnoremap = Remap.nnoremap
local vnoremap = Remap.vnoremap
local inoremap = Remap.inoremap
local xnoremap = Remap.xnoremap
local nmap = Remap.nmap

-- gitsigns

nnoremap("<leader>hs", "<cmd>lua require('gitsigns').stage_hunk()<cr>")
nnoremap("<leader>hu", "<cmd>lua require('gitsigns').undo_stage_hunk()<cr>")
nnoremap("<leader>hr", "<cmd>lua require('gitsigns').reset_hunk()<cr>")
nnoremap("<leader>hR", "<cmd>lua require('gitsigns').reset_buffer()<cr>")
nnoremap("<leader>hp", "<cmd>lua require('gitsigns').preview_hunk()<cr>")
nnoremap("<leader>hb", "<cmd>lua require('gitsigns').blame_line()<cr>")
vnoremap("<leader>hs", "<cmd>lua require('szymon.functions').stage_selection()<cr>")

-- telescope

