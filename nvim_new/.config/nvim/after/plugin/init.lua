local Remap = require "szymon.keymap"
local nnoremap = Remap.nnoremap
local vnoremap = Remap.vnoremap
local inoremap = Remap.inoremap
local xnoremap = Remap.xnoremap
local nmap = Remap.nmap

vnoremap("J", ":m '>+1<cr>gv=gv")
vnoremap("L", ":m '<-2<cr>gv=gv")

nnoremap("Y", "yg$")

xnoremap("<leader>p", '"_dP')

nnoremap("Q", "<nop>")

-- gitsigns

nnoremap("<leader>hs", "<cmd>lua require('gitsigns').stage_hunk()<cr>")
nnoremap("<leader>hu", "<cmd>lua require('gitsigns').undo_stage_hunk()<cr>")
nnoremap("<leader>hr", "<cmd>lua require('gitsigns').reset_hunk()<cr>")
nnoremap("<leader>hR", "<cmd>lua require('gitsigns').reset_buffer()<cr>")
nnoremap("<leader>hp", "<cmd>lua require('gitsigns').preview_hunk()<cr>")
nnoremap("<leader>hb", "<cmd>lua require('gitsigns').blame_line()<cr>")
vnoremap("<leader>hs", "<cmd>lua require('szymon.functions').stage_selection()<cr>")

-- telescope

local telescope_actions = require("telescope.actions")

nnoremap("<c-p>", "<cmd>lua require('telescope.builtin').find_files({})<cr>")
nnoremap("<leader>rr", "<cmd>lua require('telescope.builtin').live_grep()<cr>")
nnoremap("<leader>gr", "<cmd>lua require('telescope.builtin').grep_string()<cr>")
nnoremap("<leader>;", "<cmd>lua require('telescope.builtin').buffers({sort_lastuse = true, ignore_current_buffer = true})<cr>")
-- nnoremap("<leader>fh", "<cmd>lua require('telescope.builtin').help_tags()<cr>")
nnoremap("<leader>fk", "<cmd>lua require('telescope.builtin').keymaps()<cr>")
nnoremap("<leader>=", "<cmd>lua require('telescope.builtin').spell_suggest()<cr>")
nnoremap("<leader>fgc", "<cmd>lua require('telescope.builtin').git_commits()<cr>")
nnoremap("<leader>fgb", "<cmd>lua require('telescope.builtin').git_bcommits()<cr>")
nnoremap("<leader>fgs", "<cmd>lua require('telescope.builtin').git_status()<cr>")

nnoremap("<leader>tt", "<cmd>TroubleToggle<cr>")
