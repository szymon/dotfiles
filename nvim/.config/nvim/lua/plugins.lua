vim.cmd "packadd packer.nvim"

local use = require("packer").use

-- git clone --depth 1 https://github.com/wbthomason/packer.nvim ~/.local/share/nvim/site/pack/packer/start/packer.nvim
return require("packer").startup(function()
    use "wbthomason/packer.nvim"
    use {"nvim-telescope/telescope.nvim", requires = {{"nvim-lua/plenary.nvim"}}}
    use "neovim/nvim-lspconfig"
    use "phanviet/vim-monokai-pro"
    use "markonm/traces.vim"
    use "romainl/vim-cool"
    use {"lewis6991/gitsigns.nvim", requires = {"nvim-lua/plenary.nvim"}}
     use {
         "hrsh7th/cmp-nvim-lsp",
         requires = {"neovim/nvim-lspconfig", "hrsh7th/nvim-cmp", "hrsh7th/cmp-buffer", "hrsh7th/cmp-path", "hrsh7th/cmp-cmdline"}
     }
    use "kana/vim-submode"
    -- use "google/jsonnet"
    use "morhetz/gruvbox"
    use "rrethy/vim-illuminate"
end)

