-- This clears my go snippets, so when I source this file
-- I can try the snippets again, without restarting neovim.
--
-- This is pretty useful if you're trying to do something a bit
-- more complicated or just exploring random snippet ideas
require("luasnip.session.snippet_collection").clear_snippets "go"

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

-- Map of default values for types.
--  Some have a bit more complicated default values,
--  but that's OK :) Lua is flexible enough!
local default_values = {
    int = "0",
    bool = "false",
    string = '""',

    error = function(_, info)
        if info then
            info.index = info.index + 1

            return c(info.index, {
                t(info.err_name),
                t(string.format('errors.Wrap(%s, "%s")', info.err_name, info.func_name)),
            })
        else
            return t "err"
        end
    end,

    -- Types with a "*" mean they are pointers, so return nil
    [function(text)
        return string.find(text, "*", 1, true) ~= nil or text == "interface{}" or text == "any"
    end] = function(_, _)
        return t("nil")
    end,

    -- Convention: Usually no "*" and Capital is a struct type, so give the option
    -- to have it be with {} as well.
    [function(text)
        return not string.find(text, "*", 1, true) and string.upper(string.sub(text, 1, 1)) == string.sub(text, 1, 1)
    end] = function(text, info)
        info.index = info.index + 1

        return c(info.index, {
            t(text .. "{}"),
            t(text),
        })
    end,
}

--- Transforms some text into a snippet node
---@param text string
---@param info table
local transform = function(text, info)
    --- Determines whether the key matches the condition
    local condition_matches = function(condition, ...)
        if type(condition) == "string" then
            return condition == text
        else
            return condition(...)
        end
    end

    -- Find the matching condition to get the correct default value
    for condition, result in pairs(default_values) do
        if condition_matches(condition, text, info) then
            if type(result) == "string" then
                return t(result)
            else
                return result(text, info)
            end
        end
    end

    -- If no matches are found, just return the text, can fix up easily
    return t(text)
end

-- Maps a node type to a handler function.
local handlers = {
    parameter_list = function(node, info)
        local result = {}

        local count = node:named_child_count()
        for idx = 0, count - 1 do
            local matching_node = node:named_child(idx)
            local type_node = matching_node:field("type")[1]
            table.insert(result, transform(vim.treesitter.get_node_text(type_node, 0), info))
            if idx ~= count - 1 then
                table.insert(result, t { ", " })
            end
        end

        return result
    end,

    type_identifier = function(node, info)
        local text = vim.treesitter.get_node_text(node, 0)
        return { transform(text, info) }
    end,
}

--- Gets the corresponding result type based on the
--- current function context of the cursor.
---@param info table
local function go_result_type(info)
    local function_node_types = {
        function_declaration = true,
        method_declaration = true,
        func_literal = true,
    }

    -- Find the first function node that's a parent of the cursor
    local node = vim.treesitter.get_node()
    while node ~= nil do
        if function_node_types[node:type()] then
            break
        end

        node = node:parent()
    end

    -- Exit if no match
    if not node then
        vim.notify "Not inside of a function"
        return t("")
    end

    -- This file is in `queries/go/return-snippet.scm`
    local query = assert(vim.treesitter.query.get("go", "return-snippet"), "No query")
    for _, capture in query:iter_captures(node, 0) do
        if handlers[capture:type()] then
            return handlers[capture:type()](capture, info)
        end
    end

    return t("")
end

local go_return_values = function(args)
    if #args == 0 then
        args = { { nil }, { nil } }
    end

    return sn(
        nil,
        go_result_type({
            index = 0,
            err_name = args[1][1],
            func_name = args[2][1],
        })
    )
end

local function filename_to_pascal_case(filename)
    -- Remove the file extension
    local name_without_extension = filename:match("^(.*)%_test.") or filename

    -- Convert to PascalCase
    local pascal_case = name_without_extension:gsub("(%a)([%w]*)", function(first, rest)
        return first:upper() .. rest:lower()
    end):gsub("[^%w]", "") -- Remove non-alphanumeric characters

    return pascal_case
end

