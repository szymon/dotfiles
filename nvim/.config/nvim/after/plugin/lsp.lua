local capabilities = nil
if pcall(require, "cmp_nvim_lsp") then
	capabilities = require("cmp_nvim_lsp").default_capabilities()
end

local servers = {
	zls = {},
	buf = {
		filetypes = { "proto" },
	},
    templ = {},
	-- html = {
	--     filetype = { "html", "templ" },
	-- },
	["htmx-lsp"] = {
		filetype = { "html", "templ" },
	},
	clangd = {
		filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
	},
	["tailwindcss-language-server"] = {
		filetype = {
			"templ",
			"astro",
			"javascript",
			"typescript",
			"react",
			"aspnetcorerazor",
			"astro",
			"astro-markdown",
			"blade",
			"clojure",
			"django-html",
			"htmldjango",
			"edge",
			"eelixir",
			"elixir",
			"ejs",
			"erb",
			"eruby",
			"gohtml",
			"gohtmltmpl",
			"haml",
			"handlebars",
			"hbs",
			"html",
			"html-eex",
			"heex",
			"jade",
			"leaf",
			"liquid",
			"markdown",
			"mdx",
			"mustache",
			"njk",
			"nunjucks",
			"razor",
			"slim",
			"twig",
			"css",
			"less",
			"postcss",
			"sass",
			"scss",
			"stylus",
			"sugarss",
			"javascript",
			"javascriptreact",
			"reason",
			"rescript",
			"typescript",
			"typescriptreact",
			"vue",
			"svelte",
			"jinja.html",
		},
		init_options = {
			userLanguages = { templ = "html" },
		},
	},
	opa = {},
	lua_ls = {
        manual_install = true,
        server_name = "lua-language-server",
		settings = {
			Lua = {
				runtime = { version = "LuaJIT" },
				workspace = {
					checkThirdParty = false,
					library = {
						"${3rd}/luv/library",
						unpack(vim.api.nvim_get_runtime_file("", true)),
					},
				},
				diagnostics = {
					globals = { "vim", "hs" },
				},
			},
		},
	},
	pyright = {
		capabilities = (function()
			local pyrightCapabilities = vim.lsp.protocol.make_client_capabilities()
			pyrightCapabilities.textDocument.publishDiagnostics = nil
			return pyrightCapabilities
		end)(),
		handlers = {
			["textDocument/publishDiagnostics"] = function(...) end,
		},
	},
	gopls = {
		settings = {
			gopls = {
				usePlaceholders = true,
				experimentalPostfixCompletions = true,
				-- analyses = { },
				gofumpt = true,
				codelenses = {
					generate = true,
					gc_details = true,
					regenerate_cgo = true,
					tidy = true,
					upgrade_depdendency = true,
					vendor = true,
				},
			},
		},
	},
	["typescript-language-server"] = {
		filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },
		init_options = {
			-- plugins = {
			-- 	{
			-- 		name = "@vue/typescript-plugin",
			-- 		location = vue_language_server_path,
			-- 		languages = { "vue" },
			-- 	},
			-- },
		},
	},
}

local servers_to_install = vim.tbl_filter(function(key)
	local t = servers[key]
	if type(t) == "table" then
		return not t.manual_install
	else
		return t
	end
end, vim.tbl_keys(servers))

local ensure_installed = {
	"stylua",
	"lua-language-server",
	"delve",
}

vim.list_extend(ensure_installed, servers_to_install)

require("mason").setup()
require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

-- set global capabilities
vim.lsp.config("*", {
	capabilities = capabilities,
})

for name, config in pairs(servers) do
	if config == true then
		config = {}
	end

	if next(config) ~= nil then
		local lsp_config = vim.tbl_deep_extend("force", {}, config)
		lsp_config.manual_install = nil
		vim.lsp.config(name, lsp_config)
	end

	vim.lsp.enable(name)
end

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local bn = args.buf
		local client = assert(vim.lsp.get_client_by_id(args.data.client_id), "must have valid client")

		vim.opt_local.omnifunc = "v:lua.vim.lsp.omnifunc"

		vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "[lsp] goto definition" })
		vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "[lsp] goto declaration" })
		vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "[lsp] hover" })
		vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { desc = "[lsp] goto implementation" })
		vim.keymap.set("n", "gr", vim.lsp.buf.references, { desc = "[lsp] find references" })
		vim.keymap.set("n", "<leader>k", vim.lsp.buf.signature_help, { desc = "[lsp] signature help" })
		vim.keymap.set("i", "<c-k>", vim.lsp.buf.signature_help, { desc = "[lsp] signature help" })
		vim.keymap.set("n", "<leader>D", vim.lsp.buf.type_definition, { desc = "[lsp] type definition" })
		vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "[lsp] rename" })
		vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "[lsp] code actions" })

       -- if client:supports_method("textDocument/completion") then
       --     vim.lsp.completion.enable(true, client.id, bn, {autotrigger = true})
       -- end
	end,
})

---@diagnostic disable-next-line
vim.lsp.handlers["textDocument/definition"] = function(_, result)
	if not result or vim.tbl_isempty(result) then
		print("[LSP] Could not find definition")
		return
	end
	if vim.tbl_islist(result) then
		vim.lsp.util.jump_to_location(result[1], "utf-8")
	else
		vim.lsp.util.jump_to_location(result, "utf-8")
	end
end

require("fidget").setup({})
