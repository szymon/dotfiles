return {
    {
        "ray-x/go.nvim",
        event = { "CmdlineEnter" },
        dev = true,
        ft = { "gomod" },
        opts = {},
        build = ":lua require('go.install').update_all_sync()",

    },

}
