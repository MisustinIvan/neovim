return {
	"folke/trouble.nvim",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},
	config = function()
		require("trouble").setup({})
	end,
	keys = {
		{ "<leader>ds", "<cmd>Trouble diagnostics<cr>", { desc = "Toggle diagnostics" } },
	},
}
