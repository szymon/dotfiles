return {
    {
        "harrisoncramer/gitlab.nvim",
        dependencies = {
            "MunifTanjim/nui.nvim",
            "nvim-lua/plenary.nvim",
            "sindrets/diffview.nvim",
        },
        build = function() require("gitlab.server").build(true) end, -- Builds the Go binary
        opts = {
            use_icons = false,
            auth_provider = function()
                return vim.env.GITLAB_TOKEN_NEOVIM, vim.env.GITLAB_URL, nil
            end,
        },
    },
}
