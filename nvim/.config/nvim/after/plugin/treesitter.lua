require("nvim-treesitter").setup({
	indent = {
		enable = true,
		-- disable = { "javascript" },
	},

	ensure_installed = {
		"go",
		"html",
		"javascript",
		"json",
		"markdown",
		"python",
		"query",
		"rust",
		"toml",
		"yaml",
		"nix",
		"lua",
		"css",
		"bash",
		"dockerfile",
		"templ",
		"zig",
	},

	highlight = {
		enable = true,
		additional_vim_regex_highlighting = true,
	},

	refactor = {
		highlight_definitions = { enable = true },
		highlight_current_scope = { enable = false },
	},

	incremental_selection = { enable = false },

	playground = {
		enable = true,
		updatetime = 25,
	},

	textobjects = {
		enable = true,
		lookahead = true,
		keymaps = {},
	},
})

vim.treesitter.language.register("sql", {"sql", "psql"})
vim.treesitter.language.add("sql", { path = "/Users/srams/code/tree-sitter-sql/sql.so" })

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "*" },
	callback = function()
		local filetype = vim.bo.filetype
		if filetype and filetype ~= "" then
			local success = pcall(function()
				vim.treesitter.start()
			end)
			if not success then
				return
			end
		end
	end,
})
