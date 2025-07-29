vim.cmd [[ source ~/.vimrc ]]

vim.g.zig_fmt_autosave = false
vim.opt.guicursor = ""
vim.opt.signcolumn = "yes"
vim.opt.wrap = false
vim.opt.spell = false
vim.opt.relativenumber = true
vim.opt.number = true
vim.opt.colorcolumn = "88,120"
vim.opt.background = "dark"
vim.opt.laststatus = 3
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undo"
vim.opt.undofile = true
vim.opt.updatetime = 200
vim.filetype.add({ extension = { templ = "templ" } })

vim.g.mouse = "a"
vim.g.gruvbox_flat_style = "hard"
vim.g.Illuminate_delay = 300
vim.g.undotree_DiffAutoOpen = false

-- Keymaps {{{
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

vim.keymap.set("n", "<leader>t", function()
    local netrw_exists = false
    local netrw_win = nil
    local all_windows = vim.api.nvim_list_wins()
    local window_count = #all_windows

    for _, win in ipairs(all_windows) do
        local buf = vim.api.nvim_win_get_buf(win)
        local filetype = vim.api.nvim_get_option_value("filetype", { buf = buf })
        if filetype == "netrw" then
            netrw_exists = true
            netrw_win = win
        end
    end

    if netrw_exists then
        if window_count == 1 then
            vim.cmd("silent! edit #")
            if vim.bo.filetype == "netrw" then
                vim.cmd("enew")
            end
        else
            assert(netrw_win ~= nil, "netrw_win must be set")
            vim.api.nvim_win_close(netrw_win, true)
        end
    else
        vim.cmd("Sexplore")
    end
end)

vim.keymap.set("n", "<leader>m", function()
    --[[
    --  toggle between normal file and test file.
    --]]
    -- Get the current file's full path
    local current_file = vim.api.nvim_buf_get_name(0)

    -- Extract the directory and filename
    local dir = vim.fn.fnamemodify(current_file, ":h")      -- Get the directory
    local filename = vim.fn.fnamemodify(current_file, ":t") -- Get the filename

    -- Determine the target file
    local target_file
    if filename:match("_test%.go$") then
        -- If the current file is a test file, switch to the implementation file
        target_file = filename:gsub("_test%.go$", ".go")
    elseif filename:match("%.go$") then
        -- If the current file is an implementation file, switch to the test file
        target_file = filename:gsub("%.go$", "_test.go")
    else
        print("Not a Go file or test file!")
        return
    end

    -- Construct the full path to the target file
    local target_path = dir .. "/" .. target_file

    -- Check if the target file is already open in a buffer
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf) then
            local buf_path = vim.api.nvim_buf_get_name(buf)
            if buf_path == target_path then
                -- Find the window displaying the buffer
                for _, win in ipairs(vim.api.nvim_list_wins()) do
                    if vim.api.nvim_win_get_buf(win) == buf then
                        -- Switch to the window displaying the buffer
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

-- }}}

-- Plugins {{{

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end

local function dupLine(opts)
    if opts == nil then
        opts = {
            count = 1
        }
    end
    local bufnr = vim.api.nvim_get_current_buf()
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    local line = vim.api.nvim_buf_get_lines(bufnr, row - 1, row, false)
    vim.api.nvim_buf_set_lines(bufnr, row, row, false, line)
    vim.api.nvim_win_set_cursor(0, { row + opts.count, col })
end

vim.keymap.set("n", "gb", dupLine, { desc = "[general] duplicate current line and move down" })

vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins", {
    dev = {
        path = "~/code",
    }
})

-- }}}


