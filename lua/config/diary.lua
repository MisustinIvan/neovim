---@class diary
---@field path string directory holding the entries
---@field file_format string strftime format for entry filenames, sorts chronologically
---@field entry_pattern string lua pattern matching a filename produced by file_format
---@field date_format string strftime format for the date written into an entry
---@field headings string[] second level headings inserted into a new entry
---@field buf_opts table<string, any> options applied to an entry buffer
local M = {
	path = vim.fn.expand('~/Documents/Diary'),
	file_format = '%Y-%m-%d',
	entry_pattern = '^%d%d%d%d%-%d%d%-%d%d%.md$',
	date_format = '%b %d %Y',
	headings = { 'TODO', 'Song of the day', 'Thoughts' },
	buf_opts = {
		wrap = true,
		linebreak = true,
		conceallevel = 2,
	},
}

---@param days integer offset from today in days
---@return integer
local function day_offset(days)
	local t = os.date('*t')
	t.day = t.day + days
	-- midday keeps a daylight saving shift from moving the date
	t.hour = 12
	return os.time(t)
end

---@return boolean ok
local function ensure_dir(path)
	if vim.fn.isdirectory(path) == 1 then
		return true
	end

	local ok, created = pcall(vim.fn.mkdir, path, 'p')
	if not ok or created == 0 then
		vim.notify('diary: cannot create ' .. path, vim.log.levels.ERROR)
		return false
	end

	return true
end

---@param buf integer
---@return boolean
local function buffer_is_empty(buf)
	if vim.api.nvim_buf_line_count(buf) ~= 1 then
		return false
	end
	return vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] == ''
end

---readable date, also used by the insert date keymap
---@param time integer|nil
---@return string
function M:date_string(time)
	return os.date(self.date_format, time or os.time())
end

---@param time integer|nil
---@return string
function M:entry_path(time)
	return self.path .. '/' .. os.date(self.file_format, time or os.time()) .. '.md'
end

---contents of a fresh entry
---@param time integer|nil
---@return string[]
function M:template(time)
	local lines = { '# ' .. self:date_string(time) }

	for _, heading in ipairs(self.headings) do
		vim.list_extend(lines, { '', '## ' .. heading, '' })
	end

	return lines
end

---every entry in the diary, oldest first
---@return string[]
function M:entries()
	if vim.fn.isdirectory(self.path) == 0 then
		return {}
	end

	local entries = vim.fn.readdir(self.path, function(name)
		return name:match(self.entry_pattern) and 1 or 0
	end)

	table.sort(entries)
	return entries
end

---@param days integer|nil offset from today in days
function M:open_entry(days)
	if not ensure_dir(self.path) then
		return
	end

	local time = day_offset(days or 0)

	vim.cmd.edit(vim.fn.fnameescape(self:entry_path(time)))

	local buf = vim.api.nvim_get_current_buf()

	if buffer_is_empty(buf) then
		local lines = self:template(time)
		vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
		vim.api.nvim_win_set_cursor(0, { #lines, 0 })
	end
end

---jump to the entry next to the current one
---@param step integer -1 for the previous entry, 1 for the next one
function M:open_adjacent(step)
	local entries = self:entries()
	if #entries == 0 then
		vim.notify('diary: no entries yet', vim.log.levels.WARN)
		return
	end

	local current = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ':t')
	local index = nil

	for i, name in ipairs(entries) do
		if name == current then
			index = i
			break
		end
	end

	-- outside the diary, step in from the end we are heading towards
	if not index then
		index = step < 0 and #entries + 1 or 0
	end

	local target = entries[index + step]
	if not target then
		vim.notify('diary: no further entry', vim.log.levels.WARN)
		return
	end

	vim.cmd.edit(vim.fn.fnameescape(self.path .. '/' .. target))
end

function M:open_list()
	if not ensure_dir(self.path) then
		return
	end
	vim.cmd.edit(vim.fn.fnameescape(self.path .. '/'))
end

function M:find_entry()
	require('telescope.builtin').find_files({ cwd = self.path, no_ignore = true })
end

function M:grep_entries()
	require('telescope.builtin').live_grep({ cwd = self.path })
end

---@param buf integer
---@return boolean
function M:owns_buffer(buf)
	local name = vim.fs.normalize(vim.api.nvim_buf_get_name(buf))
	local dir = vim.fs.normalize(self.path) .. '/'
	return name:sub(1, #dir) == dir
end

vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufWinEnter' }, {
	desc = 'prose friendly options in diary entries',
	group = vim.api.nvim_create_augroup('UserDiary', {}),
	-- the path is read on every event so M.path stays configurable
	pattern = '*.md',
	callback = function(event)
		if not M:owns_buffer(event.buf) then
			return
		end

		for name, value in pairs(M.buf_opts) do
			vim.opt_local[name] = value
		end
	end,
})

