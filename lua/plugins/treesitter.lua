return {
	"nvim-treesitter/nvim-treesitter",
	config = function()
		require("nvim-treesitter.configs").setup({
			ensure_installed = { "c", "lua", "vim", "vimdoc", "query" },
			sync_install = true,
			highlight = true,
			auto_install = true,
			ignore_install = {},
		})
	end,
}
