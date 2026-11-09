-- the wikis register themselves when they are created
local wikis = require('config.wikis')

local Wiki = require('config.wiki')

local startup_group = vim.api.nvim_create_augroup('CustomStartup', { clear = true })
local homepage_ns = vim.api.nvim_create_namespace('homepage')
local cursor_ns = vim.api.nvim_create_namespace('homepage_cursor')

-- linked by default, so a colorscheme or the config can override any of them
for name, link in pairs({
	HomepageHeader = 'Title',
	HomepageDate = 'Comment',
	HomepageIcon = 'Function',
	HomepageLabel = 'Normal',
	HomepageFill = 'NonText',
	HomepageKey = 'Special',
	HomepageSection = 'Title',
	HomepageTodoIcon = 'DiagnosticWarn',
	HomepageTodo = 'Normal',
	HomepageTodoBold = '@markup.strong',
	HomepageNote = 'Comment',
	HomepageSelected = 'CursorLine',
	HomepageMarker = 'Special',
}) do
	vim.api.nvim_set_hl(0, name, { link = link, default = true })
end

local icon = {
	wiki = vim.fn.nr2char(0xf02d),   -- book
	files = vim.fn.nr2char(0xf07b),  -- folder
	config = vim.fn.nr2char(0xf013), -- cog
	quit = vim.fn.nr2char(0xf011),   -- power
	todo = vim.fn.nr2char(0xf0131),  -- empty checkbox
	marker = '▸',
}

---width of the menu and the todo list, the header is centered on its own
local BLOCK_WIDTH = 56

---three rows per letter, the figlet "future" font
local glyphs = {
	w = { '╻ ╻', '┃╻┃', '┗┻┛' },
	e = { '┏━╸', '┣╸ ', '┗━╸' },
	l = { '╻  ', '┃  ', '┗━╸' },
	c = { '┏━╸', '┃  ', '┗━╸' },
	o = { '┏━┓', '┃ ┃', '┗━┛' },
	m = { '┏┳┓', '┃┃┃', '╹ ╹' },
	b = { '┏┓ ', '┣┻┓', '┗━┛' },
	a = { '┏━┓', '┣━┫', '╹ ╹' },
	k = { '╻┏ ', '┣┻┓', '╹ ╹' },
	[' '] = { ' ', ' ', ' ' },
}

---@param word string
---@return string[]
local function banner(word)
	local rows = { {}, {}, {} }
	for char in word:gmatch('.') do
		for i = 1, 3 do
			table.insert(rows[i], glyphs[char][i])
		end
	end
	return vim.tbl_map(function(row) return table.concat(row, '') end, rows)
end

---@class homepage.action
---@field key string key opening it
---@field label string what it does
---@field icon string shown before the label
---@field run fun() the action itself

---the wikis come first, in the order they were created
---@return homepage.action[]
local function actions()
	local list = {}

	for _, wiki in ipairs(Wiki.registry) do
		if wiki.key then
			table.insert(list, {
				key = wiki.key,
				label = 'Open ' .. wiki.name,
				icon = icon.wiki,
				run = function() wiki:menu() end,
			})
		end
	end

	vim.list_extend(list, {
		{ key = 'f', label = 'Open file manager', icon = icon.files, run = function() vim.cmd.edit('.') end },
		{ key = 'c', label = 'Open config', icon = icon.config, run = function() vim.cmd.edit('~/.config/nvim/init.lua') end },
		{ key = 'q', label = 'Quit', icon = icon.quit, run = function() vim.cmd.quit() end },
	})

	return list
end

---a piece of a line and how it is highlighted
---@alias homepage.segment { [1]: string, [2]: string|nil }

local width = vim.fn.strdisplaywidth

---cut text down to at most max cells, marking the cut
---@param text string
---@param max integer
---@return string
local function truncate(text, max)
	if width(text) <= max then
		return text
	end
	local chars = vim.fn.strchars(text)
	while chars > 0 and width(vim.fn.strcharpart(text, 0, chars)) > max - 1 do
		chars = chars - 1
	end
	return vim.fn.strcharpart(text, 0, chars) .. '…'
end

