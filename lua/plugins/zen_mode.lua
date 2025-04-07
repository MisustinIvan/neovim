return {
	"folke/zen-mode.nvim",
	config = function()
		vim.keymap.set("n", "<leader>zm", ":ZenMode<CR>", { desc = "Zen Mode" })
	end,
}
