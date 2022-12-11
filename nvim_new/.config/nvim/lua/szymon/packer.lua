return require("packer").startup(function()
    use "wbthomason/packer.nvim"

    use "nvim-lua/plenary.nvim"
    use "nvim-lua/popup.nvim"
    use "nvim-telescope/telescope.nvim"

    use {
        "nvim-lualine/lualine.nvim",
        requires = { "kyazdani42/nvim-web-devicons", opt = true }
    }

    use {"nvim-treesitter/nvim-treesitter", ["do"] = "TSUpdate"}
    use {"nvim-treesitter/playground"}
    use "neovim/nvim-lspconfig"
    use "markonm/traces.vim"
    use "romainl/vim-cool"
    use {"lewis6991/gitsigns.nvim", requires = {"nvim-lua/plenary.nvim"}}
    use {
        "hrsh7th/cmp-nvim-lsp",
        requires = {
            "neovim/nvim-lspconfig", "hrsh7th/nvim-cmp", "hrsh7th/cmp-buffer", "hrsh7th/cmp-path", "hrsh7th/cmp-cmdline"
        }
    }
    use "kana/vim-submode"
    -- use "rrethy/vim-illuminate"
    -- use "ray-x/lsp_signature.nvim"
    use "tpope/vim-fugitive"
    -- use "junegunn/gv.vim"
    use "sainnhe/gruvbox-material"
    use "eddyekofo94/gruvbox-flat.nvim"
    use "phanviet/vim-monokai-pro"
    use "folke/tokyonight.nvim"
    use "jose-elias-alvarez/null-ls.nvim"
    use {"petertriho/cmp-git", requires = "nvim-lua/plenary.nvim"}
    use "Vimjas/vim-python-pep8-indent"
    use "google/vim-jsonnet"

    use {
        'folke/trouble.nvim',
        config = function()
            require("trouble").setup {
                icons = false,
            }
        end
    }

end)
