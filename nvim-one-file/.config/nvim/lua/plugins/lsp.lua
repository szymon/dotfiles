return {
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
                    { name = 'luasnip' },
                    { name = "supermaven" },
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
                        local ops = opts or {}
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
                opa = {},
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
            vim.list_extend(ensure_installed, { "stylua", })

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
}
