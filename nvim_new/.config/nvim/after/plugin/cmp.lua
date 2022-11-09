if not pcall(require, "cmp") then return end

local util = require "lspconfig/util"
local nvim_lsp = require("lspconfig")
local source_mapping = {
    buffer = "[BUF]",
    lusnip = "[SNIP]",
    nvim_lsp = "[LSP]",
    nvim_lua = "[lua]",
    path = "[path]"
}

local cmp = require("cmp")
local cmp_types = require("cmp.types")
local cmp_options_insert = {behavior = cmp_types.cmp.SelectBehavior.Insert}
local cmp_options_select = {behavior = cmp_types.cmp.SelectBehavior.Select}
local cmp_modes = {"i", "c", "s"}

cmp.setup {
    snippet = function(args)
        if not pcall(require, "luasnip") then return end
        require("luasnip").lsp_expand(args.body)
    end,

    preselect = cmp.PreselectMode.None,
    mapping = {
        ["<c-b>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), cmp_modes),
        ["<c-f>"] = cmp.mapping(cmp.mapping.scroll_docs(4), cmp_modes),
        ["<c-space>"] = cmp.mapping(cmp.mapping.complete(), cmp_modes),
        ["<c-y>"] = cmp.mapping.confirm({select = true}),
        ["<c-e>"] = {i = cmp.mapping.abort(), c = cmp.mapping.close()},
        ["<c-n>"] = cmp.mapping(
            cmp.mapping.select_next_item(cmp_options_insert), cmp_modes),
        ["<c-p>"] = cmp.mapping(
            cmp.mapping.select_prev_item(cmp_options_insert), cmp_modes),
        ["<tab>"] = cmp.mapping(
            cmp.mapping.select_next_item(cmp_options_insert), cmp_modes),
        ["<s-tab>"] = cmp.mapping(cmp.mapping.select_prev_item(
                                      cmp_options_insert), cmp_modes)
    },
    formatting = {
        format = function(entry, vim_item)
            local menu = source_mapping[entry.source.name]
            vim_item.menu = menu
            return vim_item
        end
    },
    sources = {{name = "nvim_lsp"}, {name = "luasnip"}, {name = "buffer"}}
}

cmp.setup.filetype("gitcommit", {
    sources = cmp.config.sources({{name = "cmp_git"}}, {{name = "buffer"}})
})
cmp.setup.filetype({"/", "?"}, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {{name = "buffer"}}
})

local cmdline_mapping = cmp.mapping.preset.cmdline()
cmdline_mapping["<c-n>"] = nil
cmdline_mapping["<c-p>"] = nil

cmp.setup.filetype(":", {
    mapping = cmdline_mapping,
    sources = cmp.config.sources({{name = "path"}, {name = "history"}},
                                 {{name = "buffer"}})
})
local capabilities = require("cmp_nvim_lsp").default_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

local function select_client(method)
    local clients = vim.tbl_values(vim.lsp.buf_get_clients())
    clients = vim.tbl_filter(function(client)
        return client.supports_method(method)
    end, clients)

    for i = 1, #clients do
        if clients[i].name == "efm" or clients[i].name == "null-ls" then
            return clients[i]
        end
    end

    return clients[1]
end

function Formatting(options, timeout_ms)
    ---@diagnostic disable-next-line: redefined-local
    local util = vim.lsp.util
    local params = util.make_formatting_params(options)
    local bufnr = vim.api.nvim_get_current_buf()
    local client = select_client("textDocument/formatting")
    if client == nil then return end

    local result, err = client.request_sync("textDocument/formatting", params, timeout_ms, bufnr)
    if result and result.result then
        util.apply_text_edits(result.result, bufnr, client.offset_encoding)
    elseif err then
        vim.notify("vim.lsp.buf.formatting_sync" .. err, vim.log.levels.WARN)
    end

end

