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

vim.keymap.set("n", ";", "dd", { desc = "[general] remove line" })

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

local function dupLine(opts)
    if opts == nil then
        opts = {
            count = 1
        }
    end
    local bufnr = vim.api.nvim_get_current_buf()
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    local line = vim.api.nvim_buf_get_lines(bufnr, row - 1, row, false)
    vim.api.nvim_buf_set_lines(bufnr, row, row, false, line)
    vim.api.nvim_win_set_cursor(0, { row + opts.count, col })
end

vim.keymap.set("n", "gb", dupLine, { desc = "[general] duplicate current line and move down" })


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

            vim.keymap.set("n", "<leader>hs", require("gitsigns").stage_hunk,
                { silent = true, noremap = true, desc = "[gitsigns] stage hunk" })
            vim.keymap.set("n", "<leader>hs", require('gitsigns').stage_hunk,
                { silent = true, noremap = true, desc = "[gitsigns] stage hunk" })
            vim.keymap.set("n", "<leader>hu", require('gitsigns').undo_stage_hunk,
                { silent = true, noremap = true, desc = "[gitsigns] undo stage hunk" })
            vim.keymap.set("n", "<leader>hr", require('gitsigns').reset_hunk,
                { silent = true, noremap = true, desc = "[gitsigns] reset hunk" })
            vim.keymap.set("n", "<leader>hR", require('gitsigns').reset_buffer,
                { silent = true, noremap = true, desc = "[gitsigns] reset buffer" })
            vim.keymap.set("n", "<leader>hp", require('gitsigns').preview_hunk,
                { silent = true, noremap = true, desc = "[gitsigns] preview hunk" })
            vim.keymap.set("n", "<leader>hb", require('gitsigns').blame_line,
                { silent = true, noremap = true, desc = "[gitsigns] blame line" })
            vim.keymap.set("n", "]h", require("gitsigns").next_hunk,
                { silent = true, noremap = true, desc = "[gitsigns] next hunk" })
            vim.keymap.set("n", "[h", require("gitsigns").prev_hunk,
                { silent = true, noremap = true, desc = "[gitsigns] next hunk" })
        end,
    },

    {
        -- Autocompletion
        "hrsh7th/nvim-cmp",
        dependencies = {
            'saadparwaiz1/cmp_luasnip',

            -- Adds other completion capabilities.
            --  nvim-cmp does not ship with all sources by default. They are split
            --  into multiple repos for maintenance purposes.
            'hrsh7th/cmp-nvim-lsp',
            'hrsh7th/cmp-path',
            { 'L3MON4D3/LuaSnip', build = "make install_jsregexp", },
        },
        config = function()
            local cmp = require("cmp")
            local luasnip = require("luasnip")

            luasnip.setup({
                history = false,
                updateevents = "TextChanged,TextChangedI",
            })

            for _, file in ipairs(vim.api.nvim_get_runtime_file("snips/ft/*.lua", true)) do
                loadfile(file)()
            end

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
                    ['<C-y>'] = cmp.mapping.confirm({ select = true }),

                    -- Manually trigger a completion from nvim-cmp.
                    --  Generally you don't need this, because nvim-cmp will display
                    --  completions whenever it has completion options available.
                    ['<C-Space>'] = cmp.mapping.complete(),

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

                    ['<c-e>'] = cmp.mapping(function()
                        if luasnip.choice_active() then
                            luasnip.change_choice(1)
                        end
                    end, { "i", "s" }),
                }),
                sources = {
                    { name = "copilot" },
                    { name = 'nvim_lsp' },
                    -- { name = 'luasnip' },
                    { name = 'path' },
                    { name = "buffer" },
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

            vim.api.nvim_create_autocmd("LspAttach", {
                group = lsp_group,
                callback = function(event)
                    vim.bo[event.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

                    local function buffer_keymap(mode, pattern, command, opts)
                        local ops = otps or {}
                        ops.noremap = true
                        ops.silent = true
                        ops.buffer = event.buf
                        vim.keymap.set(mode, pattern, command, opts)
                    end

                    buffer_keymap('n', 'gd', vim.lsp.buf.definition, { desc = "[lsp] goto definition" })
                    buffer_keymap('n', 'gD', vim.lsp.buf.declaration, { desc = "[lsp] goto declaration" })
                    buffer_keymap('n', 'K', vim.lsp.buf.hover, { desc = "[lsp] hover" })
                    buffer_keymap('n', 'gi', vim.lsp.buf.implementation, { desc = "[lsp] goto implementation" })
                    buffer_keymap('n', 'gr', vim.lsp.buf.references, { desc = "[lsp] find references" })
                    buffer_keymap('n', '<leader>k', vim.lsp.buf.signature_help, { desc = "[lsp] signature help" })
                    buffer_keymap('i', '<c-k>', vim.lsp.buf.signature_help, { desc = "[lsp] signature help" })
                    buffer_keymap('n', '<leader>D', vim.lsp.buf.type_definition, { desc = "[lsp] type definition" })
                    buffer_keymap('n', '<leader>rn', vim.lsp.buf.rename, { desc = "[lsp] rename" })
                    buffer_keymap('n', '<leader>ca', vim.lsp.buf.code_action, { desc = "[lsp] code actions" })
                end,
            })


            require("mason").setup()

            local capabilities = vim.lsp.protocol.make_client_capabilities()
            capabilities.textDocument.completion.completionItem.snippetSupport = true
            local mason_registry = require('mason-registry')
            local vue_language_server_path = mason_registry.get_package('vue-language-server'):get_install_path() ..
                '/node_modules/@vue/language-server'

            local servers = {
                zls = {},
                buf = {
                    filetypes = { "proto" },
                },
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
                            usePlaceholders = true,
                            experimentalPostfixCompletions = true,
                            analyses = {
                                pointerTypeCheck = true,
                                usePlaceholders = true,
                                unusedparams = true,
                                shadow = true,
                            },
                            gofumpt = true,
                            codelenses = {
                                generate = true,
                                gc_details = true,
                                regenerate_cgo = true,
                                tidy = true,
                                upgrade_depdendency = true,
                                vendor = true,
                            },
                            staticcheck = true,
                        }
                    }

                },
                -- tsserver = {
                --     filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue' },
                --     init_options = {
                --         plugins = {
                --             {
                --                 name = "@vue/typescript-plugin",
                --                 location = vue_language_server_path,
                --                 languages = { 'vue' },
                --             },
                --         },
                --     },
                -- },
                volar = {},
            }

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
        "stevearc/conform.nvim",
        config = function()
            require("conform").setup({
                default_format_opts = {
                    lsp_format = "last",
                },
            })
        end,
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
        "ray-x/go.nvim",
        event = { "CmdlineEnter" },
        ft = { "go", "gomod" },
        opts = {},
        build = ":lua require('go.install').update_all_sync()",

    },

    {
        "mfussenegger/nvim-lint",
        config = function()
            require("lint").linters_by_ft = {
                go = { "golangcilint" },
            }
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
        config = function()
            require('treesitter-context').setup({
                max_lines = 2,
                trim_scope = "inner",
            })
        end,
    },

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

