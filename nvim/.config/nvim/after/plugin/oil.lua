

oil = require("oil")

oil.setup()

vim.keymap.set("n", "<leader>t", oil.toggle_float, { desc = "Oil toggle float" })
