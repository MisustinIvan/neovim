vim.pack.add({
	{
		src = 'https://github.com/nvim-treesitter/nvim-treesitter',
		version = 'master',
	},
})

local filetypes = {
	'go',
	'lua',
	'html',
	'javascript',
	'css',
	'csv',
	'tsv',
	'sql',
}

require('nvim-treesitter.configs').setup({
	ensure_installed = filetypes,
	highlight = {
		enable = true,
	},
	indent = {
		enable = true,
	},
	auto_install = true,
})

vim.api.nvim_create_autocmd('PackChanged', {
	desc = 'update treesitter parsers',
	callback = function(event)
		if event.data.kind == 'update' then
			if event.data.spec.src == 'https://github.com/nvim-treesitter/nvim-treesitter' then
				vim.cmd("TSUpdate")
			end
		end
	end,
})
