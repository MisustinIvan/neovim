vim.pack.add({ 'https://github.com/folke/trouble.nvim' })
require('trouble').setup()

vim.keymap.set('n', '<leader>ds', function()
	require('trouble').toggle('diagnostics')
end)
