local nvim_lsp = require("lspconfig")
USER = vim.fn.expand("$USER")

local sumneko_root_path = ""
local sumneko_binary = ""

if vim.fn.has("mac") == 1 then
    sumneko_root_path = "/Users/" .. USER .. "/.config/nvim/lua-language-server"
    sumneko_binary = "/Users/" .. USER .. "/.config/nvim/lua-language-server/bin/macOS/lua-language-server"
elseif vim.fn.has("unix") == 1 then
    sumneko_root_path = "/home/" .. USER .. "/.config/nvim/lua-language-server"
    sumneko_binary = "/home/" .. USER .. "/.config/nvim/lua-language-server/bin/Linux/lua-language-server"
else
    print("Unsupported system for sumneko")
end

local cmp = require("cmp")
cmp.setup({
    mapping = {
        ["<c-b>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), {'i', 'c'}),
        ["<c-f>"] = cmp.mapping(cmp.mapping.scroll_docs(4), {'i', 'c'}),
        ["<c-space>"] = cmp.mapping(cmp.mapping.complete(), {'i', 'c'}),
        ["<c-y>"] = cmp.config.disable,
        ["<c-e>"] = cmp.mapping({i = cmp.mapping.abort(), c = cmp.mapping.close()}),
        --        ["<cr>"] = cmp.mapping.confirm({select = true})
        ["<tab>"] = cmp.mapping(cmp.mapping.select_next_item(), {"i", "s"})
    },
    sources = cmp.config.sources({{name = "nvim_lsp"}}, {{name = "buffer"}})
})

local custom_handlers = {
    ["textDocument/definition"] = function(_, result, params)
        if result == nil or vim.tbl_isempty(result) then
            local _ = vim.lsp.log.info() and vim.lsp.log.info(params.method, "No location found")
            return nil
        end

        if vim.tbl_islist(result) then
            vim.lsp.util.jump_to_location(result[1])
            vim.fn.setqflist(vim.lsp.util.locations_to_items(result))
        else
            vim.lsp.util.jump_to_location(result)
        end

    end
}

cmp.setup.cmdline("/", {sources = {{name = "buffer"}}})
-- cmp.setup.cmdline(":", {sources = cmp.config.sources({{name = "path"}}, {{name = "cmdline"}})})

local capabilities = require("cmp_nvim_lsp").update_capabilities(vim.lsp.protocol.make_client_capabilities())
---@diagnostic disable-next-line: unused-local
local on_attach = function(client, bufnr)
    local function buf_set_keymap(...)
        vim.api.nvim_buf_set_keymap(bufnr, ...)
    end
    local function buf_set_option(...)
        vim.api.nvim_buf_set_option(bufnr, ...)
    end

    -- Enable completion triggered by <c-x><c-o>
    -- buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

    -- Mappings.
    local opts = {noremap = true, silent = true}

    -- See `:help vim.lsp.*` for documentation on any of the below functions
    buf_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
    buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
    buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
    buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
    buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
    buf_set_keymap('n', '<leader>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
    buf_set_keymap('n', '<leader>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
    buf_set_keymap('n', '<leader>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
    buf_set_keymap('n', '<leader>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
    buf_set_keymap('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
    buf_set_keymap('n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
    buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
    buf_set_keymap('n', '<leader>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
    buf_set_keymap('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
    buf_set_keymap('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
    buf_set_keymap('n', '<leader>q', '<cmd>lua vim.lsp.diagnostic.set_quickfixlist()<CR>', opts)
    buf_set_keymap('n', '<leader>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)

    vim.cmd [[
    augroup SZYMON_AUGROUP
        au!
        autocmd BufWritePre *.lua lua vim.lsp.buf.formatting_sync()
        autocmd FileType yaml setlocal ts=12 sts=2 sw=2 expandtab indentkeys-=<:>
        autocmd FileType go setlocal noexpandtab ts=4 sts=4 sw=4
        autocmd FileType python setlocal expandtab ts=4 sts=4 sw=4
        autocmd BufWritePre *.py lua vim.lsp.buf.formatting_sync()
    augroup END
    ]]

    require'illuminate'.on_attach(client)
end

nvim_lsp.pyright.setup {
    handlers = custom_handlers,
    on_attach = on_attach,
    capabilities = capabilities,
    flags = {debounce_text_changes = 150},
    settings = {python = {analysis = {autoSearchPaths = true, diagnosticMode = "workspace", useLibraryCodeForTypes = true}}}
}

nvim_lsp.ccls.setup {on_attach = on_attach, capabilities = capabilities, flags = {debounce_text_changes = 150}}

nvim_lsp.hls.setup {on_attach = on_attach, settings = {haskell = {hlintOn = true, formattingProvider = "fourmolu"}}}

-- cd lua-language-server/3rd/luamake
-- ninja -f compile/luamake/{linux,macos}.ninja
-- cd ../../
-- ./3rd/luamake/luamake rebuild
nvim_lsp.sumneko_lua.setup {
    on_attach = on_attach,
    capabilities = capabilities,
    cmd = {sumneko_binary, "-E", sumneko_root_path .. "/main.lua"},
    settings = {
        Lua = {
            runtime = {version = "LuaJIT", path = vim.split(package.path, ";")},
            diagnostics = {globals = {"vim"}},
            workspace = {library = {[vim.fn.expand("$VIMRUNTIME/lua")] = true, [vim.fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true}}
        }
    }
}

-- luarocks install --server=https://luarocks.org/dev luaformatter
-- go install github.com/mattn/efm-langserver
nvim_lsp.efm.setup {
    init_options = {documentFormatting = true},
    filetypes = {"lua", "python"},
    settings = {
        rootMarkers = {".git/", ".project", "venv/", ".venv/", vim.fn.expand("~/.config/nvim"), vim.fn.expand("~/.config/nvim/lua")},
        languages = {
            --            lua = {
            --                {
            --                    formatCommand = "lua-format -i --no-keep-simple-function-one-line --no-break-after-operator --column-limit=150 --break-after-table-lb",
            --                    formatStdin = true
            --                }
            --            },
            python = {
                {formatCommand = "black --quiet -", formatStdin = true}, {formatCommand = "isort --profile=black -", formatStdin = true},
                {formatCommand = "autoflake -", formatStdin = true}
            }
        }
    }
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
    capabilities = capabilities,
    settings = {
        gopls = {experimentalPostfixCompletions = true, analyses = {unusedparams = true, shadow = true}, staticcheck = true},
        on_attach = on_attach
    }
}

require("lsp_signature").setup {bind = true, handler_opts = {border = "shadow"}}

vim.cmd [[
augroup SZYMON_AUGROUP
    au!
    autocmd BufWritePre *.go lua vim.lsp.buf.formatting()
    " autocmd BufWritePre *.go lua goimports(1000)
    autocmd BufWritePre *.lua lua vim.lsp.buf.formatting_sync(nil, 100)
    autocmd BufWritePre *.py lua vim.lsp.buf.formatting()
    autocmd FileType yaml setlocal ts=12 sts=2 sw=2 expandtab indentkeys-=<:>
    autocmd FileType go setlocal noexpandtab ts=4 sts=4 sw=4
augroup END
]]
