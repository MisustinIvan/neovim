return {
	{
		"olimorris/onedarkpro.nvim",
		priority = 1000,
		--init = function()
		--	vim.cmd("colorscheme onedark_vivid")
		--	--vim.cmd("colorscheme onedark_dark")
		--end,
	},
	{
		"catppuccin/nvim",
		priority = 1000,
		--init = function()
		--	vim.cmd("colorscheme catppuccin-frappe")
		--end,
	},
	{
		"blazkowolf/gruber-darker.nvim",
		priority = 1000,
		--init = function()
		--	vim.cmd("colorscheme gruber-darker")
		--end,
		opts = {
			bold = true,
			invert = {
				signs = true,
				tabline = true,
				visual = false,
			},
			italic = {
				strings = true,
				comments = true,
				operators = false,
				folds = true,
			},
			undercurl = true,
			underline = true,
		},
	},
	{
		"rebelot/kanagawa.nvim",
		priority = 1000,
		init = function()
			vim.cmd("colorscheme kanagawa")
		end,
	},
}
