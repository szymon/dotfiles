local M = {}

local gitsigns = require('gitsigns')

M.debug = function()
    print(vim.inspect(vim.api.nvim_buf_get_mark(0, "<")))
end

M.stage_selection = function()

    local start_pos = vim.api.nvim_buf_get_mark(0, "<")[1]
    local end_pos = vim.api.nvim_buf_get_mark(0, ">")[1]

    print("Staging lines from: " .. start_pos .. " to: " .. end_pos)

    gitsigns.stage_hunk({start_pos, end_pos})

end

return M
