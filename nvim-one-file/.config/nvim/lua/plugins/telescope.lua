return {
    {
        'dmtrKovalenko/fff.nvim',
        build = function()
            -- this will download prebuild binary or try to use existing rustup toolchain to build from source
            -- (if you are using lazy you can use gb for rebuilding a plugin if needed)
            require("fff.download").download_or_build_binary()
        end,
        -- if you are using nixos
        -- build = "nix run .#release",
        opts = {                    -- (optional)
            debug = {
                enabled = false,    -- we expect your collaboration at least during the beta
                show_scores = true, -- to help us optimize the scoring system, feel free to share your scores!
            },
        },
        -- No need to lazy-load with lazy.nvim.
        -- This plugin initializes itself lazily.
        lazy = false,
        keys = {
            {
                "ff", -- try it if you didn't it is a banger keybinding for a picker
                function() require('fff').find_files() end,
                desc = 'FFFind files',
            }
        }
    },
    {
        "ibhagwan/fzf-lua",
        config = function()
            local fzf = require("fzf-lua")

            fzf.setup({
                { "telescope", "fzf-native", "max-perf" },
                keymap = {
                    fzf = {
                        ["ctrl-q"] = "select-all+accept",
                    },
                },
                files = {
                    cmd = [[rg --files --color=never --hidden -g '!.git' -g '!*.pb.go' -g '!*.pb.mock.go' -g '!.jj/' ]],
                },
            })

            vim.keymap.set("n", "<c-p>", fzf.files)
            vim.keymap.set("n", "<leader>;", fzf.buffers)
            vim.keymap.set("n", "<leader>gr", fzf.live_grep_native)
            vim.keymap.set("n", "<leader>sw", fzf.grep_cword)
        end,
    },
    {
        "benfowler/telescope-luasnip.nvim",
        module = "telescope._extensions.luasnip", -- if you wish to lazy-load
    },
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
                pickers = {
                },
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
                            -- ["<m-d>"] = actions.delete_buffer,
                            ["<esc>"] = actions.close,
                        }
                    }
                }
            })

            pcall(require("telescope").load_extension, "fzf")
            pcall(require("telescope").load_extension, "luasnip")

            -- vim.keymap.set("n", "<c-p>", function()
            --         require('telescope.builtin').find_files(
            --             {
            --                 hidden = true,
            --                 find_command = {
            --                     "rg",
            --                     "--files",
            --                     "--hidden",
            --                     "--glob=!**/.git/*",
            --                     "--glob=!**/.idea/*",
            --                     "--glob=!**/.vscode/*",
            --                     "--glob=!**/build/*",
            --                     "--glob=!**/dist/*",
            --                     "--glob=!**/yarn.lock",
            --                     "--glob=!**/package-lock.json",
            --                     "--glob=!*.pb.go",
            --                 },
            --             }
            --         )
            --     end,
            --     { silent = true, noremap = true, desc = "[telescope] open" }
            -- )
            -- vim.keymap.set("n", "<leader>hh",
            --     function() require("telescope.builtin").help_tags({ show_version = true }) end,
            --     { silent = true, noremap = true, desc = "[telescope] help" }
            -- )
            -- vim.keymap.set("n", "<leader>sw",
            --     function()
            --         local word = vim.fn.expand("<cword>")
            --         require("telescope.builtin").grep_string({ search = word })
            --     end,
            --     { silent = true, noremap = true, desc = "[telescope] search cword" }
            -- )
            -- vim.keymap.set("v", "<leader>s",
            --     function()
            --         local _, start_row, start_col = unpack(vim.fn.getpos("v"))
            --         local _, end_row, end_col = unpack(vim.fn.getpos("."))

            --         print(vim.inspect({ start_row, start_col, end_row, end_col }))

            --         if start_row ~= end_row then
            --             print("Selection spans multiple lines. This function only supports single-line selections.")
            --             return ""
            --         end

            --         if start_col > end_col then
            --             start_col, end_col = end_col, start_col
            --         end

            --         local line_content = vim.api.nvim_buf_get_lines(
            --             0,
            --             start_row - 1,
            --             start_row,
            --             false
            --         )[1]

            --         start_col = start_col - 1
            --         end_col = end_col - 1

            --         local word = line_content:sub(start_col + 1, end_col + 1)
            --         require("telescope.builtin").grep_string({ search = word })
            --     end,
            --     { silent = true, noremap = true, desc = "[telescope] search cword" }
            -- )
            -- vim.keymap.set("n", "<leader>sW",
            --     function()
            --         local word = vim.fn.expand("<cWORD>")
            --         require("telescope.builtin").grep_string({ search = word })
            --     end,
            --     { silent = true, noremap = true, desc = "[telescope] search cWORD" }
            -- )
            -- vim.keymap.set("n", "<leader>rr", function()
            --         -- TODO: move this to seperate file
            --         local pickers = require "telescope.pickers"
            --         local finders = require "telescope.finders"
            --         local make_entry = require "telescope.make_entry"
            --         local conf = require "telescope.config".values

            --         local opts = {}
            --         opts.cwd = vim.uv.cwd()

            --         local finder = finders.new_async_job({
            --             command_generator = function(prompt)
            --                 if not prompt or prompt == "" then
            --                     return nil
            --                 end

            --                 local pieces = vim.split(prompt, "  ")
            --                 local args = { "rg" }
            --                 if pieces[1] then
            --                     table.insert(args, "-e")
            --                     table.insert(args, pieces[1])
            --                 end

            --                 if pieces[2] then
            --                     table.insert(args, "-g")
            --                     table.insert(args, pieces[2])
            --                 end

            --                 ---@diagnostic disable-next-line: deprecated
            --                 return vim.tbl_flatten({
            --                     args,
            --                     { "--color=never", "--no-heading", "--with-filename", "--line-number", "--column",
            --                         "--smart-case" },
            --                 })
            --             end,
            --             entry_maker = make_entry.gen_from_vimgrep(opts),
            --             cwd = opts.cwd,
            --         })

            --         pickers.new(opts, {
            --             debounce = 100,
            --             prompt_title = "Multi Grep",
            --             finder = finder,
            --             previewer = conf.grep_previewer(opts),
            --             sorter = require("telescope.sorters").empty(),
            --         }):find()
            --     end,
            --     { silent = true, noremap = true, desc = "[telescope] live grep" }
            -- )
            -- vim.keymap.set("n", "<leader>gr",
            --     function() require('telescope.builtin').grep_string({ search = vim.fn.input("Grep > ") }) end,
            --     { silent = true, noremap = true, desc = "[telescope] open files after searching for a string" }
            -- )
            -- vim.keymap.set("n", "<leader>;",
            --     function() require('telescope.builtin').buffers({ sort_lastuse = true, ignore_current_buffer = true }) end,
            --     { silent = true, noremap = true, desc = "[telescope] open buffer list" }
            -- )
            -- vim.keymap.set("n", "<leader>sk", function() require('telescope.builtin').keymaps() end,
            --     { silent = true, noremap = true, desc = "[telescope] open keymaps" }
            -- )
            -- vim.keymap.set("n", "<leader>=", function() require('telescope.builtin').spell_suggest() end,
            --     { silent = true, noremap = true, desc = "[telescope] spelling" }
            -- )
            -- vim.keymap.set("n", "<leader>sgc", function() require('telescope.builtin').git_commits() end,
            --     { silent = true, noremap = true, desc = "[telescope] commits" }
            -- )
            -- vim.keymap.set("n", "<leader>sgb", function() require('telescope.builtin').git_bcommits() end,
            --     { silent = true, noremap = true, desc = "[telescope] bcommits" }
            -- )
            -- vim.keymap.set("n", "<leader>sgs", function() require('telescope.builtin').git_status() end,
            --     { silent = true, noremap = true, desc = "[telescope] git status" }
            -- )
        end
    },
}
