return {
	"ThePrimeagen/vim-apm",
	config = function()
		require("vim-apm"):setup({})
	end,
	keys = {
		{
			"<leader>pmt",
			function()
				require("vim-apm"):toggle_monitor()
			end,
			desc = "Toggle vim apm",
		},
	},
}
