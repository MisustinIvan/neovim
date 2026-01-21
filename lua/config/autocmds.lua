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
		local path = vim.api.nvim_buf_get_name(0)
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

vim.api.nvim_create_autocmd('BufWritePost', {
	desc = 'compile typst files on save',
	pattern = '*.typ',
	group = augroup,
	callback = function()
		local filename = vim.fn.expand('%:p')
		local command = "typst compile " .. filename .. " &"
		vim.fn.system(command)
	end
})

local handles = {}
local function start_process(command, args)
	local handle = vim.loop.spawn(command, {
		args = args,
	})
	table.insert(handles, handle)
end

vim.api.nvim_create_autocmd("VimLeavePre", {
	callback = function()
		for _, handle in pairs(handles) do
			if handle and not handle:is_closing() then
				handle:kill(15)
			end
		end
	end
})

vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufReadPre' }, {
	desc = 'Open Typst PDF file on buffer open',
	pattern = '*.typ',
	group = augroup,
	callback = function()
		local typ_filename = vim.fn.expand('%:p')
		local pdf_filename = typ_filename:gsub("%.typ$", ".pdf")

		vim.system({ "typst", "compile", typ_filename }, nil, function()
			start_process("zathura", { pdf_filename })
		end)
	end
})
