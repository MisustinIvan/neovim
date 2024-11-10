-- set the keymaps here, because of lazy loading(we want them to be always available)
-- the config function gets called only when the plugin is loaded, which is when
-- we press the keybind to open the terminal
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

-- remove some visual bullshit so that the terminal looks clean
local function set_term_visuals()
	vim.wo.number = false
	vim.wo.relativenumber = false
	vim.wo.cursorline = false
	vim.wo.wrap = false
end
vim.api.nvim_create_autocmd("TermEnter", { callback = set_term_visuals })

return {
	"akinsho/toggleterm.nvim",
	config = function()
		require("toggleterm").setup({
			shell = "powershell.exe",
			size = 8,
			shade_terminals = true,
			float_opts = {
				border = "rounded",
			},

			winbar = {
				enabled = false,
				name_formatter = function(term) --  term: Terminal
					return term.name
				end,
			},
		})

		vim.api.nvim_set_keymap(
			"n",
			"<leader>th",
			"<cmd>ToggleTerm direction=horizontal<cr>",
			{ noremap = true, silent = true }
		)
		vim.api.nvim_set_keymap(
			"n",
			"<leader>tf",
			"<cmd>ToggleTerm direction=float<cr>",
			{ noremap = true, silent = true }
		)
        local Terminal = require("toggleterm.terminal").Terminal
        local lazygit = Terminal:new({cmd = "lazygit", hidden = true, direction = "float"})

        function _lazygit_toggle()
            lazygit:toggle()
        end

        vim.api.nvim_set_keymap("n", "<leader>tg", "<cmd>lua _lazygit_toggle()<CR>", {noremap = true, silent = true})
	end,
}
