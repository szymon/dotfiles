vim.cmd [[ source ~/.vimrc ]]

vim.opt.guicursor = ""
vim.opt.signcolumn = "yes"
vim.opt.wrap = false
vim.opt.spell = false
vim.opt.colorcolumn = "88,120"
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.background = "dark"
vim.opt.laststatus = 3
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undo"
vim.opt.undofile = true
vim.opt.updatetime = 200
vim.opt.winborder = "rounded"

-- built-in completion & tag search
vim.opt.completeopt:append{"fuzzy", "menuone", "noselect", "popup"}
vim.opt.complete:remove{"t"}
vim.opt.completefunc = "v:lua.require'snipcomp'" -- custom snippet completion defined in lua/snipcomp.lua

vim.filetype.add({ extension = { templ = "templ" } })

vim.g.mouse = "a"

vim.g.gruvbox_flat_style = "hard"

vim.keymap.set("n", "<leader>f", vim.lsp.buf.format)
vim.keymap.set("n", "<leader>t", "<cmd>Oil<cr>")
vim.keymap.set("n", "<c-p>", "<cmd>Pick files<cr>")
vim.keymap.set("n", "<leader>rr", "<cmd>Pick grep_live<cr>")

vim.keymap.set("v", "J", ":m '>+1<cr>gv=gv", { desc = "[general] move selected line down" })
vim.keymap.set("v", "L", ":m '<-2<cr>gv=gv", { desc = "[general] move selected line up" })

vim.keymap.set("n", "Y", "yg$", { desc = "[general] yank to end of line" })

vim.keymap.set("x", "<leader>p", '"_dP', { desc = "[general] paste without overwriting clipboard" })

-- disable ex mode
vim.keymap.set("n", "Q", "<nop>", { desc = "[general] disable ex mode" })

-- keep cursor inplace when joining lines
vim.keymap.set("n", "J", "mzJ`z", { desc = "[general] join lines without moving the cursor" })

-- keep cursor in the center when jumping half page
vim.keymap.set("n", "<c-d>", "<c-d>zz", { desc = "[general] jump half page down and center the cursor" })
vim.keymap.set("n", "<c-u>", "<c-u>zz", { desc = "[general] jump half page up and center the cursor" })

-- keep cursor in the center when searching with n/N
vim.keymap.set("n", "n", "nzzzv", { desc = "[general] search next and center the cursor" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "[general] search previous and center the cursor" })

vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<cr>", { desc = "[general] make file executable" })

vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "[general] open diagnostics" })
-- vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)


vim.keymap.set("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end,
    { desc = "[general] go to previous diagnostic" })
vim.keymap.set("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end,
    { desc = "[general] go to next diagnostic" })

vim.keymap.set("n", ";", "dd", { desc = "[general] remove line" })
vim.keymap.set("i", "<c-space>", "<c-x><c-o>")

vim.keymap.set("v", "<leader>rr", function()
    local start_col = vim.fn.getpos("v")[3]
    local end_col = vim.fn.getpos(".")[3]
    local line = vim.fn.getline("."):sub(start_col, end_col)

    vim.schedule(function()
        require("mini.pick").set_picker_query({ line })
    end)
    require("mini.pick").builtin.grep_live({})
end)


vim.keymap.set("n", "gb", function()
    local opts = { count = 1 }
    local bufnr = vim.api.nvim_get_current_buf()
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    local line = vim.api.nvim_buf_get_lines(bufnr, row - 1, row, false)
    vim.api.nvim_buf_set_lines(bufnr, row, row, false, line)
    vim.api.nvim_win_set_cursor(0, { row + opts.count, col })
end, { desc = "[general] duplicate current line and move down" })

vim.keymap.set("n", "<leader>m", function()
    local current_file = vim.api.nvim_buf_get_name(0)

    local dir = vim.fn.fnamemodify(current_file, ":h")
    local filename = vim.fn.fnamemodify(current_file, ":t")

    local target_file
    if filename:match("_test%.go$") then
        target_file = filename:gsub("_test%.go$", ".go")
    elseif filename:match("%.go$") then
        target_file = filename:gsub("%.go$", "_test.go")
    else
        print("Not a Go file or test file!")
        return
    end

    local target_path = dir .. "/" .. target_file

    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf) then
            local buf_path = vim.api.nvim_buf_get_name(buf)
            if buf_path == target_path then
                for _, win in ipairs(vim.api.nvim_list_wins()) do
                    if vim.api.nvim_win_get_buf(win) == buf then
                        vim.api.nvim_set_current_win(win)
                        print("Switched to already open file: " .. target_path)
                        return
                    end
                end
            end
        end
    end

    vim.cmd("rightb vsplit " .. target_path)
end)


vim.pack.add({
    { src = "https://github.com/stevearc/oil.nvim" },
    { src = "https://github.com/echasnovski/mini.nvim" },
    { src = "https://github.com/nvim-lua/plenary.nvim" },

    -- -- cmp
    -- { src = "https://github.com/hrsh7th/nvim-cmp" },
    -- { src = "https://github.com/saadparwaiz1/cmp_luasnip" },
    -- { src = "https://github.com/hrsh7th/cmp-nvim-lsp" },
    -- { src = "https://github.com/hrsh7th/cmp-path" },

    -- themes
    { src = "https://github.com/folke/tokyonight.nvim" },
    { src = "https://github.com/ellisonleao/gruvbox.nvim" },

    -- treesitter
    { src = "https://github.com/nvim-treesitter/nvim-treesitter" },

    -- git
    { src = "https://github.com/lewis6991/gitsigns.nvim" },

    -- snippet
    { src = "https://github.com/L3MON4D3/LuaSnip" },

    -- lsp related
    { src = "https://github.com/neovim/nvim-lspconfig" },
    { src = "https://github.com/j-hui/fidget.nvim" },
    { src = "https://github.com/williamboman/mason.nvim" },
    { src = "https://github.com/williamboman/mason-lspconfig.nvim" },
    { src = "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim" },
    { src = "https://github.com/supermaven-inc/supermaven-nvim" },

    -- linter
    { src = "https://github.com/mfussenegger/nvim-lint" },

    -- harpoon
    {
        src = "https://github.com/ThePrimeagen/harpoon",
        version = "harpoon2"
    },

    -- golang
    { src = "https://github.com/ray-x/go.nvim" },

    -- jsonnet
    { src = "https://github.com/google/vim-jsonnet" },
})

require("mini.pick").setup({
    mappings = {
        caret_left = "<c-b>",
        caret_right = "<c-f>",
        choose_marked = "<c-q>",
        scroll_up = "",
        scroll_down = "",
    },
})
require("oil").setup()

require("local_config.theme").setup()
require("local_config.lsp").setup()
require("local_config.treesitter").setup()
require("local_config.statusline").setup()
require("local_config.git").setup()
require("local_config.snippets").setup()
require("local_config.supermaven").setup()
require("local_config.harpoon").setup()
-- require("local_config.lint").setup()
-- require("local_config.pick").setup()

vim.api.nvim_create_autocmd("TextYankPost",
    { callback = function() vim.highlight.on_yank() end, pattern = "*" }
)
