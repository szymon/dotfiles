local M = {}

local function select_client(method)
  local clients = vim.tbl_values(vim.lsp.buf_get_clients())
  clients = vim.tbl_filter(function(client) return client.supports_method(method) end, clients)

  for i = 1, #clients do if clients[i].name == "efm" or clients[i].name == "null-ls" then return clients[i] end end

  return clients[1]
end

M.format = function(options, timeout_ms)
  ---@diagnostic disable-next-line: redefined-local
  local util = vim.lsp.util
  local params = util.make_formatting_params(options)
  local bufnr = vim.api.nvim_get_current_buf()
  local client = select_client("textDocument/formatting")
  if client == nil then return end

  local result, err = client.request_sync("textDocument/formatting", params, timeout_ms, bufnr)
  if result and result.result then
    util.apply_text_edits(result.result, bufnr, client.offset_encoding)
  elseif err then
    vim.notify("vim.lsp.buf.formatting_sync" .. err, vim.log.levels.WARN)
  end

end

local function run_sql_formatter(text)

  -- local bin = vim.api.nvim_get_runtime_file("bin/sql-format-via-python.py", false)[1]
  local bin = '/home/srams/.local/share/nvm/v18.1.0/bin/sql-formatter-cli'

  local j = require("plenary.job"):new{command = "node", args = {bin}, writer = {text}}
  return j:sync()
end

M.format_dat_sql = function(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  if vim.bo[bufnr].filetype == "sql" then
    local text = table.concat(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), "\n")
    local formatted = run_sql_formatter(text)

    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, formatted)

  elseif vim.bo[bufnr].filetype ~= "python" then
    vim.notify "can only be used on sql or python file"
    return
  end
end

return M
