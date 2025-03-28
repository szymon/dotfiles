return {
    {
        "ellisonleao/gruvbox.nvim",
        priority = 1000,
        config = function()
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
            vim.cmd("colorscheme gruvbox")
        end,
    },
}
