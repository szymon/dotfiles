require("mason").setup()
require("mason-lspconfig").setup()

if pcall('require', 'lsp_signature') then
    require("lsp_signature").setup()
end

local lsp = require("lsp-zero").preset("recommended")

lsp.ensure_installed({ "pyright", "rust_analyzer", "gopls", "lua_ls" })

lsp.configure("lua_ls", { settings = { Lua = { diagnostics = { globals = { "vim" } } } } })

local cmp = require("cmp")
local cmp_types = require("cmp.types")
local cmp_options_insert = { behavior = cmp_types.cmp.SelectBehavior.Insert }
local cmp_options_select = { behavior = cmp_types.cmp.SelectBehavior.Select }
local cmp_modes = { "i", "c", "s" }

local cmp_mappings = lsp.defaults.cmp_mappings({
    ["<c-p>"] = cmp.mapping(cmp.mapping.select_prev_item(cmp_options_insert), cmp_modes),
    ["<c-n>"] = cmp.mapping(cmp.mapping.select_next_item(cmp_options_insert), cmp_modes),
    ["<c-y>"] = cmp.mapping.confirm({ select = true }),
    ["<c-space>"] = cmp.mapping(cmp.mapping.complete(), cmp_modes),
    ["<c-b>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), cmp_modes),
    ["<c-f>"] = cmp.mapping(cmp.mapping.scroll_docs(4), cmp_modes)
})

cmp_mappings["<Tab>"] = nil
cmp_mappings["<S-Tab>"] = nil
cmp_mappings["<CR>"] = nil

lsp.setup_nvim_cmp({ mapping = cmp_mappings, select_behavior = cmp_types.cmp.SelectBehavior.Insert })

local on_attach = function(client, bufnr)
    local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end

    if client.server_capabilities.documentSymbolProvider then
        if pcall(require, "nvim-navic") then
            require("nvim-navic").attach(client, bufnr) --
        end
    end

    -- Mappings.
    local opts = { noremap = true, silent = true }

    buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    buf_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
    buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
    buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
    buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)

    buf_set_keymap('n', '<leader>k', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)

    -- buf_set_keymap('n', '<leader>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
    -- buf_set_keymap('n', '<leader>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
    -- buf_set_keymap('n', '<leader>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
    buf_set_keymap('n', '<leader>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
    buf_set_keymap('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
    buf_set_keymap('n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
    buf_set_keymap('n', '<leader>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
    -- buf_set_keymap('n', '<leader>q', '<cmd>lua vim.lsp.diagnostic.set_quickfixlist()<CR>', opts)
    buf_set_keymap('n', '<leader>f', '<cmd>lua vim.lsp.buf.format({ async = false, timeout_ms = 5000 })<CR>', opts)
end

lsp.configure("pyright", {
    on_init = function(client)
        if client.name == "pyright" then
            client.server_capabilities.documentFormattingProvider = false
            client.server_capabilities.documentFormattingRangeProvider = false
        end
    end
})

lsp.configure("gopls", {
    settings = {
        gopls = {
            -- keep formatting
            experimentalPostfixCompletions = true,
            analyses = { unusedparams = true, shadow = true },
            staticcheck = true
        }
    }
})

lsp.configure("tailwindcss", {
    filetypes = {
        "aspnetcorerazor",
        "astro",
        "astro-markdown",
        "blade",
        "clojure",
        "django-html",
        "htmldjango",
        "edge",
        "eelixir",
        "elixir",
        "ejs",
        "erb",
        "eruby",
        "gohtml",
        "gohtmltmpl",
        "haml",
        "handlebars",
        "hbs",
        "html",
        "html-eex",
        "heex",
        "jade",
        "leaf",
        "liquid",
        "markdown",
        "mdx",
        "mustache",
        "njk",
        "nunjucks",
        "razor",
        "slim",
        "twig",
        "css",
        "less",
        "postcss",
        "sass",
        "scss",
        "stylus",
        "sugarss",
        "javascript",
        "javascriptreact",
        "reason",
        "rescript",
        "typescript",
        "typescriptreact",
        "vue",
        "svelte",
        "jinja.html"
    }
})


lsp.on_attach(on_attach)
lsp.setup()

local nls_with_diagnostics = function(func) return func.with { diagnostics_format = "#{m} [#{c}]" } end

local lspformat = vim.api.nvim_create_augroup("LspFormat", { clear = true })
local null_ls = require("null-ls")

local enable_format_on_save = false

vim.api.nvim_create_user_command("ToggleFormatOnSave",
    function()
        enable_format_on_save = not enable_format_on_save
        if enable_format_on_save then
            print("Format on save enabled")
        else
            print("Format on save disabled")
        end
    end,
    {
        nargs = 0,
    }
)

local local_home_bin = vim.fn.expand("~/.local/bin")

null_ls.setup {
    -- debug = true,
    on_attach = function(client, bufnr)
        if client.supports_method("textDocument/formatting") then
            vim.api.nvim_clear_autocmds({ group = lspformat, buffer = bufnr })
            vim.api.nvim_create_autocmd("BufWritePre", {
                group = lspformat,
                buffer = bufnr,
                callback = function()
                    if enable_format_on_save then
                        vim.lsp.buf.format({ async = false, timeout_ms = 5000 })
                    end
                end
            })
        end
    end,
    sources = {
        null_ls.builtins.formatting.djlint.with({ command = local_home_bin .. "/djlint" }),
        nls_with_diagnostics(null_ls.builtins.diagnostics.curlylint.with({ command = local_home_bin .. "/curlylint" })),
        null_ls.builtins.formatting.black.with({ command = local_home_bin .. "/black" }),
        null_ls.builtins.formatting.isort.with({ comamnd = local_home_bin .. "/isort" }),
        null_ls.builtins.formatting.golines.with({ extra_args = { "-m", "120" } }),
        null_ls.builtins.formatting.goimports,
        nls_with_diagnostics(null_ls.builtins.diagnostics.flake8),

        -- nls_with_diagnostics(null_ls.builtins.diagnostics.mypy.with({extra_args={'--follow-imports', 'normal'}})),
        nls_with_diagnostics(null_ls.builtins.diagnostics.mypy.with({ command = local_home_bin .. "/mypy" })),
        -- null_ls.builtins.formatting.lua_format.with({extra_args = {"--column-limit", "90"}}),
        nls_with_diagnostics(null_ls.builtins.diagnostics.luacheck),
        nls_with_diagnostics(null_ls.builtins.diagnostics.golangci_lint)
    }

}

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

local function custom_on_publish_diagnostics(a, params, client_id, c, config)
    filter(params.diagnostics, filter_diagnostics)
    vim.lsp.diagnostic.on_publish_diagnostics(a, params, client_id, c, config)
end

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(custom_on_publish_diagnostics, {})

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
