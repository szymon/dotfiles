local M = {}

function M.setup()
    require("mason").setup()

    vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(ev)
            local client = vim.lsp.get_client_by_id(ev.data.client_id)

            if client ~= nil and client:supports_method("textDocument/completion") then
                vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
            end

            local function k(mod, pattern, command, opts)
                local ops = opts or {}
                ops.noremap = true
                ops.silent = true
                ops.buffer = ev.buf
                vim.keymap.set(mod, pattern, command, ops)
            end

            k("n", "gd", vim.lsp.buf.definition)
            k("n", "gD", vim.lsp.buf.declaration)
            k("n", "K", vim.lsp.buf.hover)
            k("n", "gi", vim.lsp.buf.implementation)
            k("n", "gr", vim.lsp.buf.references)
            k("n", "<leader>k", vim.lsp.buf.signature_help)
            k("i", "<c-k>", vim.lsp.buf.signature_help)
            k("n", "<leader>D", vim.lsp.buf.type_definition)
            k("n", "<leader>rn", vim.lsp.buf.rename)
            k("n", "<leader>ca", vim.lsp.buf.code_action)
        end,
    })

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
        -- volar = {},
    }

    local caps = vim.lsp.protocol.make_client_capabilities()
    caps.textDocument.completion.completionItem.snippetSupport = true


    require("mason-tool-installer").setup({
        ensure_installed = vim.tbl_keys(servers or {}),
    })

    for server, config in pairs(servers) do
        if not vim.tbl_isempty(config) then
            config.capabilities = vim.tbl_deep_extend("force", {}, caps, config.capabilities or {})
            vim.lsp.config(server, config)
        end
    end

    vim.lsp.enable(vim.tbl_keys(servers))

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

        print(vim.inspect(result))

        if vim.islist(result) then
            vim.lsp.util.show_documentation(result[1], "utf-8", { focus = true })
        else
            vim.lsp.util.show_documentation(result, "utf-8", { focus = true })
        end
    end
end

return M
