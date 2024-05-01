return {
	"folke/trouble.nvim",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},
	config = function()
		require("trouble").setup({})
	end,
	keys = {
		{ "<leader>ds", "<cmd>TroubleToggle<cr>", { desc = "Toggle trouble" } },
	},
}
