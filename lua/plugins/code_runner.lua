return {
	"CRAG666/code_runner.nvim",
	config = function()
		require("code_runner").setup({
			mode = "float",
			filetype = {
				--python = "python3",
				go = "go run .",
				rust = "cargo run",
			},
		})
	end,
	keys = {
		{ "<leader>rr", '<cmd>lua require("code_runner").run_code()<cr>', desc = "Run code" },
	},
}
