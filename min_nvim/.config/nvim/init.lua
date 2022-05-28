local util = require "lspconfig/util"
vim.cmd "packadd packer.nvim"

vim.o.signcolumn = "yes"

local packer = require "packer"
local use = packer.use

packer.startup(function()
	use "wbthomason/packer.nvim"
	use {
		"hrsh7th/nvim-cmp",
		requires = {
			"neovim/nvim-lspconfig",
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline"
		}
	}
	use "nvim-treesitter/nvim-treesitter"
	use "neovim/nvim-lspconfig"
end)

local lsp_config = require "lspconfig"
local cmp = require "cmp"

cmp.setup {
	preselect = cmp.PreselectMode.None,
	mapping = cmp.mapping.preset.insert {
		["<tab>"] = cmp.mapping(
			function (fallback)
				if cmp.visible() then
					cmp.select_next_item()
				else
					fallback()
				end
			end,
			{"i"}
		),
		["<s-tab>"] = cmp.mapping(
			function (fallback)
				if cmp.visible() then
					cmp.select_prev_item()
				else
					fallback()
				end
			end,
			{"i"}
		),
		["<c-y>"] = cmp.mapping(
			cmp.mapping.confirm(), {"i"}
		),
	},
	sources = cmp.config.sources({{name = "nvim_lsp"}}, {{name = "buffer"}})
}

local capabilities = require("cmp_nvim_lsp").update_capabilities(vim.lsp.protocol.make_client_capabilities())

local on_attach = function(client, bufnr)
	local function buf_set_keymap(...)
		vim.api.nvim_buf_set_keymap(bufnr, ...)
	end

	local opts = {noremap = true, silent = true}

	-- See `:help vim.lsp.*` for documentation on any of the below functions
	buf_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
	buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
	buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
	buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
	buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
	buf_set_keymap('n', '<leader>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
	buf_set_keymap('n', '<leader>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
	buf_set_keymap('n', '<leader>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
	buf_set_keymap('n', '<leader>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
	buf_set_keymap('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
	buf_set_keymap('n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
	buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
	buf_set_keymap('n', '<leader>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
	buf_set_keymap('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
	buf_set_keymap('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
	buf_set_keymap('n', '<leader>q', '<cmd>lua vim.lsp.diagnostic.set_quickfixlist()<CR>', opts)
	buf_set_keymap('n', '<leader>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)

end

lsp_config.gopls.setup {
	cmd = {"gopls", "serve"},
	on_attach = on_attach,
	capabilities = capabilities,
	filetypes = {"go", "gomod"},
	root_dir = util.root_pattern("go.work", "go.mod", ".git"),
	settings = {gopls = {analyses = {unusedparams = true, shadow = true}, staticcheck = true}}
}

lsp_config.pyright.setup {
	on_attach = on_attach,
	capabilities = capabilities,
	flags = {debounce_text_changes = 150},
	settings = {
		python = {analysis = {autoSearchPaths = true, diagnosticMode = "workspace", useLibraryCodeForTypes = true}}
	}
}

