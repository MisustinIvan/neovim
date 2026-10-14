-- to be able to run build scripts for example
vim.api.nvim_create_autocmd('PackChanged', {
	callback = function(ev)
		require('config.vim_pack').run_callbacks(ev)
	end,
})

require('plugins.nvim-web-devicons')

require('config.options')
require('config.keymaps')
require('config.autocmds')
require('config.statusline')
require('config.lsp')
require('config.wikis')
require('config.homepage')
require('config.cetz_ai').setup()

require('plugins.telescope')
require('plugins.oil')
require('plugins.nvim-treesitter')

require('plugins.gruber-darker')
require('plugins.kanagawa')
vim.cmd.colorscheme('gruber-darker')

require('plugins.mini-pairs')
require('plugins.nvim-highlight-colors')
require('plugins.gitsigns')
require('plugins.trouble')
require('plugins.render-markdown')
require('plugins.strudel')
require('plugins.rainbow_delimiters')
