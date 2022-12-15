if not pcall(require, "barbecue") then return end

require("barbecue").setup({create_autocmd = false, kinds = false, symbols = {modified = "M", ellipsis = "...", separator = ">"}})

vim.api.nvim_create_autocmd({
  "WinScrolled", "BufWinEnter", "CursorMoved", "InsertLeave", "BufWritePost", "TextChanged", "TextChangedI"
  -- add more events here
}, {
  group = vim.api.nvim_create_augroup("barbecue", {}),
  callback = function()
    require("barbecue.ui").update()

    -- maybe a bit more logic here
  end
})