local function execute_lsp_code_action_on_string(input_string, language_server_name)
    -- Create a temporary buffer
    local buf = vim.api.nvim_create_buf(false, true) -- Create an unlisted, scratch buffer

    -- Set the content of the buffer to the input string
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(input_string, "\n"))

    -- Determine the filetype (optional, for LSP compatibility)
    vim.api.nvim_buf_set_option(buf, "filetype", "plaintext") -- Change to your desired filetype

    -- Attach the LSP client to the buffer
    local clients = vim.lsp.get_active_clients()
    local client = nil
    for _, c in ipairs(clients) do
        if c.name == language_server_name then
            client = c
            break
        end
    end

    if not client then
        print("LSP client not found: " .. language_server_name)
        return
    end

    client.config.flags.allow_incremental_sync = true
    vim.lsp.buf_attach_client(buf, client.id)

    -- Request code actions
    vim.lsp.buf_request(buf, "textDocument/codeAction", {
        textDocument = { uri = vim.uri_from_bufnr(buf) },
        range = {
            start = { line = 0, character = 0 },
            ["end"] = { line = #vim.api.nvim_buf_get_lines(buf, 0, -1, false), character = 0 },
        },
        context = { diagnostics = {}, only = nil },
    }, function(err, result, ctx)
        if err then
            print("Error requesting code action: " .. err.message)
            return
        end

        if not result or vim.tbl_isempty(result) then
            print("No code actions available")
            return
        end

        -- Apply the first code action (customize as needed)
        local action = result[1]
        if action.edit then
            vim.lsp.util.apply_workspace_edit(action.edit, 'utf-8')
        elseif action.command then
            vim.lsp.buf.execute_command(action.command)
        end

        -- Retrieve the modified content
        local modified_content = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n")

        -- Clean up the buffer
        vim.api.nvim_buf_delete(buf, { force = true })
        return modified_content
    end)
end




ls.add_snippets("go", {
    s(
        "efi",
        fmta(
            [[
<val>, <err> := <f>(<args>)
if <err_same> != nil {
	return <result>
}
<finish>
]],
            {
                val = i(1),
                err = i(2, "err"),
                f = i(3),
                args = i(4),
                err_same = rep(2),
                result = d(5, go_return_values, { 2, 3 }),
                finish = i(0),
            }
        )
    ),
    s("ie", fmta([[
if err != nil {
	<choice>
}
<finish>
]], {
        choice = i(1),
        finish = i(0),
    }
    )),
    s("iep", fmta("if err != nil {\n\tpanic(err)\n}<finish>", { finish = i(0) })),
    s("simpleDynamicKubernetesTest",
        fmta([[
package activities_test

import (
	workerv1 "github.com/cloudferro/mk8s/gen/worker/v1"
	"github.com/cloudferro/mk8s/pkg/activities"
	. "github.com/onsi/ginkgo/v2"
	. "github.com/onsi/gomega"
	"go.temporal.io/sdk/testsuite"
	"k8s.io/apimachinery/pkg/runtime"
	"k8s.io/client-go/dynamic"
	"k8s.io/client-go/dynamic/fake"
)

var _ = Describe("<describe>", Ordered, func() {
	var env *testsuite.TestActivityEnvironment
	var acts *activities.Activities
	var cli *fake.FakeDynamicClient
	BeforeAll(func() {
		scheme := runtime.NewScheme()
		cli = fake.NewSimpleDynamicClient(scheme)

		acts = &activities.Activities{
			Logger: logger,
			CreateKubernetesDynamicClient: func(kubeconfig []byte) (dynamic.Interface, error) {
				return cli, nil
			},
		}

		env = suite.NewTestActivityEnvironment()
		env.RegisterActivity(acts)
	})

	It("completes", func(c SpecContext) {
		resp, err := env.ExecuteActivity("<activity>",
			&workerv1.<activityInput>Input{
                <finish>
			},
		)
		Expect(err).ShouldNot(HaveOccurred())
		Expect(resp.HasValue()).To(BeTrue())
        result := workerv1.<activityOutput>Output{}
        Expect(resp.Get(&result)).ShouldNot(HaveOccurred())
	})
})
]], {
            describe = f(function()
                return vim.fn.expand("%:t")
            end),
            activity = f(function()
                local filename = vim.fn.expand("%:t")
                return filename_to_pascal_case(filename)
            end),
            activityInput = f(function()
                local filename = vim.fn.expand("%:t")
                return filename_to_pascal_case(filename)
            end),
            activityOutput = f(function()
                local filename = vim.fn.expand("%:t")
                return filename_to_pascal_case(filename)
            end),
            finish = i(0),

        })),
    s("simpleOpenstackTest",
        fmta([[
package activities_test

import (
	"context"

	workerv1 "github.com/cloudferro/mk8s/gen/worker/v1"
	"github.com/cloudferro/mk8s/pkg/activities"
	openstackapi "github.com/cloudferro/mk8s/pkg/clients/openstack"
	"github.com/cloudferro/mk8s/pkg/clients/openstack/openstackmock"
	. "github.com/onsi/ginkgo/v2"
	. "github.com/onsi/gomega"
	"go.temporal.io/sdk/testsuite"
	"go.uber.org/mock/gomock"
)

var _ = Describe("<describe>", Ordered, func() {
	var env *testsuite.TestActivityEnvironment
	var acts *activities.Activities
	var cli *openstackmock.MockClient
	BeforeAll(func() {
		mockctrl := gomock.NewController(GinkgoT())

		cli = openstackmock.NewMockClient(mockctrl)

		env = suite.NewTestActivityEnvironment()

		acts = &activities.Activities{
			Logger: logger,
			CreateOpenStackClient: func(ctx context.Context, url string, region string, opts ...openstackapi.ClientOptionFn) (openstackapi.Client, error) {
				return cli, nil
			},
		}

		env.RegisterActivity(acts)
	})

	It("completes", func(c SpecContext) {
		cli.EXPECT().<command>(
			gomock.Any(),
			func() any { panic("unimplemented") }(),
			func() any { panic("unimplemented") }(),
			func() any { panic("unimplemented") }(),
		).Return(nil).Times(1)

		resp, err := env.ExecuteActivity("<activity>",
			&workerv1.<activityInput>Input{
                <finish>
            })
		Expect(err).ShouldNot(HaveOccurred())
		Expect(resp.HasValue()).To(BeTrue())
        result := workerv1.<activityOutput>Output{}
        Expect(resp.Get(&result)).ShouldNot(HaveOccurred())
	})
})

]], {
            describe = f(function()
                return vim.fn.expand("%:t")
            end),
            command = i(1),
            activity = f(function()
                local filename = vim.fn.expand("%:t")
                return filename_to_pascal_case(filename)
            end),
            activityInput = f(function()
                local filename = vim.fn.expand("%:t")
                return filename_to_pascal_case(filename)
            end),
            activityOutput = f(function()
                local filename = vim.fn.expand("%:t")
                return filename_to_pascal_case(filename)
            end),
            finish = i(0),

        })),
    s("simpleKubernetesTest",
        fmta([[
]], {
            describe = f(function()
                return vim.fn.expand("%:t")
            end),
            command = i(1),
            activity = f(function()
                local filename = vim.fn.expand("%:t")
                return filename_to_pascal_case(filename)
            end),
            activityInput = f(function()
                local filename = vim.fn.expand("%:t")
                return filename_to_pascal_case(filename)
            end),
            activityOutput = f(function()
                local filename = vim.fn.expand("%:t")
                return filename_to_pascal_case(filename)
            end),
            finish = i(0),

        })),
})

-- ls.add_snippets(
--   "go",
--   make {
--     main = {
--       t { "func main() {", "\t" },
--       i(0),
--       t { "", "}" },
--     },
--
--     ef = {
--       i(1, { "val" }),
--       t ", err := ",
--       i(2, { "f" }),
--       t "(",
--       i(3),
--       t ")",
--       i(0),
--     },
--
--     -- TODO: Fix this up so that it actually uses the tree sitter thing
--     ie = { "if err != nil {", "\treturn err", i(0), "}" },
--   }
-- )

-- ls.add_snippets("go", {
--   s("f", fmt("func {}({}) {} {{\n\t{}\n}}", { i(1, "name"), i(2), i(3), i(0) })),
-- })
