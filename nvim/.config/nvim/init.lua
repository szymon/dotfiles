vim.cmd([[ source ~/.vimrc ]])

vim.opt.guicursor = ""
vim.opt.signcolumn = "yes"
vim.opt.wrap = false
vim.opt.spell = false
vim.opt.relativenumber = true
vim.opt.number = true
vim.opt.colorcolumn = "88,120"
vim.opt.background = "dark"
vim.opt.laststatus = 3
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undo"
vim.opt.undofile = true
vim.opt.updatetime = 200

vim.g.mouse = "a"

-- general keymaps
vim.keymap.set("v", "J", ":m '>+1<cr>gv=gv", { desc = "[general] move selected line down" })
vim.keymap.set("v", "L", ":m '<-2<cr>gv=gv", { desc = "[general] move selected line up" })

vim.keymap.set("n", "Y", "yg$", { desc = "[general] yank to end of line" })

vim.keymap.set("x", "<leader>p", '"_dP', { desc = "[general] paste without overwriting clipboard" })

-- disable ex mode
vim.keymap.set("n", "Q", "<nop>", { desc = "[general] disable ex mode" })

-- keep cursor inplace when joining lines
vim.keymap.set("n", "J", "mzJ`z", { desc = "[general] join lines without moving the cursor" })

-- keep cursor in the center when jumping half page
vim.keymap.set("n", "<c-d>", "<c-d>zz", { desc = "[general] jump half page down and center the cursor" })
vim.keymap.set("n", "<c-u>", "<c-u>zz", { desc = "[general] jump half page up and center the cursor" })

-- keep cursor in the center when searching with n/N
vim.keymap.set("n", "n", "nzzzv", { desc = "[general] search next and center the cursor" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "[general] search previous and center the cursor" })

vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<cr>", { desc = "[general] make file executable" })

vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "[general] open diagnostics" })
-- vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)

-- vim.keymap.set("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end,
--     { desc = "[general] go to previous diagnostic" })
-- vim.keymap.set("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end,
--     { desc = "[general] go to next diagnostic" })

vim.keymap.set("n", ";", "dd", { desc = "[general] remove line" })

vim.keymap.set("n", "<leader>m", function()
	--[[
    --  toggle between normal file and test file.
    --]]
	-- Get the current file's full path
	local current_file = vim.api.nvim_buf_get_name(0)

	-- Extract the directory and filename
	local dir = vim.fn.fnamemodify(current_file, ":h") -- Get the directory
	local filename = vim.fn.fnamemodify(current_file, ":t") -- Get the filename

	-- Determine the target file
	local target_file
	if filename:match("_test%.go$") then
		-- If the current file is a test file, switch to the implementation file
		target_file = filename:gsub("_test%.go$", ".go")
	elseif filename:match("%.go$") then
		-- If the current file is an implementation file, switch to the test file
		target_file = filename:gsub("%.go$", "_test.go")
	else
		print("Not a Go file or test file!")
		return
	end

	-- Construct the full path to the target file
	local target_path = dir .. "/" .. target_file

	-- Check if the target file is already open in a buffer
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_loaded(buf) then
			local buf_path = vim.api.nvim_buf_get_name(buf)
			if buf_path == target_path then
				-- Find the window displaying the buffer
				for _, win in ipairs(vim.api.nvim_list_wins()) do
					if vim.api.nvim_win_get_buf(win) == buf then
						-- Switch to the window displaying the buffer
						vim.api.nvim_set_current_win(win)
						print("Switched to already open file: " .. target_path)
						return
					end
				end
			end
		end
	end

	vim.cmd("rightb vsplit " .. target_path)
end)

local function dupLine(opts)
	if opts == nil then
		opts = {
			count = 1,
		}
	end
	local bufnr = vim.api.nvim_get_current_buf()
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))
	local line = vim.api.nvim_buf_get_lines(bufnr, row - 1, row, false)
	vim.api.nvim_buf_set_lines(bufnr, row, row, false, line)
	vim.api.nvim_win_set_cursor(0, { row + opts.count, col })
end

vim.keymap.set("n", "gb", dupLine, { desc = "[general] duplicate current line and move down" })

require("custom.statusline").setup()

vim.pack.add({
	"https://github.com/stevearc/oil.nvim",
	"https://github.com/stevearc/conform.nvim",
	"https://github.com/ibhagwan/fzf-lua",
	"https://github.com/supermaven-inc/supermaven-nvim",
	"https://github.com/lewis6991/gitsigns.nvim",
	"https://github.com/nvim-lua/plenary.nvim",
	"https://github.com/tpope/vim-fugitive",
	"https://github.com/google/vim-jsonnet",
	"https://github.com/ThePrimeagen/harpoon",
	"https://github.com/ray-x/go.nvim",
	"https://github.com/ellisonleao/gruvbox.nvim",
	-- cmp
	"https://github.com/hrsh7th/nvim-cmp",
	"https://github.com/saadparwaiz1/cmp_luasnip",
	"https://github.com/hrsh7th/cmp-nvim-lsp",
	"https://github.com/hrsh7th/cmp-path",
	"https://github.com/L3MON4D3/LuaSnip",
    -- "https://github.com/saghen/blink.cmp",
	-- lsp
	"https://github.com/williamboman/mason.nvim",
	"https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim",
	"https://github.com/j-hui/fidget.nvim",
    "https://github.com/neovim/nvim-lspconfig",
    -- treesitter
    "https://github.com/nvim-treesitter/nvim-treesitter",
}, {
	confirm = false,
})

vim.diagnostic.config({
	virtual_text = true,
	update_in_insert = true,
	signs = { severity_limit = "Error" },
	underline = { severity_limit = "Warning" },
})