---left and right segments, with the gap between them filled up to BLOCK_WIDTH
---@param left homepage.segment[]
---@param right homepage.segment[]
---@param fill string
---@return homepage.segment[]
local function spread(left, right, fill)
	local used = 0
	for _, seg in ipairs(vim.list_extend(vim.list_extend({}, left), right)) do
		used = used + width(seg[1])
	end
	local gap = math.max(1, BLOCK_WIDTH - used)
	local filler = gap > 2 and (' ' .. fill:rep(gap - 2) .. ' ') or (' '):rep(gap)

	local line = vim.list_extend({}, left)
	table.insert(line, { filler, 'HomepageFill' })
	return vim.list_extend(line, right)
end

---a todo's text as segments, **bold** parts highlighted without the markers,
---cut down to at most max cells
---@param text string
---@param max integer
---@return homepage.segment[]
local function todo_segments(text, max)
	local segments = {}
	local bold = false
	local left = max
	for part in (text .. '**'):gmatch('(.-)%*%*') do
		if part ~= '' and left > 0 then
			local cut = truncate(part, left)
			left = left - width(cut)
			if cut ~= part then
				left = 0
			end
			table.insert(segments, { cut, bold and 'HomepageTodoBold' or 'HomepageTodo' })
		end
		bold = not bold
	end
	return segments
end

---the diary's open todos, newest note first, in note order within one
---@return wiki.todo[]
local function sorted_todos()
	local todos = wikis.diary:todos()
	table.sort(todos, function(a, b)
		if a.path ~= b.path then
			return a.path > b.path
		end
		return a.lnum < b.lnum
	end)
	return todos
end