---@diagnostic disable-next-line: unused-local
local on_attach = function(_client, bufnr)
    local function buf_set_keymap(...)
        vim.api.nvim_buf_set_keymap(bufnr, ...)
    end

    -- local function buf_set_option(...)
    --     vim.api.nvim_buf_set_option(bufnr, ...)
    -- end

    -- Enable completion triggered by <c-x><c-o>
    -- buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

    -- Mappings.
    local opts = {noremap = true, silent = true}

    -- See `:help vim.lsp.*` for documentation on any of the below functions
    buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
    buf_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
    buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
    buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
    buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)

    buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)

    buf_set_keymap('n', '<leader>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
    buf_set_keymap('n', '<leader>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
    buf_set_keymap('n', '<leader>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
    buf_set_keymap('n', '<leader>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
    buf_set_keymap('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
    buf_set_keymap('n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
    buf_set_keymap('n', '<leader>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
    -- buf_set_keymap('n', '<leader>q', '<cmd>lua vim.lsp.diagnostic.set_quickfixlist()<CR>', opts)
    buf_set_keymap('n', '<leader>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)

    -- require'illuminate'.on_attach(client)

end
---[[
nvim_lsp.pyright.setup {
    on_attach = on_attach,
    capabilities = capabilities,
    flags = {debounce_text_changes = 150},
    settings = {
        python = {
            analysis = {
                autoSearchPaths = true,
                diagnosticMode = "workspace",
                useLibraryCodeForTypes = true,
                typeCheckingMode = "off"
            }
        }
    }
}
---]]

--[[
nvim_lsp.pylsp.setup {
    on_attach = on_attach,
    capabilities = capabilities,
    flags = { debounce_text_changes = 150 },
    settings = {
    },
}
--]]
nvim_lsp.tsserver.setup({
    capabilities = capabilities,
    on_attach = on_attach,
    flags = {debounce_text_changes = 150}
})

nvim_lsp.ccls.setup {
    on_attach = on_attach,
    capabilities = capabilities,
    flags = {debounce_text_changes = 150}
}

nvim_lsp.yamlls.setup {
    capabilities = capabilities,
    settings = {
        yamlls = {
            schemas = {
                ["https://raw.githubusercontent.com/argoproj/argo-workflows/master/api/jsonschema/schema.json"] = "~/code/argonaut",
                ["https://raw.githubusercontent.com/instrumenta/kubernetes-json-schema/master/v1.16.0-standalone-strict/all.json"] = ".*\\.k8s\\.yaml"
            },
            schemaDownload = {enable = true},
            validate = true
        }
    }
}

nvim_lsp.gopls.setup {
    cmd = {"gopls", "serve"},
    on_attach = on_attach,
    filetypes = {"go", "gomod"},
    root_dir = util.root_pattern("go.work", "go.mod", ".git"),
    settings = {
        gopls = {
            analyses = {unusedparams = true, shadow = true},
            staticcheck = true
        }
    }
}
nvim_lsp.sumneko_lua.setup {
    on_attach = on_attach,
    settings = {
        Lua = {
            diagnostic = false,
            workspace = {library = vim.api.nvim_get_runtime_file("", true)},
            telemetry = {enable = false}
        }
    }
}

local function GoOrdImports(wait_ms)
    local params = vim.lsp.util.make_range_params()
    params.context = {only = {"source.organizeImports"}}
    local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction",
                                            params, wait_ms)
    for _, res in pairs(result or {}) do
        for _, r in pairs(res.result or {}) do
            if r.edit then
                vim.lsp.util.apply_workspace_edit(r.edit, "UTF-8")
            else
                vim.lsp.buf.execute_command(r.command)
            end
        end
    end
end

function GoOnPreWrite()
    vim.lsp.buf.formatting_sync()
    -- GoOrdImports(1000)
end

-- require("lsp_signature").setup {bind = true, handler_opts = {border = "shadow"}}

local nls_utils = require("null-ls.utils")

local nls_with_diagnostics = function(builtin)
    return builtin.with {diagnostics_format = "#{m} [#{c}]"}
end

local null_ls = require("null-ls")

null_ls.setup {
    sources = {
        null_ls.builtins.formatting.black, null_ls.builtins.formatting.isort,
        nls_with_diagnostics(null_ls.builtins.diagnostics.flake8),
        nls_with_diagnostics(null_ls.builtins.diagnostics.mypy),

        null_ls.builtins.formatting.lua_format,
        nls_with_diagnostics(null_ls.builtins.diagnostics.luacheck)

    }

}

local group = vim.api.nvim_create_augroup("MyGroup", {clear = true});
vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*.py",
    callback = function() Formatting({async = true}) end,
    group = group
})
vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*.go",
    callback = function() print("formatting") end,
    group = group
})
vim.api.nvim_create_autocmd("FileType", {
    pattern = "yaml",
    command = "setlocal ts=12 sts=2 sw=2 expandtab indentkeys-=<:>",
    group = group
})
vim.api.nvim_create_autocmd("FileType", {
    pattern = "go",
    command = "setlocal noexpandtab ts=4 sts=4 sw=4",
    group = group
})
