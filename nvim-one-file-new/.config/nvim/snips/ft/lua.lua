-- require("luasnip.session.snippet_collection").clear_snippets "lua"

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

return {
    s("ie", fmta("if <this> than <that> end <finish>",
        {
            this = i(1),
            that = i(2),
            finish = i(0),
        }))
}
