return {
	{
		"olimorris/onedarkpro.nvim",
		priority = 1000,
		--init = function()
		--vim.cmd("colorscheme onedark_vivid")
		--vim.cmd("colorscheme onedark_dark")
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
		--init = function()
		--	vim.cmd("colorscheme kanagawa")
		--end,
	},
    -- Using lazy.nvim
    {
      'ribru17/bamboo.nvim',
      lazy = false,
      priority = 1000,
      config = function()
        --require('bamboo').setup {
        --  -- optional configuration here
        --}
        --require('bamboo').load()
      end,
    },
	{
		"0xstepit/flow.nvim",
		lazy = false,
		priority = 1000,
	},
	{
		"nyoom-engineering/oxocarbon.nvim",
		lazy = false,
		priority = 1000,
		--init = function()
		--	vim.cmd("colorscheme oxocarbon")
		--end
	},
	{
		"tiagovla/tokyodark.nvim",
		lazy = false,
		priority = 1000,
	},
	{
		"niyabits/calvera-dark.nvim",
		lazy = false,
		priority = 1000,
	},
}
