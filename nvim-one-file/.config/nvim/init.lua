vim.cmd [[ source ~/.vimrc ]]


-- Helper Functions {{{
local function bind(op, outer_opts)
    return function(lhs, rhs, opts)
        outer_opts = outer_opts or {}
        opts = vim.tbl_extend("force", outer_opts, opts or {})
        vim.keymap.set(op, lhs, rhs, opts)
    end
end

local function filter(arr, func)
    -- Filter in place
    -- https://stackoverflow.com/questions/49709998/how-to-filter-a-lua-array-inplace
    local new_index = 1
    local size_orig = #arr
    for old_index, v in ipairs(arr) do
        if func(v, old_index) then
            arr[new_index] = v
            new_index = new_index + 1
        end
    end
    for i = new_index, size_orig do arr[i] = nil end
end

local function filter_diagnostics(diagnostic)
    -- Only filter out Pyright stuff for now
    if diagnostic.source == "Pyright" then return false end

    return true
end

local nnoremap = bind("n")
local vnoremap = bind("v")
local xnoremap = bind("x")

-- }}}

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


vim.g.mouse = "a"
vim.g.gruvbox_flat_style = "hard"
vim.g.Illuminate_delay = 300
vim.g.undotree_DiffAutoOpen = false

-- Keymaps {{{
vnoremap("J", ":m '>+1<cr>gv=gv")
vnoremap("L", ":m '<-2<cr>gv=gv")

nnoremap("Y", "yg$")

xnoremap("<leader>p", '"_dP')

-- disable ex mode
nnoremap("Q", "<nop>")

-- keep cursor inplace when joining lines
nnoremap("J", "mzJ`z")

-- keep cursor in the center when jumping half page
nnoremap("<c-d>", "<c-d>zz")
nnoremap("<c-u>", "<c-u>zz")

-- keep cursor in the center when searching with n/N
nnoremap("n", "nzzzv")
nnoremap("N", "Nzzzv")

nnoremap("<leader>x", "<cmd>!chmod +x %<cr>")

-- nnoremap("<leader>u", vim.cmd.UndotreeToggle)

nnoremap("<leader>gs", "<cmd>Git<cr>")


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

vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    {
        "sainnhe/gruvbox-material",
        lazy = false,
        priority = 1000,
        config = function()
            vim.cmd [[
           colorscheme gruvbox-material
        ]]
        end
    },

    {
        "nvim-telescope/telescope.nvim",
        dependencies = { { "nvim-lua/plenary.nvim" },

            { "tribela/vim-transparent" },
        },
        lazy = false,
        keys = {
            { "<c-p>",      function() require('telescope.builtin').find_files() end },
            { "<leader>rr", function() require('telescope.builtin').live_grep() end },
            { "<leader>gr",
                function()
                    local ok, input = pcall(vim.fn.input, "Grep > ")
                    if not ok then return end

                    require('telescope.builtin').grep_string({
                        search = input,
                    })
                end
            },
            { "<leader>;",
                function()
                    require('telescope.builtin').buffers({
                        sort_lastuse = true,
                        ignore_current_buffer = true
                    })
                end },
            { "<leader>sk",  function() require('telescope.builtin').keymaps() end },
            { "<leader>=",   function() require('telescope.builtin').spell_suggest() end },
            { "<leader>sgc", function() require('telescope.builtin').git_commits() end },
            { "<leader>sgb", function() require('telescope.builtin').git_bcommits() end },
            { "<leader>sgs", function() require('telescope.builtin').git_status() end },

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
        end
    },

    -- { "nvim-lualine/lualine.nvim" },
    {
        "nvim-treesitter/nvim-treesitter",
        dependencies = { "nvim-treesitter/playground", "nvim-treesitter/nvim-treesitter" },
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter.configs").setup({

                ensure_installed = {
                    "go", "html", "javascript", "json", "markdown", "python", "query",
                    "rust", "toml", "yaml", "nix", "lua", "css", "bash", "dockerfile",
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
        keys = {
            { "<leader>hs", function() require('gitsigns').stage_hunk() end },
            { "<leader>hu", function() require('gitsigns').undo_stage_hunk() end },
            { "<leader>hr", function() require('gitsigns').reset_hunk() end },
            { "<leader>hR", function() require('gitsigns').reset_buffer() end },
            { "<leader>hp", function() require('gitsigns').preview_hunk() end },
            { "<leader>hb", function() require('gitsigns').blame_line() end },
        },
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
        end,
    },

    {
        "VonHeikemen/lsp-zero.nvim",
        dependencies = {
            { "neovim/nvim-lspconfig" },
            { "williamboman/mason.nvim" },
            { "williamboman/mason-lspconfig.nvim" },

            -- Autocompletion
            { 'hrsh7th/nvim-cmp' },
            { 'hrsh7th/cmp-buffer' },
            { 'hrsh7th/cmp-path' },
            { 'saadparwaiz1/cmp_luasnip' },
            { 'hrsh7th/cmp-nvim-lsp' },
            { 'hrsh7th/cmp-nvim-lua' },

            -- Snippets
            { 'L3MON4D3/LuaSnip' },
            { "SmiteshP/nvim-navic" },
        },

        config = function()
            local lsp = require("lsp-zero").preset("recommended")
            local cmp = require("cmp")
            local cmp_types = require("cmp.types")
            local cmp_options_insert = { behavior = cmp_types.cmp.SelectBehavior.Insert }
            local cmp_modes = { "i", "c", "s" }

            local cmp_mappings = lsp.defaults.cmp_mappings({
                ["<c-p>"] = cmp.mapping(cmp.mapping.select_prev_item(cmp_options_insert), cmp_modes),
                ["<c-n>"] = cmp.mapping(cmp.mapping.select_next_item(cmp_options_insert), cmp_modes),
                ["<c-y>"] = cmp.mapping.confirm({ select = true }),
                ["<c-space>"] = cmp.mapping(cmp.mapping.complete(), cmp_modes),
                ["<c-b>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), cmp_modes),
                ["<c-f>"] = cmp.mapping(cmp.mapping.scroll_docs(4), cmp_modes),
            })

            cmp_mappings["<Tab>"] = nil
            cmp_mappings["<S-Tab>"] = nil
            cmp_mappings["<CR>"] = nil

            local function on_attach(client, bufnr)
                local function k(mode, pattern, command)
                    local opts = { noremap = true, silent = true }
                    vim.api.nvim_buf_set_keymap(bufnr, mode, pattern, command, opts)
                end
                if client.server_capabilities.documentSymbolProvider then
                    require("nvim-navic").attach(client, bufnr)
                end

                k('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>')
                k('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>')
                k('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>')
                k('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>')
                k('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>')
                -- k('n', '<c-space>', '<cmd>lua vim.lsp.buf.complete()<cr>')
                k('n', '<leader>k', '<cmd>lua vim.lsp.buf.signature_help()<CR>')
                k('n', '<leader>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>')
                k('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>')
                k('n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>')
                k('n', '<leader>e', '<cmd>lua vim.diagnostic.open_float()<CR>')
                k('n', '<leader>f', '<cmd>lua vim.lsp.buf.format({ async = false, timeout_ms = 5000 })<CR>')
            end

            lsp.configure("lua_ls", {
                settings = {
                    Lua = {
                        diagnostics = {
                            globals = { "vim" }
                        }
                    }
                }
            })

            lsp.configure("pyright", {
                on_init = function(client)
                    print("init pyright")
                    -- if client.name == "pyright" then
                    --     client.server_capabilities.documentFormattingProvider = false
                    --     client.server_capabilities.documentFormattingRangeProvider = false
                    -- end
                end,
            })

            lsp.configure("gopls", {
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
            })

            lsp.configure("tailwindcss", {
                filetypes = {
                    "aspnetcorerazor", "astro", "astro-markdown", "blade", "clojure", "django-html", "htmldjango",
                    "edge", "eelixir", "elixir", "ejs", "erb", "eruby", "gohtml", "gohtmltmpl", "haml", "handlebars",
                    "hbs", "html", "html-eex", "heex", "jade", "leaf", "liquid", "markdown", "mdx", "mustache", "njk",
                    "nunjucks", "razor", "slim", "twig", "css", "less", "postcss", "sass", "scss", "stylus", "sugarss",
                    "javascript", "javascriptreact", "reason", "rescript", "typescript", "typescriptreact", "vue",
                    "svelte", "jinja.html"
                },
            })

            lsp.on_attach(on_attach)

            require("mason").setup()
            require("mason-lspconfig").setup({
                ensure_installed = {
                    "pyright", "gopls", "lua_ls", "tailwindcss"
                },
            })

            cmp.setup({
                mapping = cmp_mappings,
            })

            lsp.setup()

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

            vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(function(a, params, client_id, c, config)
                filter(params.diagnostics, filter_diagnostics)
                vim.lsp.diagnostic.on_publish_diagnostics(a, params, client_id, c, config)
            end, {})

            vim.lsp.handlers["textDocument/publishDiagnostics"] =
                vim.lsp.with(vim.lsp.handlers["textDocument/publishDiagnostics"], {
                    signs = {
                        severity_limit = "Error",
                    },
                    underline = {
                        severity_limit = "Warning",
                    },
                    virtual_text = true,
                })
        end
    },

    { "tpope/vim-fugitive" },
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
                    with_diagnostics(null_ls.builtins.diagnostics.flake8),

                    -- nls_with_diagnostics(null_ls.builtins.diagnostics.mypy.with({extra_args={'--follow-imports', 'normal'}})),
                    with_diagnostics(null_ls.builtins.diagnostics.mypy),
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
    {
        "google/vim-jsonnet",
        event = {
            "BufEnter",
        },
        filetype = {
            "jsonnet"
        },
    },
    -- {'folke/trouble.nvim', config = function() end},
    { "github/copilot.vim" },
    {
        "ray-x/go.nvim",
        event = { "CmdlineEnter" },
        ft = { "go", "gomod" },
        config = function()
            require("go").setup()
        end,
        build = ":lua require('go.install').update_all_sync()",

    },
    -- { "yorik1984/zola.nvim",          dependencies = { "Glench/Vim-Jinja2-Syntax" } },
    {
        "ThePrimeagen/git-worktree.nvim",
        dependencies = {
            "nvim-telescope/telescope.nvim",
        },
        keys = {
            { "<leader>wl", function() require('telescope').extensions.git_worktree.git_worktrees() end },
            { "<leader>wc", function() require('telescope').extensions.git_worktree.create_git_worktree() end },
        },
        config = function()
            pcall(require("telescope").load_extension, "git-worktree")
            require("gitsigns").setup()
        end,
    },

    { "mfussenegger/nvim-lint" },

    -- {
    --     "utilyre/barbecue.nvim",
    --     name = "barbecue",
    --     version = "*",
    --     dependencies = {
    --         "SmiteshP/nvim-navic",
    --     },
    --     config = function()
    --         require("barbecue").setup({
    --             create_autocmd = false,
    --             kinds = false,
    --             symbols = { modified = "M", ellipsis = "...", separator = ">" }
    --         })


    --         vim.api.nvim_create_autocmd({
    --             "WinScrolled", "BufWinEnter", "CursorMoved", "InsertLeave", "BufWritePost", "TextChanged", "TextChangedI"
    --             -- add more events here
    --         }, {
    --             group = vim.api.nvim_create_augroup("barbecue.updater", { clear = true }),
    --             callback = function()
    --                 require("barbecue.ui").update()

    --                 -- maybe a bit more logic here
    --             end
    --         })
    --     end
    -- }


    -- LOCAL PLUGINS
    {
        "szymon/pytest.nvim",
        ft = "python",
        dev = true,
        config = function()
            vim.keymap.set("n", "<leader>tp", "<cmd>Pytest<cr>", { noremap = true })
        end
    }

}, {
    dev = {
        path = "~/code/neovim_plugins/",
    },
    ui = {
        icons = {
            cmd = "<cmd> ",
            config = "<config> ",
            event = "<event> ",
            ft = "<ft> ",
            init = "<init> ",
            import = "<import> ",
            keys = "<keys> ",
            lazy = "<lazy> ",
            loaded = "<loaded> ",
            not_loaded = "<not loaded> ",
            plugin = "<plugin> ",
            runtime = "<runtime> ",
            source = "<source> ",
            start = "<start> ",
            task = "<task> ",
            list = {
                "-",
                "*",
                "+",
                "!",
            },
        },

    }
})

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

vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(ev)
        local opts = { buffer = ev.bufnr }
        vim.keymap.set("n", "<leader>v", "<cmd>vsplit | lua vim.lsp.buf.definition()<cr>", opts)
    end,
})

vim.api.nvim_create_user_command("LspCapabilities", function()
    local curBuf = vim.api.nvim_get_current_buf()
    local clients = vim.lsp.get_active_clients { bufnr = curBuf }

    for _, client in pairs(clients) do
        if client.name ~= "null-ls" then
            local capAsList = {}
            for key, value in pairs(client.server_capabilities) do
                if value and key:find("Provider") then
                    local capability = key:gsub("Provider$", "")
                    table.insert(capAsList, "- " .. capability)
                end
            end
            table.sort(capAsList) -- sorts alphabetically
            local msg = "# " .. client.name .. "\n" .. table.concat(capAsList, "\n")
            vim.notify(msg, "trace", {
                on_open = function(win)
                    local buf = vim.api.nvim_win_get_buf(win)
                    vim.api.nvim_buf_set_option(buf, "filetype", "markdown")
                end,
                timeout = 14000,
            })
            vim.fn.setreg("+", "Capabilities = " .. vim.inspect(client.server_capabilities))
        end
    end
end, {})


-- }}}
