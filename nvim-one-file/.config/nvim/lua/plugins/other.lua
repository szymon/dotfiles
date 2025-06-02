return {

    {
        "lewis6991/gitsigns.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        lazy = false,
        config = function()
            require("gitsigns").setup({
                watch_gitdir = { interval = 1000 }
            })
            vim.api.nvim_set_hl(0, "GitSignsAdd", { link = "SignAdd" })
            vim.api.nvim_set_hl(0, "GitSignsChange", { link = "SignChange" })
            vim.api.nvim_set_hl(0, "GitSignsChangedelete", { link = "SignChange" })
            vim.api.nvim_set_hl(0, "GitSignsDelete", { link = "SignDelete" })
            vim.api.nvim_set_hl(0, "GitSignsTopdelete", { link = "SignDelete" })
            vim.api.nvim_set_hl(0, "GitSignsUntracked", { link = "SignAdd" })
        end,
        keys = {
            { "<leader>hs", [[<cmd>lua require('gitsigns').stage_hunk()<cr>]],      desc = "[gitsigns] stage hunk" },
            { "<leader>hs", [[<cmd>lua require('gitsigns').stage_hunk()<cr>]],      desc = "[gitsigns] stage hunk" },
            { "<leader>hu", [[<cmd>lua require('gitsigns').undo_stage_hunk()<cr>]], desc = "[gitsigns] undo stage hunk" },
            { "<leader>hr", [[<cmd>lua require('gitsigns').reset_hunk()<cr>]],      desc = "[gitsigns] reset hunk" },
            { "<leader>hR", [[<cmd>lua require('gitsigns').reset_buffer()<cr>]],    desc = "[gitsigns] reset buffer" },
            { "<leader>hp", [[<cmd>lua require('gitsigns').preview_hunk()<cr>]],    desc = "[gitsigns] preview hunk" },
            { "<leader>hb", [[<cmd>lua require('gitsigns').blame_line()<cr>]],      desc = "[gitsigns] blame line" },
            { "]h",         [[<cmd>lua require('gitsigns').next_hunk()<cr>]],       desc = "[gitsigns] next hunk" },
            { "[h",         [[<cmd>lua require('gitsigns').prev_hunk()<cr>]],       desc = "[gitsigns] next hunk" },
        },
    },


    {
        "tpope/vim-fugitive",
        lazy = false,
        keys = {
            { "<leader>gs", "<cmd>Git<cr>", mode = "n" },
        },
    },
    {
        "stevearc/conform.nvim",
        opts = {
            default_format_opts = {
                lsp_format = "last",
            },
        },
    },
    -- { "petertriho/cmp-git",           dependencies = "nvim-lua/plenary.nvim" },
    { "Vimjas/vim-python-pep8-indent" },
    { "google/vim-jsonnet",           event = { "BufEnter", }, filetype = { "jsonnet" }, },
    -- {
    --     'folke/trouble.nvim',
    --     config = function()
    --         require("trouble").setup({
    --             icons = false,
    --         })

    --         vim.keymap.set("n", "[d", function() require("trouble").next({ jump = true, skip_groups = true }) end)
    --         vim.keymap.set("n", "]d", function() require("trouble").previous({ jump = true, skip_groups = true }) end)
    --         vim.keymap.set("n", "gtt", function() require("trouble").toggle({}) end)
    --     end,
    -- },
    -- {
    --     "zbirenbaum/copilot.lua",
    --     cmd = "Copilot",
    --     event = "InsertEnter",
    --     opts = {
    --         suggestion = { enabled = false },
    --         panel = { enabled = false },
    --     },
    -- },
    -- {
    --     "zbirenbaum/copilot-cmp",
    --     after = { "copilot.lua" },
    --     opts = {},
    -- },
    {
        "mfussenegger/nvim-lint",
        event = "VeryLazy",
        opts = {
            events = { "BufWritePost", "BufReadPost", "InsertLeave" },
            linters_by_ft = {
                go = { "golangcilint" },
            }
        },
        config = function(_, opts)
            local lint = require("lint")
            for name, linter in pairs(opts.linters or {}) do
                if type(linter) == "table" and type(lint.linters[name]) == "table" then
                    lint.linters[name] = vim.tbl_deep_extend("force", lint.linters[name], linter)
                    if type(linter.prepend_args) == "table" then
                        lint.linters[name].args = lint.linters[name].args or {}
                        vim.list_extend(lint.linters[name].args, linter.prepend_args)
                    end
                else
                    lint.linters[name] = linter
                end
            end
            lint.linters_by_ft = opts.linters_by_ft

            lint.linters.golangcilint.args = {
                'run',
                '--output.json.path=stdout',
                '--issues-exit-code=0',
                '--show-stats=false',
                '--output.text.print-issued-lines=false',
                '--output.text.print-linter-name=false',
                function()
                    return vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":h")
                end
            }

            vim.api.nvim_create_autocmd(opts.events, {
                group = vim.api.nvim_create_augroup("nvim-lint", { clear = true }),
                callback = function() require("lint").try_lint() end,
            })
        end,
    },

    {
        "ThePrimeagen/harpoon",
        branch = "harpoon2",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            local harpoon = require("harpoon")
            harpoon:setup()

            vim.keymap.set("n", "<leader>aa", function() harpoon:list():add() end, { desc = "[harpoon] add to list" })
            vim.keymap.set("n", "<leader>ae", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end,
                { desc = "[harpoon] edit list" })
            vim.keymap.set("n", "<leader>1", function() harpoon:list():select(1) end, { desc = "[harpoon] select 1" })
            vim.keymap.set("n", "<leader>2", function() harpoon:list():select(2) end, { desc = "[harpoon] select 2" })
            vim.keymap.set("n", "<leader>3", function() harpoon:list():select(3) end, { desc = "[harpoon] select 3" })
            vim.keymap.set("n", "<leader>4", function() harpoon:list():select(4) end, { desc = "[harpoon] select 4" })
        end,
    },

    { "nvim-treesitter/nvim-treesitter-angular" },
    {
        "nvim-treesitter/nvim-treesitter-context",
        opts = {
            max_lines = 2,
            trim_scope = "inner",
        },
    },
    {
        "ray-x/go.nvim",
        event = { "CmdlineEnter" },
        dev = true,
        ft = { "go", "gomod" },
        opts = {},
        build = ":lua require('go.install').update_all_sync()",
    },
}