-- Statusline {{{

local function create_statusline_helpers()
    local M = {}
    local active_sep = "blank"

    M.separators = { blank = { "", "" } }

    M.colors = {
        active = "%#StatusLine#",
        inactive = "%#StatusLineNC#",
        mode = "%#Mode#",
        mode_alt = "%#ModeAlt#",
        git = "%#Git#",
        git_alt = "%#GitAlt#",
        filetype = "%#Filetype#",
        filetype_alt = "%#FiletypeAlt#",
        line_col = "%#LineCol#",
        line_col_alt = "%#LineColAlt#"
    }

    M.truncate_width = setmetatable({
            mode = 80,
            git_status = 90,
            filename = 140,
            line_col = 60
        },
        {
            __index = function()
                return 80
            end
        }
    )

    M.is_truncated = function(_, width)
        local current_width = vim.api.nvim_win_get_width(0)
        return current_width < width
    end

    M.modes = setmetatable({
        ["n"] = { "Normal", "N " },
        ["no"] = { "Normal·Operator Pending", "NP" },
        ["v"] = { "Visual", "V " },
        ["V"] = { "V·Line", "VL" },
        -- V Block is ^V (enter with <c-v><c-v>
        [""] = { "V·Blck", "VL" },
        ["s"] = { "Select", "S " },
        ["S"] = { "S·Line", "SL" },
        [""] = { "S·Block", "SB" },
        ["i"] = { "Insert", "I " },
        ["R"] = { "Replace", "R " },
        ["Rv"] = { "V·Replace", "VR" },
        ["c"] = { "CMD   ", "C " },
        ["cv"] = { "Vim Ex", "X " },
        ["ce"] = { "Ex", "EX" },
        ["r"] = { "Prompt", "P " },
        ["rm"] = { "More", "M " },
        ["r?"] = { "Confirm", "C " },
        ["!"] = { "Shell", "S " },
        ["t"] = { "Terminal", "T " }
    }, { __index = function() return { "Unknown", "U" } end })

    M.get_current_mode = function(self)
        ---@diagnostic disable-next-line
        local current_mode = vim.api.nvim_get_mode().mode

        if self:is_truncated(self.truncate_width.mode) then
            return string.format(" %s ", self.modes[current_mode][2])
                :upper()
        end
        return string.format(" %s ", self.modes[current_mode][1]):upper()
    end

    M.get_git_status = function(self)
        local signs = vim.b.gitsigns_status_dict or { head = "", added = 0, changed = 0, removed = 0 }
        local is_head_empty = signs.head ~= ""

        if self:is_truncated(self.truncate_width.git_status) then
            return is_head_empty and
                string.format(" %s ", signs.head or "") or ""
        end
        return is_head_empty and
            string.format(" +%s ~%s -%s | %s ", signs.added, signs.changed, signs.removed, signs.head) or ""
    end

    M.get_filename = function(self)
        if self:is_truncated(self.truncate_width.filename) then return " %<%f " end
        return " %<%F "
    end

    M.get_filetype = function()
        -- local file_name, file_ext = fn.expand("%"), fn.expand("%:e")
        -- local icon = require("nvim-web-devicons").get_icon(file_name, file_ext, { default = true })
        local filetype = vim.bo.filetype

        if filetype == "" then return "" end
        return string.format(" %s ", filetype):lower()
    end

    M.get_line_col = function(self)
        if self:is_truncated(self.truncate_width.line_col) then return " %l:%c " end
        return " Ln %3l, Col %2c "
    end

    M.set_active = function(self)
        local colors = self.colors
        local mode = colors.mode .. self:get_current_mode()
        local mode_alt = colors.mode_alt .. self.separators[active_sep][1]
        local git = colors.git .. self:get_git_status()
        local git_alt = colors.git_alt .. self.separators[active_sep][1]
        local filename = colors.inactive .. self:get_filename()
        local filetype_alt = colors.filetype_alt .. self.separators[active_sep][2]
        local filetype = colors.filetype .. self:get_filetype()
        local line_col_alt = colors.line_col_alt .. self.separators[active_sep][2]
        local line_col = colors.line_col .. self:get_line_col()

        return table.concat({ colors.active, mode, mode_alt, git, git_alt, "%=", filename, "%=", filetype_alt, filetype,
            line_col_alt, line_col })
    end

    M.set_inactive = function(self) return self.colors.inactive .. "%= %F %=" end

    return M
end

Statusline = setmetatable(create_statusline_helpers(), {
    __call = function(statusline, mode)
        if mode == "active" then return statusline:set_active() end
        if mode == "inactive" then return statusline:set_inactive() end
    end
})

local group = vim.api.nvim_create_augroup("StatusLine", { clear = true })

vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" },
    { command = "setlocal statusline=%!v:lua.Statusline('active')", group = group }
)
vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave" },
    { command = "setlocal statusline=%!v:lua.Statusline('inactive')", group = group }
)


-- }}}

-- Colorscheme {{{

vim.cmd [[
   hi WinSeperator guibg=none
   hi def link LspReferenceText CursorLine
   hi def link LspReferenceWrite CursorLine
   hi def link LspReferenceRead CursorLine

   hi Normal guibg=none ctermbg=none
   hi EndOfBuffer guibg=none ctermbg=none

   hi SignAdd guifg=#98971a ctermfg=10
   hi SignDelete guifg=#cc241d ctermfg=9
   hi SignChange guifg=#458588 ctermfg=12
]]

-- local function custom_format(opts)
--     if vim.bo.filetype == "tmpl" then
--         -- TODO: write better formatter
--         local bufnr = vim.api.nvim_get_current_buffer()
--         local filename = vim.api.nvim_buf_get_name(bufnr)
--         local cmd = "templ fmt " .. vim.fn.shellescape(filename)
--
--         vim.fn.jobstart(cmd, {
--             on_exit = function()
--                 if vim.api.nvim_get_current_buffer() == bufnr then
--                     vim.cmd("e!")
--                 end
--             end,
--         })
--     else
--         vim.lsp.buf.format(opts)
--     end
-- end

vim.keymap.set(
    "n",
    "<leader>f",
    function()
        local buffer = vim.api.nvim_get_current_buf()
        require("conform").format({ bufnr = buffer, async = true })
    end,
    {
        remap = true,
        desc = "[general] try to format with conform or lsp",
    }
)


local hi_group = vim.api.nvim_create_augroup("YankHi", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost",
    { callback = function() vim.highlight.on_yank() end, group = hi_group, pattern = "*" }
)

local indentation = vim.api.nvim_create_augroup("Indentation", { clear = true })
vim.api.nvim_create_autocmd({ "BufRead", "BufEnter", "BufNewFile" },
    { group = indentation, pattern = "*.c,*.h,*.cpp", command = "setlocal expandtab tabstop=2 shiftwidth=2" }
)

vim.api.nvim_create_autocmd({ "BufRead", "BufEnter", "BufNewFile" },
    { group = indentation, pattern = "*.proto", command = "setlocal expandtab tabstop=2 shiftwidth=2" }
)

local customFiletypes = vim.api.nvim_create_augroup("CustomFiletypes", { clear = true })
-- vim.api.nvim_create_autocmd({ "BufRead", "BufEnter", "BufNewFile" },
--     {
--         group = customFiletypes,
--         pattern = "*.rego",
--         command = "setlocal filetype=rego expandtab shiftwidth=4 tabstop=4"
--     }
-- )

vim.api.nvim_create_autocmd({ "FileType" }, {
    group = customFiletypes,
    pattern = "help",
    command = "wincmd L",
})


-- }}}
