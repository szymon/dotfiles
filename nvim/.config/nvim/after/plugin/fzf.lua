
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
vim.keymap.set("n", "<leader>;", fzf.files, { desc = "fzf buffers" })
vim.keymap.set("n", "<leader>gr", fzf.files, { desc = "fzf grep" })
vim.keymap.set("n", "<leader>sw", fzf.files, { desc = "fzf cword" })
