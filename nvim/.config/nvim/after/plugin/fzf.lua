fzf = require("fzf-lua")

fzf.setup({
    { "telescope", "fzf-native", "max-perf" },
    keymap = {
        fzf = {
            ["ctrl-q"] = "select-all+accept",
        },
    },
    files = {
        cmd = [[rg --files --color=never --hidden -g '!.git' -g '!*.pb.go' -g '!*.pb.mock.go' -g '!.jj/' ]],
    },
})

vim.keymap.set("n", "<c-p>", fzf.files, { desc = "fzf files" })
vim.keymap.set("n", "<leader>;", fzf.buffers, { desc = "fzf buffers" })
vim.keymap.set("n", "<leader>gr", fzf.live_grep_native, { desc = "fzf grep" })
vim.keymap.set("n", "<leader>sw", fzf.grep_cword, { desc = "fzf cword" })
vim.keymap.set("v", "<leader>sw", function(args)
    local selection = require("fzf-lua.utils").get_visual_selection()
    fzf.live_grep({ search = selection })
end, { desc = "fzf selection" })
