local icons = {
	diagnostics = {
		ERROR = '',
		WARN = '',
		HINT = '',
		INFO = '',
	},
	arrows = {
		right = '',
		left = '',
		up = '',
		down = '',
	},
	misc = {
		bug = '',
		git = '',
		search = '',
		vertical_bar = '│',
	},
}

vim.o.showmode = false

local colors = {
	bg      = '#282828',
	normal  = '#f43841',
	insert  = '#73d936',
	visual  = '#ffdd33',
	command = '#9e95c7',
	replace = '#95a99f',
	select  = '#96a6c8',
}

local function mode()
	-- these colors are taken from the gruber-darker color scheme
	local bg = colors.bg

	vim.api.nvim_set_hl(0, 'StatusLineNormal', { fg = colors.normal, bold = true })
	vim.api.nvim_set_hl(0, 'StatusLineInsert', { fg = colors.insert, bold = true })
	vim.api.nvim_set_hl(0, 'StatusLineVisual', { fg = colors.visual, bold = true })
	vim.api.nvim_set_hl(0, 'StatusLineCommand', { fg = colors.command, bold = true })
	vim.api.nvim_set_hl(0, 'StatusLineReplace', { fg = colors.replace, bold = true })
	vim.api.nvim_set_hl(0, 'StatusLineSelect', { fg = colors.select, bold = true })


	local mode_to_str = {
		['n'] = 'NORMAL',
		['no'] = 'OP-PENDING',
		['nov'] = 'OP-PENDING',
		['noV'] = 'OP-PENDING',
		['no\22'] = 'OP-PENDING',
		['niI'] = 'NORMAL',
		['niR'] = 'NORMAL',
		['niV'] = 'NORMAL',
		['nt'] = 'NORMAL-T',
		['ntT'] = 'NORMAL-T',
		['v'] = 'VISUAL',
		['vs'] = 'VISUAL',
		['V'] = 'V-LINE',
		['Vs'] = 'V-LINE',
		['\22'] = 'V-BLOCK',
		['\22s'] = 'V-BLOCK',
		['s'] = 'SELECT',
		['S'] = 'SELECT',
		['\19'] = 'SELECT',
		['i'] = 'INSERT',
		['ic'] = 'INSERT',
		['ix'] = 'INSERT',
		['R'] = 'REPLACE',
		['Rc'] = 'REPLACE',
		['Rx'] = 'REPLACE',
		['Rv'] = 'VIRT REPLACE',
		['Rvc'] = 'VIRT REPLACE',
		['Rvx'] = 'VIRT REPLACE',
		['c'] = 'COMMAND',
		['cv'] = 'VIM EX',
		['cvr'] = 'EX',
		['r'] = 'PROMPT',
		['rm'] = 'MORE',
		['r?'] = 'CONFIRM',
		['!'] = 'SHELL',
		['t'] = 'TERMINAL',
	}

	local mode_color = {
		-- normal modes
		n = 'StatusLineNormal',
		niI = 'StatusLineNormal',
		niR = 'StatusLineNormal',
		niV = 'StatusLineNormal',
		nt = 'StatusLineNormal',
		ntT = 'StatusLineNormal',

		-- operator pending variants
		no = 'StatusLineNormal',
		nov = 'StatusLineNormal',
		noV = 'StatusLineNormal',
		['no\22'] = 'StatusLineNormal',

		-- visual modes
		v = 'StatusLineVisual',
		vs = 'StatusLineVisual',
		V = 'StatusLineVisual',
		Vs = 'StatusLineVisual',
		['\22'] = 'StatusLineVisual',
		['\22s'] = 'StatusLineVisual',

		-- select modes
		s = 'StatusLineSelect',
		S = 'StatusLineSelect',
		['\19'] = 'StatusLineSelect',

		-- all sorts of insert modes
		i = 'StatusLineInsert',
		ic = 'StatusLineInsert',
		ix = 'StatusLineInsert',

		-- all sorts of replace modes
		R = 'StatusLineReplace',
		Rc = 'StatusLineReplace',
		Rx = 'StatusLineReplace',
		Rv = 'StatusLineReplace',
		Rvc = 'StatusLineReplace',
		Rvx = 'StatusLineReplace',

		-- command line(Ex mode)
		c = 'StatusLineCommand',
		cv = 'StatusLineCommand',
		cvr = 'StatusLineCommand',

		-- confirm
		r = 'StatusLineCommand',
		rm = 'StatusLineCommand',
		['r?'] = 'StatusLineCommand',

		-- shell
		['!'] = 'StatusLineNormal',

		-- terminal mode
		t = 'StatusLineNormal',
	}

	local m = vim.fn.mode()
	local mode_s = mode_to_str[m]
	if not mode_s then
		return 'UNKNOWN'
	end
	local hl = mode_color[m]
	if not hl then
		return mode_s
	end
	return '%#' .. hl .. '#' .. mode_s .. '%*'