---@param buf integer
---@param win integer
---@param list homepage.action[]
---@param todos wiki.todo[]
---@return table<integer, wiki.todo> todo_at, integer|nil first, integer[] block
local function render(buf, win, list, todos)
	---@type homepage.segment[][]
	local rows = {}
	local function add(segments) table.insert(rows, segments) end

	local hour = tonumber(os.date('%H'))
	local greeting = hour < 5 and 'good night' or hour < 12 and 'good morning'
		or hour < 18 and 'good afternoon' or 'good evening'

	for _, row in ipairs(banner('welcome back')) do
		add({ { row, 'HomepageHeader' } })
	end
	add({})
	add({ { ('%s · %s'):format(greeting, os.date('%A %-d %B')), 'HomepageDate' } })
	add({})
	add({})

	---rows that span the block and get its left edge, not their own centering
	local in_block = {}

	for _, action in ipairs(list) do
		add(spread(
			{ { action.icon, 'HomepageIcon' }, { '  ' .. action.label, 'HomepageLabel' } },
			{ { action.key, 'HomepageKey' } },
			'·'))
		in_block[#rows] = true
	end

	---@type table<integer, integer>
	local todo_row = {}

	if #todos > 0 then
		add({})
		add({})
		add(spread({ { ('Open todos (%d)'):format(#todos), 'HomepageSection' } }, {}, '─'))
		in_block[#rows] = true
		add({})

		for i, todo in ipairs(todos) do
			local note = vim.fn.fnamemodify(todo.path, ':t:r')
			local room = BLOCK_WIDTH - width(icon.todo) - 2 - width(note) - 2
			local left = { { icon.todo, 'HomepageTodoIcon' }, { '  ' } }
			vim.list_extend(left, todo_segments(todo.text, room))
			add(spread(left, { { note, 'HomepageNote' } }, ' '))
			in_block[#rows] = true
			todo_row[#rows] = i
		end
	end

	local win_width = vim.api.nvim_win_get_width(win)
	local top = math.max(0, math.floor((vim.api.nvim_win_get_height(win) - #rows) / 2))
	local block_pad = math.max(0, math.floor((win_width - BLOCK_WIDTH) / 2))

	local lines = {}
	for _ = 1, top do
		table.insert(lines, '')
	end

	---@type { [1]: integer, [2]: integer, [3]: integer, [4]: string }[]
	local marks = {}
	local todo_at = {}

	for r, segments in ipairs(rows) do
		local text_width = 0
		for _, seg in ipairs(segments) do
			text_width = text_width + width(seg[1])
		end
		local pad = in_block[r] and block_pad or math.max(0, math.floor((win_width - text_width) / 2))

		local line = #segments > 0 and (' '):rep(pad) or ''
		for _, seg in ipairs(segments) do
			if seg[2] then
				table.insert(marks, { #lines, #line, #line + #seg[1], seg[2] })
			end
			line = line .. seg[1]
		end
		table.insert(lines, line)

		if todo_row[r] then
			todo_at[#lines] = todos[todo_row[r]]
		end
	end

	vim.bo[buf].modifiable = true
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.bo[buf].modifiable = false

	vim.api.nvim_buf_clear_namespace(buf, homepage_ns, 0, -1)
	for _, mark in ipairs(marks) do
		vim.api.nvim_buf_set_extmark(buf, homepage_ns, mark[1], mark[2], {
			end_col = mark[3],
			hl_group = mark[4],
		})
	end

	local first = nil
	for lnum in pairs(todo_at) do
		first = first and math.min(first, lnum) or lnum
	end

	return todo_at, first, { block_pad, block_pad + BLOCK_WIDTH }
end

vim.api.nvim_create_autocmd('VimEnter', {
	group = startup_group,
	nested = true,
	callback = function()
		if vim.fn.argc() > 0 then
			return
		end

		local buf = vim.api.nvim_create_buf(false, true)

		vim.bo[buf].buftype = 'nofile'
		vim.bo[buf].bufhidden = 'wipe'
		vim.bo[buf].swapfile = false
		vim.bo[buf].modifiable = false
		vim.bo[buf].filetype = 'startup'

		vim.api.nvim_win_set_buf(0, buf)
		local win = vim.api.nvim_get_current_win()

		-- local to the homepage, the next buffer in the window gets the usual ones
		local wo = vim.wo[win][0]
		wo.number = false
		wo.relativenumber = false
		wo.cursorline = false
		wo.list = false
		wo.colorcolumn = ''
		wo.signcolumn = 'no'
		wo.foldcolumn = '0'
		wo.statuscolumn = ''
		wo.fillchars = 'eob: '

		local list = actions()
		local todos = sorted_todos()
		local todo_at, first, block = render(buf, win, list, todos)

		---the column the todo text starts at, right after its icon
		local function text_col(_)
			return block[1] + #icon.todo + 2
		end

		---marks the todo under the cursor, the one <cr> opens
		local function highlight_selected()
			vim.api.nvim_buf_clear_namespace(buf, cursor_ns, 0, -1)
			local lnum = vim.api.nvim_win_get_cursor(0)[1]
			if not todo_at[lnum] then
				return
			end
			local line = vim.api.nvim_buf_get_lines(buf, lnum - 1, lnum, false)[1]
			vim.api.nvim_buf_set_extmark(buf, cursor_ns, lnum - 1, block[1], {
				end_col = #line,
				hl_group = 'HomepageSelected',
				priority = 50,
			})
			if block[1] >= 2 then
				vim.api.nvim_buf_set_extmark(buf, cursor_ns, lnum - 1, block[1] - 2, {
					virt_text = { { icon.marker, 'HomepageMarker' } },
					virt_text_pos = 'overlay',
				})
			end
		end

		if first then
			vim.api.nvim_win_set_cursor(win, { first, text_col(first) })
		end
		highlight_selected()

		vim.api.nvim_create_autocmd('CursorMoved', {
			group = startup_group,
			buffer = buf,
			callback = highlight_selected,
		})

		-- keep it centered, and the cursor on the same todo
		vim.api.nvim_create_autocmd({ 'VimResized', 'WinResized' }, {
			group = startup_group,
			callback = function()
				if not vim.api.nvim_buf_is_valid(buf) then
					return true
				end
				local shown = vim.fn.win_findbuf(buf)[1]
				if not shown then
					return
				end
				local selected = todo_at[vim.api.nvim_win_get_cursor(shown)[1]]
				todo_at, first, block = render(buf, shown, list, todos)
				for lnum, todo in pairs(todo_at) do
					if todo == selected then
						vim.api.nvim_win_set_cursor(shown, { lnum, text_col(lnum) })
					end
				end
				vim.api.nvim_win_call(shown, highlight_selected)
			end,
		})

		local map_opts = { silent = true, buffer = buf }

		for _, action in ipairs(list) do
			vim.keymap.set('n', action.key, action.run, map_opts)
		end

		vim.keymap.set('n', '<cr>', function()
			local todo = todo_at[vim.api.nvim_win_get_cursor(0)[1]]
			if todo then
				vim.cmd.edit(vim.fn.fnameescape(todo.path))
				vim.api.nvim_win_set_cursor(0, { todo.lnum, 0 })
			end
		end, map_opts)
	end,
})
