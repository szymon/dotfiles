local M = {}


function M.setup()
    local luasnip = require("luasnip")

    luasnip.setup({
        history = false,
        updateevents = "TextChanged,TextChangedI",
    })

    vim.keymap.set({ "i" }, "<c-l>", function() luasnip.expand_or_jump(1) end, { silent = true })
    vim.keymap.set({ "i" }, "<c-k>", function() luasnip.expand() end, { silent = true })
    -- vim.keymap.set({ "i", "s" }, "<c-l>", function() luasnip.jump(1) end, { silent = true })
    vim.keymap.set({ "i", "s" }, "<c-j>", function() luasnip.jump(-1) end, { silent = true })

    vim.keymap.set({ "i", "s" }, "<C-E>", function()
        if luasnip.choice_active() then
            luasnip.change_choice(1)
        end
    end, { silent = true })


    local ls = require "luasnip"

    local fmta = require("luasnip.extras.fmt").fmta
    local rep = require("luasnip.extras").rep

    local s = ls.snippet
    local c = ls.choice_node
    local d = ls.dynamic_node
    local i = ls.insert_node
    local f = ls.function_node
    local t = ls.text_node
    local sn = ls.snippet_node

    ls.add_snippets("lua", {
        s("ie", fmta("if <this> than <that> end <finish>",
            {
                this = i(1),
                that = i(2),
                finish = i(0),
            }))
    })
end

return M
