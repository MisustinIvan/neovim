return {
	"CRAG666/code_runner.nvim",
	config = function()
		require("code_runner").setup({
			mode = "float",
			filetype = {
				python = "python3",
				go = "go run .",
				rust = "cargo run",
				c = "make build run",
				haskell = "ghc main.hs && ./main",
                elixir = "mix run",
                odin = "odin run ."
			},
			float = {
				border = "rounded",
			},
		})
	end,
	keys = {
		{ "<leader>rr", '<cmd>lua require("code_runner").run_code()<cr>', desc = "Run code" },
	},
}
