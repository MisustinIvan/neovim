-- bootstrap lazy
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require("config.settings")
require("config.keybinds")
require("config.latex")

require("lazy").setup({
	defaults = {
		lazy = true,
	},
	--require("plugins.express_line"),
	--require("plugins.which_key"),

	require("plugins.treesitter"),
	require("plugins.autopairs"),
	require("plugins.colorschemes"),
	--require("plugins.nvim_tree"),
	require("plugins.telescope"),
	require("plugins.lualine"),
	--require("plugins.harpoon"),
	require("plugins.code_runner"),
	require("plugins.nvim_highlight_colors"),
	require("plugins.lsp"),
	require("plugins.trouble"),
	require("plugins.conform"),
	require("plugins.toggleterm"),
	--require("plugins.apm"),

	--require("plugins.nwm"),

	require("plugins.gitsigns"),
	require("plugins.colorsync"),
	--require("plugins.music_info"),

	--require("plugins.markview"),

	--require("plugins.dap"),
	require("plugins.dbee"),
	--require("plugins.neorg"),
	require("plugins.oil"),
	require("plugins.zen_mode"),
})
