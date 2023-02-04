local function prequire(...)
    local status, lib = pcall(require, ...)
    if (status) then return lib end
    return nil
end
local ls = prequire('luasnip')
local cmp = prequire("cmp")
local s = ls.snippet
local ps = ls.parser.parse_snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node
local events = require("luasnip.util.events")
local ai = require("luasnip.nodes.absolute_indexer")
local l = require("luasnip.extras").lambda
local rep = require("luasnip.extras").rep
local p = require("luasnip.extras").partial
local m = require("luasnip.extras").match
local n = require("luasnip.extras").nonempty
local dl = require("luasnip.extras").dynamic_lambda
local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta
local types = require("luasnip.util.types")
-- local conds = require("luasnip.extras.conditions")

return {

    s("code-block",
    fmta(
    [[
⍝►
<code>
⍝◄
    ]],
    {
        code = i(1, "..."),
    })
    ),
}
