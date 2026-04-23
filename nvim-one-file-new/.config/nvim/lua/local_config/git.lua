local M = {}

function M.setup()
    local gitsigns = require("gitsigns")

    gitsigns.setup({
        watch_gitdir = { interval = 1000 }
    })
    vim.api.nvim_set_hl(0, "GitSignsAdd", { link = "SignAdd" })
    vim.api.nvim_set_hl(0, "GitSignsChange", { link = "SignChange" })
    vim.api.nvim_set_hl(0, "GitSignsChangedelete", { link = "SignChange" })
    vim.api.nvim_set_hl(0, "GitSignsDelete", { link = "SignDelete" })
    vim.api.nvim_set_hl(0, "GitSignsTopdelete", { link = "SignDelete" })
    vim.api.nvim_set_hl(0, "GitSignsUntracked", { link = "SignAdd" })


    vim.keymap.set("n", "<leader>hs", gitsigns.stage_hunk, { desc = "[gitsigns] stage hunk" })
    vim.keymap.set("n", "<leader>hs", gitsigns.stage_hunk, { desc = "[gitsigns] stage hunk" })
    vim.keymap.set("n", "<leader>hu", gitsigns.undo_stage_hunk, { desc = "[gitsigns] undo stage hunk" })
    vim.keymap.set("n", "<leader>hr", gitsigns.reset_hunk, { desc = "[gitsigns] reset hunk" })
    vim.keymap.set("n", "<leader>hR", gitsigns.reset_buffer, { desc = "[gitsigns] reset buffer" })
    vim.keymap.set("n", "<leader>hp", gitsigns.preview_hunk, { desc = "[gitsigns] preview hunk" })
    vim.keymap.set("n", "<leader>hb", gitsigns.blame_line, { desc = "[gitsigns] blame line" })
    vim.keymap.set("n", "]h", gitsigns.next_hunk, { desc = "[gitsigns] next hunk" })
    vim.keymap.set("n", "[h", gitsigns.prev_hunk, { desc = "[gitsigns] next hunk" })
end

return M
