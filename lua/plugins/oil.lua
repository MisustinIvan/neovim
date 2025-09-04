vim.pack.add({
	'https://github.com/stevearc/oil.nvim',
})

-- disable netrw as it is not needed
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

local oil = require('oil')

oil.setup({
	default_file_explorer = true,
})

vim.keymap.set('n', '<leader>fl', function()
	oil.open_float()
end, { noremap = true, silent = true })
