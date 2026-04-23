local luasnip = require("luasnip")
local snipcomp = {}

local function snippet2completion(snippet)
    return {
        word      = snippet.trigger,
        menu      = snippet.name,
        info      = vim.trim(table.concat(vim.tbl_flatten({ snippet.dscr or "", "", snippet:get_docstring() }), "\n")),
        dup       = true,
        user_data = "luasnip"
    }
end

local function snippetfilter(line_to_cursor, base)
    return function(s)
        return not s.hidden and vim.startswith(s.trigger, base) and s.show_condition(line_to_cursor)
    end
end


function snipcomp.complete(findstart, base)
    local line = vim.api.nvim_get_current_line()
    local col = vim.api.nvim_win_get_cursor(0)[2]
    local line_to_cursor = line:sub(1, col)

    if findstart == 1 then
        print(vim.fn.match(line_to_cursor, '\\k*$'))
        return vim.fn.match(line_to_cursor, '\\k*$')
    end

    print(findstart, base)

    local snippets = vim.list_extend(vim.list_slice(luasnip.get_snippets("all")), luasnip.get_snippets(vim.bo.filetype))
    snippets = vim.tbl_filter(snippetfilter(line_to_cursor, base), snippets)
    snippets = vim.tbl_map(snippet2completion, snippets)
    table.sort(snippets, function(s1, s2) return s1.word < s2.word end)
    return snippets
end

return setmetatable(snipcomp, {
    __call = function(_, ...) snipcomp.complete(...) end,
})
