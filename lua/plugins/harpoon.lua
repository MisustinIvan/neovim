return {
	"ThePrimeagen/harpoon",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"MunifTanjim/nui.nvim",
	},
	config = function()
		vim.api.nvim_set_keymap(
			"n",
			"<leader>hf",
			'<cmd>lua require("harpoon.mark").add_file()<cr>',
			{ desc = "Harpoon a file" }
		)
		vim.api.nvim_set_keymap(
			"n",
			"<leader>ha",
			'<cmd>lua require("harpoon.ui").toggle_quick_menu()<cr>',
			{ desc = "Show all marks" }
		)
		vim.api.nvim_set_keymap(
			"n",
			"<leader>1",
			'<cmd>lua require("harpoon.ui").nav_file(1)<cr>',
			{ desc = "first file" }
		)
		vim.api.nvim_set_keymap(
			"n",
			"<leader>2",
			'<cmd>lua require("harpoon.ui").nav_file(2)<cr>',
			{ desc = "second file" }
		)
		vim.api.nvim_set_keymap(
			"n",
			"<leader>3",
			'<cmd>lua require("harpoon.ui").nav_file(3)<cr>',
			{ desc = "third file" }
		)
		vim.api.nvim_set_keymap(
			"n",
			"<leader>4",
			'<cmd>lua require("harpoon.ui").nav_file(4)<cr>',
			{ desc = "fourth file" }
		)
	end,
}
