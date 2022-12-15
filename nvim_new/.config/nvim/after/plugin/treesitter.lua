if not pcall(require, "nvim-treesitter") then return end

local _ = require("nvim-treesitter.configs").setup({
  ensure_installed = {"go", "html", "javascript", "json", "markdown", "python", "query", "rust", "toml", "yaml"},

  highlight = {enable = true, additional_vim_regex_highlighting = false},

  incremental_selection = {enable = true, keymaps = {init_selection = "<M-w>", node_incremental = "<M-w>", node_decremental = "<M-C-w>", scope_incremental = "<M-e>"}},

  playground = {enable = true, updatetime = 25}
})
