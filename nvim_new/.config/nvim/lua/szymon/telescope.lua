local M = {}

local state = require("telescope.state")
local action_state = require("telescope.actions.state")

M.get_window_height = function(bufnr)
  local status = state.get_status(bufnr)
  return vim.api.nvim_win_get_height(status.preview_win)
end

M.scroll_window = function(prompt_bufnr, direction, mod)

  local previewer = action_state.get_current_picker(prompt_bufnr).previewer

  if type(previewer) ~= "table" or previewer.scroll_fn == nil then return end
  if type(mod) == "function" then mod = mod(prompt_bufnr) end

  local status = state.get_status(prompt_bufnr)
  local default_speed = vim.api.nvim_win_get_height(status.preview_win) / mod
  local speed = status.picker.layout_config.scroll_speed or default_speed

  previewer:scroll_fn(math.floor(speed * direction))
end

return M
