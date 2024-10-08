return {
	"stevearc/conform.nvim",
	config = function()
		require("conform").setup({
			formatters_by_ft = {
				lua = { "stylua" },
				python = { "ruff" },
				go = { "gofmt" },
				rust = { "rustfmt" },
				html = { "prettier" },
				javascript = { "prettier" },
				json = { "prettier" },
                haskell = {"ormolu"},
			},
		})
	end,
	init = function()
		vim.api.nvim_create_autocmd("BufWritePre", {
			pattern = "*",
			callback = function(args)
				require("conform").format({ bufnr = args.buf })
			end,
		})
	end,
}
