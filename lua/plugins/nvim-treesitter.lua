vim.pack.add({
	{
		src = 'https://github.com/nvim-treesitter/nvim-treesitter',
		version = 'main',
	},
})

local ts = require("nvim-treesitter")
ts.setup({
	install_dir = vim.fn.stdpath("data") .. "/site"
})

local filetypes = { 'go', 'lua', 'html', 'javascript', 'css', 'csv', 'tsv', 'sql' }
local installed = require("nvim-treesitter.config").get_installed()

local to_install = vim.iter(filetypes):filter(function(lang)
	return not vim.tbl_contains(installed, lang)
end):totable()

if #to_install > 0 then
	ts.install(to_install)
end

vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("ts_core_setup", { clear = true }),
	callback = function(ev)
		pcall(vim.treesitter.start, ev.buf)

		vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
	end,
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
