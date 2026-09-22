vim.pack.add({ 'https://github.com/gruvw/strudel.nvim' })

require('config.vim_pack').add_callback(function(event)
	print("PackChanged hook")

	local name, kind = event.data.spec.name, event.data.kind

	if name == 'strudel.nvim' and (kind == 'install' or kind == 'update') then
		vim.system({ 'npm', 'ci' }, { cwd = event.data.path })
	end
end
)

require('strudel').setup()

vim.filetype.add({
	extension = {
		str = 'javascript'
	}
})
