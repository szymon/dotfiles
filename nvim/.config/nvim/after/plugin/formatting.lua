conform = require("conform")
conform.setup({
	default_format_opts = {
		lsp_format = "last",
	},
	formatters_by_ft = {
		lua = { "stylua" },
		go = { "goimports", "gofmt" },
		rust = { "rustfmt", lsp_format = "fallback" },
		-- Conform will run the first available formatter
		javascript = { "prettierd", "prettier", stop_after_first = true },
	},
})

vim.keymap.set("n", "<leader>f", function()
	local buffer = vim.api.nvim_get_current_buf()
	conform.format({
		bufnr = buffer,
		async = true,
		filter = function(client)
			return client.name ~= "html"
		end,
	})
end, {
	remap = true,
	desc = "[general] try to format with conform or lsp",
})
