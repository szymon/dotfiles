return {
    {
        "nvim-telescope/telescope.nvim",
        dependencies = {
            { "nvim-lua/plenary.nvim" },
            { "tribela/vim-transparent" },
        },
        config = function()
            local state = require("telescope.state")
            local action_state = require("telescope.actions.state")

            local actions = require("telescope.actions")

            local function scroll_window(bufnr, direction, mod)
                local previewer = action_state.get_current_picker(bufnr).previewer
                if type(previewer) ~= "table" or previewer.scroll_fn == nil then return end
                if type(mod) == "function" then mod = mod(bufnr) end

                local status = state.get_status(bufnr)
                local default_speed = vim.api.nvim_win_get_height(status.preview_win) / mod
                local speed = status.picker.layout_config.scroll_speed or default_speed

                previewer:scroll_fn(math.floor(speed * direction))
            end
            local function get_window_height(bufnr)
                local status = state.get_status(bufnr)
                return vim.api.nvim_win_get_height(status.preview_win)
            end

            require("telescope").setup({
                defaults = {
                    preview = {
                        filesize_hook = function(filepath, bufnr, opts)
                            local max_bytes = 10000;
                            local cmd = { "head", "-c", max_bytes, filepath }
                            require("telescope.previewers.utils").job_maker(cmd, bufnr, opts)
                        end
                    },
                    mappings = {
                        i = {
                            ["<c-f>"] = function(pbn) scroll_window(pbn, 1, 1) end,
                            ["<c-b>"] = function(pbn) scroll_window(pbn, -1, 1) end,
                            ["<c-e>"] = function(pbn) scroll_window(pbn, 1, get_window_height) end,
                            ["<c-y>"] = function(pbn) scroll_window(pbn, -1, get_window_height) end,
                            ["<c-k>"] = actions.move_selection_previous,
                            ["<c-j>"] = actions.move_selection_next,
                            ["<c-h>"] = actions.which_key,
                            ["<c-;>"] = actions.delete_buffer,
                            ["<esc>"] = actions.close,
                        }
                    }
                }
            })

            pcall(require("telescope").load_extension, "fzf")

            vim.keymap.set("n", "<c-p>", function() require('telescope.builtin').find_files() end,
                { silent = true, noremap = true, desc = "[telescope] open" }
            )
            vim.keymap.set("n", "<leader>hh",
                function() require("telescope.builtin").help_tags({ show_version = true }) end,
                { silent = true, noremap = true, desc = "[telescope] help" }
            )
            vim.keymap.set("n", "<leader>sw",
                function()
                    local word = vim.fn.expand("<cword>")
                    require("telescope.builtin").grep_string({ search = word })
                end,
                { silent = true, noremap = true, desc = "[telescope] search cword" }
            )
            vim.keymap.set("n", "<leader>sW",
                function()
                    local word = vim.fn.expand("<cWORD>")
                    require("telescope.builtin").grep_string({ search = word })
                end,
                { silent = true, noremap = true, desc = "[telescope] search cWORD" }
            )
            vim.keymap.set("n", "<leader>rr", function() require('telescope.builtin').live_grep() end,
                { silent = true, noremap = true, desc = "[telescope] live grep" }
            )
            vim.keymap.set("n", "<leader>gr",
                function() require('telescope.builtin').grep_string({ search = vim.fn.input("Grep > ") }) end,
                { silent = true, noremap = true, desc = "[telescope] open files after searching for a string" }
            )
            vim.keymap.set("n", "<leader>;",
                function() require('telescope.builtin').buffers({ sort_lastuse = true, ignore_current_buffer = true }) end,
                { silent = true, noremap = true, desc = "[telescope] open buffer list" }
            )
            vim.keymap.set("n", "<leader>sk", function() require('telescope.builtin').keymaps() end,
                { silent = true, noremap = true, desc = "[telescope] open keymaps" }
            )
            vim.keymap.set("n", "<leader>=", function() require('telescope.builtin').spell_suggest() end,
                { silent = true, noremap = true, desc = "[telescope] spelling" }
            )
            vim.keymap.set("n", "<leader>sgc", function() require('telescope.builtin').git_commits() end,
                { silent = true, noremap = true, desc = "[telescope] commits" }
            )
            vim.keymap.set("n", "<leader>sgb", function() require('telescope.builtin').git_bcommits() end,
                { silent = true, noremap = true, desc = "[telescope] bcommits" }
            )
            vim.keymap.set("n", "<leader>sgs", function() require('telescope.builtin').git_status() end,
                { silent = true, noremap = true, desc = "[telescope] git status" }
            )
        end
    },
}
