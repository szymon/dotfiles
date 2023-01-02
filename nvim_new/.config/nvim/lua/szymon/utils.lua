function select_client(method)
  local clients = vim.tbl_values(vim.lsp.buf_get_clients())
  clients = vim.tbl_filter(function(client) return client.supports_method(method) end, clients)

  for i = 1, #clients do if clients[i].name == "efm" or clients[i].name == "null-ls" then return clients[i] end end

  return clients[1]
end

function Formatting(options, timeout_ms)
    print("here")
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
