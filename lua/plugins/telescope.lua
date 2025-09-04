vim.pack.add({
	'https://github.com/nvim-tree/nvim-web-devicons',
	'https://github.com/BurntSushi/ripgrep',
	'https://github.com/nvim-lua/plenary.nvim',
	'https://github.com/nvim-telescope/telescope.nvim'
})

require('nvim-web-devicons').setup()
require('telescope').setup()

vim.keymap.set('n', '<leader>ff', '<cmd>Telescope find_files<cr>', { desc = 'find files', silent = true})
vim.keymap.set('n', '<leader>gl', '<cmd>Telescope live_grep<cr>', { desc = 'live grep', silent = true})
vim.keymap.set('n', '<leader>gr', '<cmd>Telescope lsp_references<cr>', { desc = 'show symbol references', silent = true})
vim.keymap.set('n', '<leader>gs', '<cmd>Telescope lsp_document_symbols<cr>', { desc = 'show document symbols', silent = true})
vim.keymap.set('n', '<leader>gh', '<cmd>Telescope help_tags<cr>', { desc = 'search neovim help', silent = true})
vim.keymap.set('n', '<leader>tc', '<cmd>Telescope colorscheme<cr>', { desc = 'select colorscheme', silent = true})
vim.keymap.set('n', '<leader>tb', '<cmd>Telescope buffers<cr>', { desc = 'show all buffers', silent = true})
