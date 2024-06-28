return {
	"mfussenegger/nvim-dap",
	dependencies = {
		{
			"rcarriga/nvim-dap-ui",
			"nvim-neotest/nvim-nio",
			"leoluz/nvim-dap-go",
		},
	},
	config = function()
		require("dapui").setup()
		vim.api.nvim_set_keymap("n", "<leader>db", '<cmd>lua require("dapui").toggle()<cr>', {})

		require("dap-go").setup({
			dap_configurations = {
				{
					type = "go",
					name = "Attach",
					mode = "remote",
					request = "attach",
				},
			},
			-- delve configurations
			delve = {
				path = "dlv",
				initialize_timeout_sec = 20,
				-- a string that defines the port to start delve debugger.
				-- default to string "${port}" which instructs nvim-dap
				-- to start the process in a random available port
				port = "${port}",
				-- additional args to pass to dlv
				args = {},
				build_flags = "",
				detached = true,
				cwd = nil,
			},
		})
	end,
}
