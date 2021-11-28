vim.cmd "packadd packer.nvim"

local use = require("packer").use

return require("packer").startup(function()
    use "wbthomason/packer.nvim"
    use {"nvim-telescope/telescope.nvim", requires = {{"nvim-lua/plenary.nvim"}}}
    use "neovim/nvim-lspconfig"
    use 'phanviet/vim-monokai-pro'
    use 'markonm/traces.vim'
    use 'romainl/vim-cool'
    use {'lewis6991/gitsigns.nvim', requires = {'nvim-lua/plenary.nvim'}}
end)

