local M = {}

function M.setup()
    require("gruvbox").setup({
        bold = false,
        italic = {
            comments = false,
            keywords = false,
            functions = false,
            strings = false,
            variables = false,
        },
    })

    vim.cmd [[ colorscheme gruvbox ]]

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
end

return M