vim.api.nvim_create_user_command('DiaryToday', function(opts)
	M:open_entry(tonumber(opts.args))
end, { nargs = '?', desc = 'open the entry for today, or an offset in days' })

vim.api.nvim_create_user_command('DiaryList', function() M:open_list() end, { desc = 'browse the diary' })
vim.api.nvim_create_user_command('DiaryPrev', function() M:open_adjacent(-1) end, { desc = 'previous diary entry' })
vim.api.nvim_create_user_command('DiaryNext', function() M:open_adjacent(1) end, { desc = 'next diary entry' })
vim.api.nvim_create_user_command('DiaryFind', function() M:find_entry() end, { desc = 'find a diary entry' })
vim.api.nvim_create_user_command('DiaryGrep', function() M:grep_entries() end, { desc = 'grep the diary' })

---@class diary.action
---@field label string what the action does
---@field cmd string the command it stands for, shown in the menu
---@field run fun() the action itself

---entries of the menu, in the order they are listed and numbered
---@type diary.action[]
M.actions = {
	{ label = 'todays entry',     cmd = ':DiaryToday',    run = function() M:open_entry() end },
	{ label = 'yesterdays entry', cmd = ':DiaryToday -1', run = function() M:open_entry(-1) end },
	{ label = 'browse the diary', cmd = ':DiaryList',     run = function() M:open_list() end },
	{ label = 'previous entry',   cmd = ':DiaryPrev',     run = function() M:open_adjacent(-1) end },
	{ label = 'next entry',       cmd = ':DiaryNext',     run = function() M:open_adjacent(1) end },
	{ label = 'find an entry',    cmd = ':DiaryFind',     run = function() M:find_entry() end },
	{ label = 'grep the entries', cmd = ':DiaryGrep',     run = function() M:grep_entries() end },
}

local menu_ns = vim.api.nvim_create_namespace('diary_menu')

---@return string[] lines, integer cmd_column
local function menu_lines(actions)
	local width = 0
	for _, action in ipairs(actions) do
		width = math.max(width, #action.label)
	end

	local lines = {}
	for i, action in ipairs(actions) do
		lines[i] = (' %d  %-' .. width .. 's   %s'):format(i, action.label, action.cmd)
	end

	-- leading space, digit, two spaces, label, three spaces
	return lines, width + 7
end

---floating list of the diary commands, pick one by its number
function M:menu()
	local actions = self.actions
	if #actions == 0 then
		return
	end

	local lines, cmd_column = menu_lines(actions)

	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

	for i = 1, #lines do
		vim.api.nvim_buf_set_extmark(buf, menu_ns, i - 1, 1, {
			end_col = 2,
			hl_group = 'Number',
		})
		vim.api.nvim_buf_set_extmark(buf, menu_ns, i - 1, cmd_column, {
			end_col = #lines[i],
			hl_group = 'Comment',
		})
	end

	vim.bo[buf].modifiable = false
	vim.bo[buf].bufhidden = 'wipe'
	vim.bo[buf].filetype = 'diarymenu'

	local width = 0
	for _, line in ipairs(lines) do
		width = math.max(width, #line)
	end
	width = width + 2

	local height = #lines

	local win = vim.api.nvim_open_win(buf, true, {
		relative = 'editor',
		width = width,
		height = height,
		row = math.floor((vim.o.lines - height) / 2 - 1),
		col = math.floor((vim.o.columns - width) / 2),
		style = 'minimal',
		border = 'rounded',
		title = ' diary ',
		title_pos = 'center',
	})

	vim.wo[win].cursorline = true

	local function close()
		if vim.api.nvim_win_is_valid(win) then
			vim.api.nvim_win_close(win, true)
		end
	end

	---closes the menu first so the action lands in the window below it
	---@param action diary.action|nil
	local function pick(action)
		close()
		if action then
			action.run()
		end
	end

	local opts = { buffer = buf, nowait = true, silent = true }

	for i, action in ipairs(actions) do
		if i < 10 then
			vim.keymap.set('n', tostring(i), function() pick(action) end, opts)
		end
	end

	vim.keymap.set('n', '<cr>', function()
		pick(actions[vim.api.nvim_win_get_cursor(win)[1]])
	end, opts)

	for _, key in ipairs({ 'q', '<esc>', '<c-c>' }) do
		vim.keymap.set('n', key, close, opts)
	end

	vim.api.nvim_create_autocmd('BufLeave', {
		desc = 'close the diary menu when it loses focus',
		buffer = buf,
		once = true,
		callback = close,
	})
end

vim.api.nvim_create_user_command('DiaryMenu', function() M:menu() end, { desc = 'show the diary menu' })

vim.keymap.set('n', '<leader>di', function() M:menu() end, { desc = 'show the diary menu', silent = true })

return M
