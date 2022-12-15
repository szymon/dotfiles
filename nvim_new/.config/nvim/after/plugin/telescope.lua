if not pcall(require, "telescope") then return end

local t = require("szymon.telescope")

local actions = require("telescope.actions")

require("telescope").setup({
  defaults = {
    mappings = {
      i = {
        ["<c-f>"] = function(pbn) t.scroll_window(pbn, 1, 1) end,
        ["<c-b>"] = function(pbn) t.scroll_window(pbn, -1, 1) end,
        ["<c-e>"] = function(pbn) t.scroll_window(pbn, 1, t.get_window_height) end,
        ["<c-y>"] = function(pbn) t.scroll_window(pbn, -1, t.get_window_height) end,
        ["<c-k>"] = actions.move_selection_previous,
        ["<c-j>"] = actions.move_selection_next,
        ["<c-h>"] = actions.which_key,
        ["<esc>"] = actions.close

      }
    }
  }
})
