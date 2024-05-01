return {
	"akinsho/toggleterm.nvim",
	config = function()
		local function set_terminal_keymaps()
			local opts = { buffer = 0 }
			vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], opts)
			vim.keymap.set("t", "kl", [[<C-\><C-n>]], opts)
			vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd h<CR>]], opts)
			vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd j<CR>]], opts)
			vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd k<CR>]], opts)
			vim.keymap.set("t", "<C-;>", [[<Cmd>wincmd l<CR>]], opts)
		end

		vim.api.nvim_create_autocmd("TermEnter", { callback = set_terminal_keymaps })

		require("toggleterm").setup({
			shell = "fish",
			size = 8,
			shade_terminals = true,
			float_opts = {
				border = "single",
			},

			winbar = {
				enabled = false,
				name_formatter = function(term) --  term: Terminal
					return term.name
				end,
			},
		})
	end,

	keys = {
		{ "<leader>th", "<cmd>ToggleTerm<cr>" },
	},
}
