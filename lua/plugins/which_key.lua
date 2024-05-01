return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	init = function()
		vim.o.timeout = true
		vim.o.timeoutlen = 1000
	end,
	config = function()
		require("which-key").register({
			f = {
				name = "file",
			},
			h = {
				name = "harpoon",
			},
			w = {
				name = "window",
			},
		}, { prefix = "<leader>" })
	end,
	opts = {},
}
