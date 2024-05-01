return {
	"nvim-tree/nvim-tree.lua",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},
	config = function()
		require("nvim-tree").setup({
			view = {
				width = 24,
			},
			renderer = {
				indent_markers = {
					enable = true,
					inline_arrows = true,
					icons = {
						corner = "└",
						edge = "│",
						item = "│",
						bottom = "─",
						none = " ",
					},
				},
			},
			filters = {
				dotfiles = true,
			},
		})
	end,
	keys = {
		{
			"<leader>fl",
			'<cmd>lua require("nvim-tree.api").tree.toggle({focus = true})<cr>',
			desc = "Toggle focus file tree",
		},
		{
			"<leader>fL",
			'<cmd>lua require("nvim-tree.api").tree.toggle({focus = false})<cr>',
			desc = "Toggle file tree",
		},
	},
}
