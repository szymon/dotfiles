vim.cmd [[ source ~/.vimrc ]]

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
vim.filetype.add({ extension = { templ = "templ" } })

vim.g.mouse = "a"
vim.g.gruvbox_flat_style = "hard"
vim.g.Illuminate_delay = 300
vim.g.undotree_DiffAutoOpen = false

-- Keymaps {{{
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


vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "[general] go to previous diagnostic" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "[general] go to next diagnostic" })

-- }}}

-- Plugins {{{

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end

---@diagnostic disable-next-line
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    {
        "ellisonleao/gruvbox.nvim",
        priority = 1000,
        config = function()
            require("gruvbox").setup({
                bold = false,
                italics = {
                    comments = false,
                    keywords = false,
                    functions = false,
                    strings = false,
                    variables = false,
                },
            })
            vim.cmd("colorscheme gruvbox")
        end,
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
                defaults = {
                    mappings = {
                        i = {
                            ["<c-f>"] = function(pbn) scroll_window(pbn, 1, 1) end,
                            ["<c-b>"] = function(pbn) scroll_window(pbn, -1, 1) end,
                            ["<c-e>"] = function(pbn) scroll_window(pbn, 1, get_window_height) end,
                            ["<c-y>"] = function(pbn) scroll_window(pbn, -1, get_window_height) end,
                            ["<c-k>"] = actions.move_selection_previous,
                            ["<c-j>"] = actions.move_selection_next,
                            ["<c-h>"] = actions.which_key,
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
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            ---@diagnostic disable-next-line
            require("nvim-treesitter.configs").setup({

                ensure_installed = {
                    "go", "html", "javascript", "json", "markdown", "python", "query",
                    "rust", "toml", "yaml", "nix", "lua", "css", "bash", "dockerfile",
                    "templ",
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
        end
    },
    {
        "lewis6991/gitsigns.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        lazy = false,
        config = function()
            require("gitsigns").setup {
                signs = {
                    add = { hl = "SignAdd", text = "+" },
                    change = { hl = "SignChange", text = "~" },
                    delete = { hl = "SignDelete", text = "-" },
                    topdelete = { hl = "SignDelete", text = "-" },
                    changedelete = { hl = "SignChange", text = "~" },
                    untracked = { hl = "SignAdd", text = "|" },
                },
                watch_gitdir = { interval = 1000 }
            }

            vim.keymap.set("n", "<leader>hs", function() require("gitsigns").stage_hunk() end,
                { silent = true, noremap = true, desc = "[gitsigns] stage hunk" }
            )
            vim.keymap.set("n", "<leader>hs", function() require('gitsigns').stage_hunk() end,
                { silent = true, noremap = true, desc = "[gitsigns] stage hunk" }
            )
            vim.keymap.set("n", "<leader>hu", function() require('gitsigns').undo_stage_hunk() end,
                { silent = true, noremap = true, desc = "[gitsigns] undo stage hunk" }
            )
            vim.keymap.set("n", "<leader>hr", function() require('gitsigns').reset_hunk() end,
                { silent = true, noremap = true, desc = "[gitsigns] reset hunk" }
            )
            vim.keymap.set("n", "<leader>hR", function() require('gitsigns').reset_buffer() end,
                { silent = true, noremap = true, desc = "[gitsigns] reset buffer" }
            )
            vim.keymap.set("n", "<leader>hp", function() require('gitsigns').preview_hunk() end,
                { silent = true, noremap = true, desc = "[gitsigns] preview hunk" }
            )
            vim.keymap.set("n", "<leader>hb", function() require('gitsigns').blame_line() end,
                { silent = true, noremap = true, desc = "[gitsigns] blame line" }
            )
        end,
    },

    {

        -- Autocompletion
        "hrsh7th/nvim-cmp",
        dependencies = {
            'L3MON4D3/LuaSnip',
            'saadparwaiz1/cmp_luasnip',

            -- Adds other completion capabilities.
            --  nvim-cmp does not ship with all sources by default. They are split
            --  into multiple repos for maintenance purposes.
            'hrsh7th/cmp-nvim-lsp',
            'hrsh7th/cmp-path',
        },
        config = function()
            local cmp = require("cmp")
            local luasnip = require("luasnip")

            cmp.setup({
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end,
                },
                completion = { completeopt = 'menu,menuone,noinsert' },
                preselect = cmp.PreselectMode.None,

                -- For an understanding of why these mappings were
                -- chosen, you will need to read `:help ins-completion`
                --
                -- No, but seriously. Please read `:help ins-completion`, it is really good!
                mapping = cmp.mapping.preset.insert({
                    -- Select the [n]ext item
                    ['<C-n>'] = cmp.mapping.select_next_item(),
                    -- Select the [p]revious item
                    ['<C-p>'] = cmp.mapping.select_prev_item(),

                    -- Accept ([y]es) the completion.
                    --  This will auto-import if your LSP supports it.
                    --  This will expand snippets if the LSP sent a snippet.
                    ['<C-y>'] = cmp.mapping.confirm { select = true },

                    -- Manually trigger a completion from nvim-cmp.
                    --  Generally you don't need this, because nvim-cmp will display
                    --  completions whenever it has completion options available.
                    ['<C-Space>'] = cmp.mapping.complete {},

                    -- Think of <c-l> as moving to the right of your snippet expansion.
                    --  So if you have a snippet that's like:
                    --  function $name($args)
                    --    $body
                    --  end
                    --
                    -- <c-l> will move you to the right of each of the expansion locations.
                    -- <c-h> is similar, except moving you backwards.
                    ['<C-l>'] = cmp.mapping(function()
                        if luasnip.expand_or_locally_jumpable() then
                            luasnip.expand_or_jump()
                        end
                    end, { 'i', 's' }),
                    ['<C-h>'] = cmp.mapping(function()
                        if luasnip.locally_jumpable(-1) then
                            luasnip.jump(-1)
                        end
                    end, { 'i', 's' }),
                }),
                sources = {
                    { name = "copilot" },
                    { name = 'nvim_lsp' },
                    { name = 'luasnip' },
                    { name = 'path' },
                },
            })
        end,
    },
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            -- Automatically install LSPs and related tools to stdpath for neovim
            'williamboman/mason.nvim',
            'williamboman/mason-lspconfig.nvim',
            'WhoIsSethDaniel/mason-tool-installer.nvim',

            -- Useful status updates for LSP.
            -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
            { 'j-hui/fidget.nvim', opts = {} },
        },

        config = function()
            local lsp_group = vim.api.nvim_create_augroup("LSP_GROUP", { clear = true })

            local function custom_format(opts)
                if vim.bo.filetype == "tmpl" then
                    -- TODO: write better formatter
                    local bufnr = vim.api.nvim_get_current_buffer()
                    local filename = vim.api.nvim_buf_get_name(bufnr)
                    local cmd = "templ fmt " .. vim.fn.shellescape(filename)

                    vim.fn.jobstart(cmd, {
                        on_exit = function()
                            if vim.api.nvim_get_current_buffer() == bufnr then
                                vim.cmd("e!")
                            end
                        end,
                    })
                else
                    vim.lsp.buf.format(opts)
                end
            end

            vim.api.nvim_create_autocmd("LspAttach", {
                group = lsp_group,
                callback = function(event)
                    vim.bo[event.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

                    local function buffer_keymap(mode, pattern, command)
                        local opts = { noremap = true, silent = true, buffer = event.buf }
                        vim.keymap.set(mode, pattern, command, opts)
                    end

                    buffer_keymap('n', 'gd', vim.lsp.buf.definition)
                    buffer_keymap('n', 'gD', vim.lsp.buf.declaration)
                    buffer_keymap('n', 'K', vim.lsp.buf.hover)
                    buffer_keymap('n', 'gi', vim.lsp.buf.implementation)
                    buffer_keymap('n', 'gr', vim.lsp.buf.references)
                    buffer_keymap('n', '<leader>k', vim.lsp.buf.signature_help)
                    buffer_keymap('n', '<leader>D', vim.lsp.buf.type_definition)
                    buffer_keymap('n', '<leader>rn', vim.lsp.buf.rename)
                    buffer_keymap('n', '<leader>ca', vim.lsp.buf.code_action)
                    buffer_keymap('n', '<leader>f', function() custom_format({ async = true, timeout_ms = 5000 }) end)
                    buffer_keymap("i", "<c-h>", vim.lsp.buf.signature_help)
                end,
            })


            local capabilities = vim.lsp.protocol.make_client_capabilities()

            local servers = {
                html = {
                    filetype = { "html", "templ" },
                },
                htmx = {
                    filetype = { "html", "templ" },
                },
                clangd = {
                    filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
                },
                tailwindcss = {
                    filetype = {
                        "templ", "astro", "javascript", "typescript", "react", "aspnetcorerazor",
                        "astro", "astro-markdown", "blade", "clojure", "django-html", "htmldjango", "edge",
                        "eelixir", "elixir", "ejs", "erb", "eruby", "gohtml", "gohtmltmpl", "haml", "handlebars",
                        "hbs", "html", "html-eex", "heex", "jade", "leaf", "liquid", "markdown", "mdx",
                        "mustache", "njk", "nunjucks", "razor", "slim", "twig", "css", "less", "postcss", "sass",
                        "scss", "stylus", "sugarss", "javascript", "javascriptreact", "reason", "rescript",
                        "typescript", "typescriptreact", "vue", "svelte", "jinja.html"
                    },
                    init_options = {
                        userLanguages = { templ = "html" }
                    }

                },
                lua_ls = {
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
                                globals = { "vim", "hs" }
                            }
                        }
                    }
                },
                pyright = {
                    capabilities = (function()
                        local pyrightCapabilities = vim.lsp.protocol.make_client_capabilities()
                        pyrightCapabilities.textDocument.publishDiagnostics = nil
                        return pyrightCapabilities
                    end)(),
                    handlers = {
                        ["textDocument/publishDiagnostics"] = function(...) end,
                    }
                },
                gopls = {
                    settings = {
                        gopls = {
                            experimentalPostfixCompletions = true,
                            analyses = {
                                pointerTypeCheck = true,
                                usePlaceholders = true,
                                unusedparams = true,
                                shadow = true,
                            },
                            -- codelenses = {
                            --     generate = true,
                            --     gc_details = true,
                            --     regenerate_cgo = true,
                            --     tidy = true,
                            --     upgrade_depdendency = true,
                            --     vendor = true,
                            -- },
                            staticcheck = true,
                        }
                    }

                }
            }


            require("mason").setup()

            local ensure_installed = vim.tbl_keys(servers or {})
            vim.list_extend(ensure_installed, {
                "stylua",
            })

            require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

            require("mason-lspconfig").setup({
                handlers = {
                    function(server_name)
                        local server = servers[server_name] or {}
                        server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
                        require("lspconfig")[server_name].setup(server)
                    end,
                }
            })

            require("fidget").setup({})

            vim.diagnostic.config({
                virtual_text = true,
                update_in_insert = true,
                signs = { severity_limit = "Error" },
                underline = { severity_limit = "Warning" },
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
        end
    },

    {
        "tpope/vim-fugitive",
        config = function()
            vim.keymap.set("n", "<leader>gs", function() vim.cmd("Git") end,
                { silent = true, noremap = true, desc = "[fugitive] open git status" }
            )
        end,
    },
    {
        "jose-elias-alvarez/null-ls.nvim",
        config = function()
            local with_diagnostics = function(func) return func.with({ diagnostics_format = "#{m} [#{c}]" }) end
            local lspformat = vim.api.nvim_create_augroup("LspFormat", { clear = true })
            local null_ls = require("null-ls")
            local local_home_bin = os.getenv("HOME") .. "/.local/bin"

            vim.g.enable_format_on_save = false

            vim.api.nvim_create_user_command("ToggleFormatOnSave",
                function()
                    vim.g.enable_format_on_save = not vim.g.enable_format_on_save
                    if vim.g.enable_format_on_save then
                        vim.api.nvim_echo({ { "Format on save enabled", "Normal" } }, true, {})
                    else
                        vim.api.nvim_echo({ { "Format on save disabled", "Normal" } }, true, {})
                    end
                end,
                {
                    nargs = 0,
                }
            )

            null_ls.setup({
                on_attach = function(client, bufnr)
                    if client.supports_method("textDocument/formatting") then
                        vim.api.nvim_clear_autocmds({ group = lspformat, buffer = bufnr })
                        vim.api.nvim_create_autocmd({ "BufWritePre" }, {
                            group = lspformat,
                            buffer = bufnr,
                            callback = function()
                                if vim.g.enable_format_on_save then
                                    vim.lsp.buf.formatting_sync(nil, 1000)
                                end
                            end,
                        })
                    end
                end,

                sources = {
                    null_ls.builtins.formatting.djlint.with({ command = local_home_bin .. "/djlint" }),
                    with_diagnostics(null_ls.builtins.diagnostics.curlylint.with({
                        command = local_home_bin .. "/curlylint"
                    })),
                    null_ls.builtins.formatting.black.with({ command = local_home_bin .. "/black" }),
                    null_ls.builtins.formatting.isort.with({ comamnd = local_home_bin .. "/isort" }),
                    null_ls.builtins.formatting.golines.with({ extra_args = { "-m", "120" } }),
                    null_ls.builtins.formatting.goimports,
                    -- with_diagnostics(null_ls.builtins.diagnostics.flake8),

                    with_diagnostics(null_ls.builtins.diagnostics.mypy.with({ extra_args = { '--follow-imports', 'normal' } })),
                    -- with_diagnostics(null_ls.builtins.diagnostics.mypy),
                    with_diagnostics(null_ls.builtins.diagnostics.ruff),
                    -- null_ls.builtins.formatting.lua_format.with({extra_args = {"--column-limit", "90"}}),
                    with_diagnostics(null_ls.builtins.diagnostics.luacheck.with({
                        extra_args = { "--globals", "vim" },
                    })),
                    with_diagnostics(null_ls.builtins.diagnostics.golangci_lint)
                }
            })
        end
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
    {
        "zbirenbaum/copilot.lua",
        cmd = "Copilot",
        event = "InsertEnter",
        opts = {
            suggestion = { enabled = false },
            panel = { enabled = false },
        },
    },
    {
        "zbirenbaum/copilot-cmp",
        after = { "copilot.lua" },
        opts = {},
    },
    {
        "ray-x/go.nvim",
        event = { "CmdlineEnter" },
        ft = { "go", "gomod" },
        opts = {},
        build = ":lua require('go.install').update_all_sync()",

    },

    { "mfussenegger/nvim-lint" },

}, {})

-- }}}


-- Statusline {{{

local function create_statusline_helpers()
    local M = {}
    local active_sep = "blank"

    M.separators = { blank = { "", "" } }

    M.colors = {
        active = "%#StatusLine#",
        inactive = "%#StatusLineNC#",
        mode = "%#Mode#",
        mode_alt = "%#ModeAlt#",
        git = "%#Git#",
        git_alt = "%#GitAlt#",
        filetype = "%#Filetype#",
        filetype_alt = "%#FiletypeAlt#",
        line_col = "%#LineCol#",
        line_col_alt = "%#LineColAlt#"
    }

    M.truncate_width = setmetatable({
            mode = 80,
            git_status = 90,
            filename = 140,
            line_col = 60
        },
        {
            __index = function()
                return 80
            end
        }
    )

    M.is_truncated = function(_, width)
        local current_width = vim.api.nvim_win_get_width(0)
        return current_width < width
    end

    M.modes = setmetatable({
        ["n"] = { "Normal", "N " },
        ["no"] = { "Normal·Operator Pending", "NP" },
        ["v"] = { "Visual", "V " },
        ["V"] = { "V·Line", "VL" },
        -- V Block is ^V (enter with <c-v><c-v>
        [""] = { "V·Blck", "VL" },
        ["s"] = { "Select", "S " },
        ["S"] = { "S·Line", "SL" },
        [""] = { "S·Block", "SB" },
        ["i"] = { "Insert", "I " },
        ["R"] = { "Replace", "R " },
        ["Rv"] = { "V·Replace", "VR" },
        ["c"] = { "CMD   ", "C " },
        ["cv"] = { "Vim Ex", "X " },
        ["ce"] = { "Ex", "EX" },
        ["r"] = { "Prompt", "P " },
        ["rm"] = { "More", "M " },
        ["r?"] = { "Confirm", "C " },
        ["!"] = { "Shell", "S " },
        ["t"] = { "Terminal", "T " }
    }, { __index = function() return { "Unknown", "U" } end })

    M.get_current_mode = function(self)
        ---@diagnostic disable-next-line
        local current_mode = vim.api.nvim_get_mode().mode

        if self:is_truncated(self.truncate_width.mode) then
            return string.format(" %s ", self.modes[current_mode][2])
                :upper()
        end
        return string.format(" %s ", self.modes[current_mode][1]):upper()
    end

    M.get_git_status = function(self)
        local signs = vim.b.gitsigns_status_dict or { head = "", added = 0, changed = 0, removed = 0 }
        local is_head_empty = signs.head ~= ""

        if self:is_truncated(self.truncate_width.git_status) then
            return is_head_empty and
                string.format(" %s ", signs.head or "") or ""
        end
        return is_head_empty and
            string.format(" +%s ~%s -%s | %s ", signs.added, signs.changed, signs.removed, signs.head) or ""
    end

    M.get_filename = function(self)
        if self:is_truncated(self.truncate_width.filename) then return " %<%f " end
        return " %<%F "
    end

    M.get_filetype = function()
        -- local file_name, file_ext = fn.expand("%"), fn.expand("%:e")
        -- local icon = require("nvim-web-devicons").get_icon(file_name, file_ext, { default = true })
        local filetype = vim.bo.filetype

        if filetype == "" then return "" end
        return string.format(" %s ", filetype):lower()
    end

    M.get_line_col = function(self)
        if self:is_truncated(self.truncate_width.line_col) then return " %l:%c " end
        return " Ln %3l, Col %2c "
    end

    M.set_active = function(self)
        local colors = self.colors
        local mode = colors.mode .. self:get_current_mode()
        local mode_alt = colors.mode_alt .. self.separators[active_sep][1]
        local git = colors.git .. self:get_git_status()
        local git_alt = colors.git_alt .. self.separators[active_sep][1]
        local filename = colors.inactive .. self:get_filename()
        local filetype_alt = colors.filetype_alt .. self.separators[active_sep][2]
        local filetype = colors.filetype .. self:get_filetype()
        local line_col_alt = colors.line_col_alt .. self.separators[active_sep][2]
        local line_col = colors.line_col .. self:get_line_col()

        return table.concat({ colors.active, mode, mode_alt, git, git_alt, "%=", filename, "%=", filetype_alt, filetype,
            line_col_alt, line_col })
    end

    M.set_inactive = function(self) return self.colors.inactive .. "%= %F %=" end

    return M
end

Statusline = setmetatable(create_statusline_helpers(), {
    __call = function(statusline, mode)
        if mode == "active" then return statusline:set_active() end
        if mode == "inactive" then return statusline:set_inactive() end
    end
})

local group = vim.api.nvim_create_augroup("StatusLine", { clear = true })

vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" },
    { command = "setlocal statusline=%!v:lua.Statusline('active')", group = group }
)
vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave" },
    { command = "setlocal statusline=%!v:lua.Statusline('inactive')", group = group }
)


-- }}}

-- Colorscheme {{{

vim.cmd [[
   hi WinSeperator guibg=none
   hi def link LspReferenceText CursorLine
   hi def link LspReferenceWrite CursorLine
   hi def link LspReferenceRead CursorLine

   hi Normal guibg=none ctermbg=none
   hi EndOfBuffer guibg=none ctermbg=none

   hi SignAdd guifg=#98971a ctermfg=10
   hi SignDelete guifg=#cc241d ctermfg=9
   hi SignChange guifg=#458588 ctermfg=12
]]

local hi_group = vim.api.nvim_create_augroup("YankHi", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost",
    { callback = function() vim.highlight.on_yank() end, group = hi_group, pattern = "*" }
)

local indentation = vim.api.nvim_create_augroup("Indentation", { clear = true })
vim.api.nvim_create_autocmd({ "BufRead", "BufEnter", "BufNewFile" },
    { group = indentation, pattern = "*.c,*.h,*.cpp", command = "setlocal expandtab tabstop=2 shiftwidth=2" }
)

vim.api.nvim_create_autocmd({ "BufRead", "BufEnter", "BufNewFile" },
    { group = indentation, pattern = "*.proto", command = "setlocal expandtab tabstop=2 shiftwidth=2" }
)

local customFiletypes = vim.api.nvim_create_augroup("CustomFiletypes", { clear = true })
vim.api.nvim_create_autocmd({ "BufRead", "BufEnter", "BufNewFile" },
    {
        group = customFiletypes,
        pattern = "*.rego",
        command =
        "setlocal filetype=rego noexpandtab shiftwidth=4 tabstop=4"
    }
)

-- }}}
