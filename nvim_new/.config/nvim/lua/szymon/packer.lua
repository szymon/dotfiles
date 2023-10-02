local install_path = vim.fn.stdpath 'data' .. '/site/pack/packer/start/packer.nvim'
local is_bootstrap = false

if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  is_bootstrap = true
  vim.fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim'}, install_path)
  vim.cmd [[ packadd packer.nvim ]]
end

return require("packer").startup(function(use)
  -- let packer manage itself
  use "wbthomason/packer.nvim"

  use {"nvim-telescope/telescope.nvim", requires = {{"nvim-lua/plenary.nvim"}}}

  -- lsp config
  -- use "nvim-lua/popup.nvim"

  use {"nvim-lualine/lualine.nvim", requires = {"kyazdani42/nvim-web-devicons", opt = true}}

  use {"nvim-treesitter/nvim-treesitter", run = ":TSUpdate"}
  use {"nvim-treesitter/playground"}

  use {"lewis6991/gitsigns.nvim", requires = {"nvim-lua/plenary.nvim"}}

  use {
    "VonHeikemen/lsp-zero.nvim",
    branch = "v1.x",
    requires = {
      {"neovim/nvim-lspconfig"},
      {"williamboman/mason.nvim"},
      {"williamboman/mason-lspconfig.nvim"},

      -- Autocompletion
      {'hrsh7th/nvim-cmp'},
      {'hrsh7th/cmp-buffer'},
      {'hrsh7th/cmp-path'},
      {'saadparwaiz1/cmp_luasnip'},
      {'hrsh7th/cmp-nvim-lsp'},
      {'hrsh7th/cmp-nvim-lua'},

      -- Snippets
      {'L3MON4D3/LuaSnip'}
    }
  }

  use "tpope/vim-fugitive"
  use "sainnhe/gruvbox-material"
  use "jose-elias-alvarez/null-ls.nvim"
  use {"petertriho/cmp-git", requires = "nvim-lua/plenary.nvim"}
  use "Vimjas/vim-python-pep8-indent"
  use "google/vim-jsonnet"

  use {'folke/trouble.nvim', config = function() end}

  use {"github/copilot.vim"}

  use {"ray-x/go.nvim"}
  -- use {"ray-x/lsp_signature.nvim"}

  use {"tribela/vim-transparent"}
  use {"yorik1984/zola.nvim", requires = {"Glench/Vim-Jinja2-Syntax"}}

  use {"ThePrimeagen/git-worktree.nvim"}

  use {"mfussenegger/nvim-lint"}

  -- use {"mhartington/formatter.nvim"}
  -- use {"nvimdev/guard.nvim"}
end)
