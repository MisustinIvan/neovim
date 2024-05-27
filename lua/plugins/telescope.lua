return {
	"nvim-telescope/telescope.nvim",
	config = function()
		require("telescope").setup({})
	end,
	keys = {
		{ "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find file" },
		{ "<leader>gl", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
		{ "<leader>gr", "<cmd>Telescope lsp_references<cr>", desc = "Show references" },
		{ "<leader>gs", "<cmd>Telescope lsp_document_symbols<cr>", desc = "Show symbols" },
		{ "<leader>gh", "<cmd>Telescope help_tags<cr>", desc = "Search help" },
		{ "<leader>tc", "<cmd>Telescope colorscheme<cr>", desc = "Choose colorscheme" },
		{ "<leader>tb", "<cmd>Telescope buffers<cr>", desc = "Show all buffers" },
	},
}