end

local function filetype_icon()
	local ft = vim.bo.filetype
	local fn = vim.fn.expand('%:t')
	local icon, hl = require('nvim-web-devicons').get_icon(fn, ft)
	if icon and hl then
		return '%#' .. hl .. '#' .. icon .. '%*'
	else
		return ''
	end
end

local function lsp_status()
	local bufnr = vim.api.nvim_get_current_buf()
	local clients = vim.lsp.get_clients({ bufnr = bufnr })
	if #clients == 0 then
		return ''
	end
	local names = {}
	for _, c in ipairs(clients) do
		table.insert(names, c.name)
	end
	return '[' .. table.concat(names, ',') .. ']'
end

local function git_branch()
	return vim.b.gitsigns_head and ('[' .. vim.b.gitsigns_head .. ']') or ''
end

local function lsp_diagnostics()
	local bufnr = vim.api.nvim_get_current_buf()
	local diagnostics = vim.diagnostic.get(bufnr)

	local counts = { E = 0, W = 0, I = 0, H = 0 }
	for _, d in ipairs(diagnostics) do
		if d.severity == vim.diagnostic.severity.ERROR then
			counts.E = counts.E + 1
		elseif d.severity == vim.diagnostic.severity.WARN then
			counts.W = counts.W + 1
		elseif d.severity == vim.diagnostic.severity.INFO then
			counts.I = counts.I + 1
		elseif d.severity == vim.diagnostic.severity.HINT then
			counts.H = counts.H + 1
		end
	end

	local result = {}
	if counts.E > 0 then
		table.insert(result,
			'%#StatusLineNormal#' .. icons.diagnostics.ERROR .. ' ' .. counts.E .. '%* ')
	end
	if counts.W > 0 then
		table.insert(result,
			'%#StatusLineVisual#' .. icons.diagnostics.WARN .. ' ' .. counts.W .. '%* ')
	end
	if counts.I > 0 then
		table.insert(result,
			'%#StatusLineInsert#' .. icons.diagnostics.INFO .. ' ' .. counts.I .. '%* ')
	end
	if counts.H > 0 then
		table.insert(result,
			'%#StatusLineCommand#' .. icons.diagnostics.HINT .. ' ' .. counts.H .. '%* ')
	end

	return table.concat(result, ' ')
end

local function media_info()
	local handle = io.popen("playerctl metadata --format '{{title}} - {{artist}}' 2>/dev/null")
	if not handle then
		return ''
	end

	local title = handle:read('*a')
	handle:close()

	if not title or title == '' then
		return ''
	end

	-- trim whitespace and newlines
	title = title:gsub('^%s*(.-)%s*$', '%1')

	-- truncate long titles
	if #title > 40 then
		title = title:sub(1, 37) .. '...'
	end

	return string.format('%%#StatusLineNormal# %s%%*', title)
end

function _G.statusline()
	return table.concat({
		' ', mode(),                              -- mode
		' ', filetype_icon(),                     -- File icon
		' %f',                                    -- File path
		' %#StatusLineSelect#' .. git_branch() .. '%*', -- Git branch
		' %#StatusLineSelect#' .. '%m' .. '%*',   -- Modified flag [+]
		' %#StatusLineNormal#' .. '%r' .. '%*',   -- Readonly flag [RO]
		' %= ',                                   -- Right align
		' ' .. media_info(),                      -- Media info
		' ' .. lsp_diagnostics(),                 -- LSP diagnostics
		' %#StatusLineSelect#' .. lsp_status() .. '%*', -- LSP status
		' %#StatusLineReplace#' .. '%{&ff}' .. '%*', -- File format (unix/dos/mac)
		' %#StatusLineSelect#' .. '%p%%' .. '%*', -- Percentage through file
		' %#StatusLineVisual#' .. '%l:%c' .. '%* ', -- Line and column
	})
end

vim.o.statusline = '%!v:lua.statusline()'
