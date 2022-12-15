if not pcall(require, "gitsigns") then return end

require("gitsigns").setup {
  signs = {add = {hl = "SignAdd", text = "+"}, change = {hl = "SignChange", text = "~"}, delete = {hl = "SignDelete", text = "-"}, topdelete = {hl = "SignDelete", text = "-"}, changedelete = {hl = "SignChange", text = "~"}},
  watch_gitdir = {interval = 1000}
}
