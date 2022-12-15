if not pcall(require, "winbar") then return end

require('winbar').setup({
  enabled = true,

  show_file_path = true,
  show_symbols = true,

  colors = {
    path = '', -- You can customize colors like #c946fd
    file_name = '',
    symbols = ''
  },

  exclude_filetype = {'help', 'startify', 'dashboard', 'packer', 'neogitstatus', 'NvimTree', 'Trouble', 'alpha', 'lir', 'Outline', 'spectre_panel', 'toggleterm', 'qf'}
})
