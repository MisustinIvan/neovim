local augroup = vim.api.nvim_create_augroup('UserConfig', {})

vim.api.nvim_create_autocmd('VimResized', {
	desc = 'auto resize splits when window is resized',
	group = augroup,
	callback = function()
		vim.cmd('wincmd =')
	end,
})

vim.api.nvim_create_autocmd('BufWritePost', {
	desc = 'compile latex on file save',
	group = augroup,
	pattern = '*.tex',
	callback = function()
		path = vim.api.nvim_buf_get_name(0)
		vim.cmd('silent !pdflatex ' .. path)
	end,
})

vim.api.nvim_create_autocmd('TermClose', {
	desc = 'auto close terminal when process exits',
	group = augroup,
	callback = function()
		if vim.v.event.status == 0 then
			vim.api.nvim_buf_delete(0, {})
		end
	end,
})

vim.api.nvim_create_autocmd('TextYankPost', {
	desc = 'highlight text after yank',
	group = augroup,
	callback = function()
		vim.highlight.on_yank()
	end,
})
