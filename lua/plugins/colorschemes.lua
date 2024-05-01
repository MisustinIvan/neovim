return {
	{
		"olimorris/onedarkpro.nvim",
		priority = 1000,
		init = function()
			vim.cmd("colorscheme onedark_vivid")
			--vim.cmd("colorscheme onedark_dark")
		end,
	},
	{
		"catppuccin/nvim",
	},
}
