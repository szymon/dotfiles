return {
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            ---@diagnostic disable-next-line
            require("nvim-treesitter.configs").setup({

                ensure_installed = {
                    "go", "html", "javascript", "json", "markdown", "python", "query",
                    "rust", "toml", "yaml", "nix", "lua", "css", "bash", "dockerfile",
                    "templ", "zig",
                },


                highlight = {
                    enable = true,
                    additional_vim_regex_highlighting = false
                },

                refactor = {
                    highlight_definitions = { enable = true },
                    highlight_current_scope = { enable = false },
                },

                incremental_selection = {
                    enable = true,
                    keymaps = {
                        init_selection = "<M-w>",
                        node_incremental = "<M-w>",
                        node_decremental = "<M-C-w>",
                        scope_incremental = "<M-e>"
                    }
                },

                playground = {
                    enable = true,
                    updatetime = 25,
                },

                textobjects = {
                    enable = true,
                    lookahead = true,
                    keymaps = {
                    },
                },
            })


            vim.treesitter.language.add('sql', { path = "/Users/srams/code/tree-sitter-sql/sql.so" })
        end
    },
}