-- local function custom_format(opts)
--     if vim.bo.filetype == "tmpl" then
--         -- TODO: write better formatter
--         local bufnr = vim.api.nvim_get_current_buffer()
--         local filename = vim.api.nvim_buf_get_name(bufnr)
--         local cmd = "templ fmt " .. vim.fn.shellescape(filename)
--
--         vim.fn.jobstart(cmd, {
--             on_exit = function()
--                 if vim.api.nvim_get_current_buffer() == bufnr then
--                     vim.cmd("e!")
--                 end
--             end,
--         })
--     else
--         vim.lsp.buf.format(opts)
--     end
-- end

vim.keymap.set(
    "n",
    "<leader>f",
    function()
        local buffer = vim.api.nvim_get_current_buf()
        require("conform").format({ bufnr = buffer, async = true })
    end,
    {
        remap = true,
        desc = "[general] try to format with conform or lsp",
    }
)


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
        command = "setlocal filetype=rego expandtab shiftwidth=4 tabstop=4"
    }
)

vim.api.nvim_create_autocmd({ "FileType" }, {
    group = customFiletypes,
    pattern = "help",
    command = "wincmd L",
})

local postwrite = vim.api.nvim_create_augroup("PostWrite", { clear = true })
vim.api.nvim_create_autocmd({ "BufWritePost", "WinEnter" }, {
    group = postwrite,
    callback = function()
        require("lint").try_lint()
    end,
})

-- }}}
