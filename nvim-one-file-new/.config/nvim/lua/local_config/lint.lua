local M = {}

function M.setup()
    local lint = require("lint")
    lint.linters_by_ft = {
        go = { "golangcilint" }
    }

    lint.linters.golangcilint.args = {
        'run',
        '--output.json.path=stdout',
        '--issues-exit-code=0',
        '--show-stats=false',
        '--output.text.print-issued-lines=false',
        '--output.text.print-linter-name=false',
        function()
            return vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":h")
        end
    }

    vim.api.nvim_create_autocmd(opts.events, {
        group = vim.api.nvim_create_augroup("nvim-lint", { clear = true }),
        callback = function() require("lint").try_lint() end,
    })
end

return M
