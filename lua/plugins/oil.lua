return {
	"stevearc/oil.nvim",
	opts = {},
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		local oil = require("oil")
		oil.setup({
			default_file_explorer = true,
		})
		vim.keymap.set("n", "<leader>fl", function()
			oil.open_float()
		end, { noremap = true, silent = true })
	end,
}
