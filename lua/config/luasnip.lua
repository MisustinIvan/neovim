local ls = require("luasnip")

ls.snippets = {
	rust = {
		ls.parser.parse_snippet({
			trig = "resfn",
			name = "Wrap return type with Result",
			dscr = "Wrap the return type of the function with Result",
			wordTrig = false,
			regTrig = true,
			fn = function(args)
				return { ls.snippet({ ls.insert.n(1), "Result<", ls.insert.n(2), ", std::io::Error>" }) }
			end,
		}),
	},
}
