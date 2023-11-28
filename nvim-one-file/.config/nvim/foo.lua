-- TODO:
--  - [ ] add diagnostics on failed tests
--  - [ ] add command to run tests for current buffer
--  - [ ] add command to run currently hovered test (when hovering over test name)
--  - [ ] add command to run all failed tests in current buffer
--  - [ ] add command to run

local M = {}


local function load_report(path)
    return vim.fn.system("cat " .. path)
end

local function _get_keys(tbl)
    local keys = {}
    for k, _ in pairs(tbl) do
        table.insert(keys, k)
    end
    return keys
end

local function get_crash_info_from_test(test)
    local result = nil

    if test.setup.outcome == "failed" then
        result = {
            type = "setup",
            traceback = test.setup.traceback,
            message = vim.split(test.setup.crash.message, "\n"),
            lnum = test.setup.crash.lineno,
        }
    elseif test.call.outcome == "failed" then
        result = {
            type = "call",
            traceback = test.call.traceback,
            message = vim.split(test.call.crash.message, "\n"),
            lnum = test.call.crash.lineno,
        }
    end

    return result
end

M.parse_tests = function()
    local data = vim.json.decode(load_report(".report.json"))

    local results = {}
    for _, test in ipairs(data.tests) do
        local crash = nil
        if test.outcome == "failed" then
            crash = get_crash_info_from_test(test)
        end
        table.insert(results, {
            nodeid = test.nodeid,
            outcome = test.outcome,
            lineno = test.lineno,
            crash = crash,
        })
    end

    return results
end


local ns = vim.api.nvim_create_namespace("pytest")

-- print(vim.inspect(M.parse_tests()))

-- vim.api.nvim_buf_set_extmark(0, ns, 1, 0, {
--     virt_text = {{ "ala ma kota" }},
-- })

-- vim.api.nvim_create_user_command(
--     "ParseTests",
--     M.parse_tests,
--     {
--         nargs = 0,
--     }
-- )

local function parse_tests_for_current_buffer(bufnr)
    local results = M.parse_tests()
    local extmarks = vim.api.nvim_buf_get_extmarks(bufnr, ns, 0, -1, {})
    for _, extmark in ipairs(extmarks) do
        vim.api.nvim_buf_del_extmark(bufnr, ns, extmark[1])
    end

    local failed = {}
    for _, result in ipairs(results) do
        if result.outcome == "passed" then
            vim.api.nvim_buf_set_extmark(bufnr, ns, result.lineno, 0, {
                hl_group = "SpecialComment",
                virt_text = { { "✓" } },
            })
        elseif result.outcome == "failed" then
            table.insert(failed, {
                bufnr = bufnr,
                lnum = result.lineno,
                col = 0,
                severity = vim.diagnostic.severity.ERROR,
                source = "pytest",
                message = "test failed",
                user_data = {},
            })
        end
    end


    vim.diagnostic.set(ns, bufnr, failed, {})
end

vim.api.nvim_create_user_command("Pytest", function(opts)
    local bufnr = vim.api.nvim_get_current_buf()

    if opts.args == "run" then
        print(vim.inspect(vim.fn.getbufinfo(bufnr)))
    elseif opts.args == nil then
        parse_tests_for_current_buffer(vim.api.nvim_get_current_buf())
    end
end, {
    nargs = "?",
})


vim.diagnostic.set(ns, vim.api.nvim_get_current_buf(), {}, {})
vim.keymap.set('n', "<leader>tp", "<cmd>Pytest<CR>", { noremap = true, silent = true })
