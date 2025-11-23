local ls = require("luasnip")
local snippet = ls.snippet
local sn = ls.snippet_node
local text = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local d = ls.dynamic_node
local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta
local rep = require("luasnip.extras").rep

local tex_utils = {}
tex_utils.in_mathzone = function()  -- math context detection
  return vim.fn['vimtex#syntax#in_mathzone']() == 1
end
tex_utils.in_text = function()
  return not tex_utils.in_mathzone()
end
tex_utils.in_comment = function()  -- comment detection
  return vim.fn['vimtex#syntax#in_comment']() == 1
end
tex_utils.in_env = function(name)  -- generic environment detection
    local is_inside = vim.fn['vimtex#env#is_inside'](name)
    return (is_inside[1] > 0 and is_inside[2] > 0)
end
-- A few concrete environments---adapt as needed
tex_utils.in_equation = function()  -- equation environment detection
    return tex_utils.in_env('equation')
end
tex_utils.in_itemize = function()  -- itemize environment detection
    return tex_utils.in_env('itemize')
end
tex_utils.in_tikz = function()  -- TikZ picture environment detection
    return tex_utils.in_env('tikzpicture')
end

local function auto_pair(open, close)
	auto_complete_snippet = snippet(
		{trig=open, snippetType="autosnippet", wordTrig=false},
		fmta(
			open .. "<>" .. close .. "<>",
			{i(1), i(0)}
		)
	)

	return auto_complete_snippet
end

return {	
	auto_pair("(", ")"),
	auto_pair("[", "]"),
	auto_pair("{", "}"),
	auto_pair('"', '"'),
-- Examples of Greek letter snippets, autotriggered for efficiency
	snippet({trig=";a", snippetType="autosnippet"},
  {
    text("\\alpha"),
  },
  {
    condition = tex_utils.in_mathzone,
  }
),
	snippet({trig=";b", snippetType="autosnippet"},
  {
    text("\\beta"),
  },
  {
    condition = tex_utils.in_mathzone,
  }

),
	snippet({trig=";g", snippetType="autosnippet"},
  {
    text("\\gamma"),
  },
  {
    condition = tex_utils.in_mathzone,
  }
),
	snippet({trig=";d", snippetType="autosnippet"},
  {
    text("\\partial"),
  },
  {
    condition = tex_utils.in_mathzone,
  }
),
	snippet({trig="oo", snippetType="autosnippet"},
  {
    text("\\infty"),
  },
  {
    condition = tex_utils.in_mathzone,
  }
),


	snippet({trig="\\beg", snippetType="autosnippet"},
  		fmta("\\begin{<>}\n    <>\n\\end{<>}",
    		{
				i(1),
      			i(2),
      			rep(1),  -- this node repeats insert node i(1)
    		}
  		)
	),
	snippet({trig="eq"},
  		fmta("\\[\n    <>\n\\]",
    		{
				i(1),
    		}
  		),
		{
			condition = tex_utils.in_text,
		}
	),
	snippet({trig="$", snippetType="autosnippet"},
  		fmta("\\(<>\\)<>",
    		{
				i(1),
				i(0),
    		}
  		),
		{
		}
	),
	snippet({trig="cal", snippetType="autosnippet"},
  		fmta("\\mathcal{<>}",
    		{
				i(1),
    		}
  		),
		{
			condition = tex_utils.in_mathzone,
		}
	),

	snippet({trig="::"},
  		fmta("{{c<>:: <> }}<>",
    		{
				i(1),
				i(2),
				i(3),
    		}
  		),
		{
			condition = tex_utils.in_text,
		}
	),
		snippet(
		{trig="abs", snippetType="autosnippet", wordTrig=false},
		fmta("\\lvert <> \\rvert ", {i(1)}),
		{
			condition = tex_utils.in_mathzone,
		}

	),

	snippet({trig="<>", snippetType="autosnippet"},
  		fmta("\\langle <> \\rangle <>",
    		{
				i(1),
				i(0),
    		}
  		),
		{
			condition = tex_utils.in_mathzone,
		}
	),
	snippet({trig="fra", snippetType="autosnippet"},
  		fmta("\\frac{<>}{<>}",
    		{
				i(1),
				i(2),
    		}
  		),
		{
			condition = tex_utils.in_mathzone,
		}
	),
	snippet({trig="set"},
  		fmta("\\{ <> \\}",
    		{
				i(1),
    		}
  		),
		{
			condition = tex_utils.in_mathzone,
		}
	),
	snippet({trig="norm", snippetType="autosnippet"},
  		fmta("\\lVert <> \\rVert",
    		{
				i(1),
    		}
  		),
		{
			condition = tex_utils.in_mathzone,
		}
	),
	snippet({trig=";Z", snippetType="autosnippet"},
  		text("\\mathbb{Z}"),
		{
			condition = tex_utils.in_mathzone,
		}
	),	

	snippet({trig=";R", snippetType="autosnippet"},
  		text("\\mathbb{R}"),
		{
			condition = tex_utils.in_mathzone,
		}
	),	
	snippet({trig=";Q", snippetType="autosnippet"},
  		text("\\mathbb{Q}"),
		{
			condition = tex_utils.in_mathzone,
		}
	),	

	snippet({trig=";N", snippetType="autosnippet"},
  		text("\\mathbb{N}"),
		{
			condition = tex_utils.in_mathzone,
		}
	),	

	snippet({trig=";L", snippetType="autosnippet"},
  		text("\\mathcal{L}"),
		{
			condition = tex_utils.in_mathzone,
		}
	),	

	snippet({trig=";E", snippetType="autosnippet"},
  		text("\\mathbb{E}"),
		{
			condition = tex_utils.in_mathzone,
		}
	),
	snippet({trig=";cE", snippetType="autosnippet"},
  		fmta("\\mathbb{E}(<> | <>)", {i(1), i(2)}),
		{
			condition = tex_utils.in_mathzone,
		}
	),


	snippet({trig=";P", snippetType="autosnippet"},
  		text("\\mathbb{P}"),
		{
			condition = tex_utils.in_mathzone,
		}
	),


	snippet({trig=";C", snippetType="autosnippet"},
  		text("\\mathbb{C}"),
		{
			condition = tex_utils.in_mathzone,
		}
	),
	snippet({trig="in", snippetType="autosnippet"},
  		text("\\in"),
		{
			condition = tex_utils.in_mathzone,
		}
	),
	snippet({trig="->", snippetType="autosnippet"},
  		text("\\rightarrow"),
		{
			condition = tex_utils.in_mathzone,
		}
	),
	snippet({trig="''", snippetType="autosnippet"},
  		fmta("\\text{<>}", i(1)),
		{
			condition = tex_utils.in_mathzone,
		}
	),
}

