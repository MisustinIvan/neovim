---@class wiki.journal dated entries, a wiki without one is only a pile of notes
---@field file_format string strftime format for entry filenames, sorts chronologically
---@field entry_pattern string lua pattern matching a filename produced by file_format
---@field headings string[] second level headings inserted into a new entry

---@class wiki.opts
---@field name string how the wiki calls itself in messages and menu titles
---@field path string directory holding the notes
---@field command_prefix string user commands are this followed by the action, :WikiFind
---@field prefix string|nil keymap opening the menu
---@field key string|nil key the homepage offers the wiki under
---@field date_format string|nil strftime format for the date written into a note
---@field todo_heading string|nil heading whose section holds the todos, TODO by default
---@field journal wiki.journal|nil
---@field buf_opts table<string, any>|nil options applied to a note buffer

---@class wiki : wiki.opts
---@field actions wiki.action[]
local Wiki = {}
Wiki.__index = Wiki

---every wiki that was created, in the order they were
---@type wiki[]
Wiki.registry = {}

local default_buf_opts = {
	wrap = true,
	linebreak = true,
	conceallevel = 2,
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
		vim.notify('wiki: cannot create ' .. path, vim.log.levels.ERROR)
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

---a bare name refers to a markdown note
---@param name string
---@return string
local function with_extension(name)
	if name:match('%.%w+$') then
		return name
	end
	return name .. '.md'
end

---@param path string
---@param root string
---@return string
local function relative(path, root)
	local prefix = vim.fs.normalize(root) .. '/'
	local normalized = vim.fs.normalize(path)

	if normalized:sub(1, #prefix) == prefix then
		return normalized:sub(#prefix + 1)
	end

	return normalized
end

---target of the markdown link the cursor sits in
---@param line string
---@param col integer zero based cursor column
---@return string|nil
local function link_under_cursor(line, col)
	local from = 1

	while true do
		local start, stop, target = line:find('%[[^%]]*%]%(([^%)]*)%)', from)
		if not start then
			return nil
		end

		if col + 1 >= start and col + 1 <= stop then
			return target
		end

		from = stop + 1
	end
end

---@param opts wiki.opts
---@return wiki
function Wiki.new(opts)
	local self = setmetatable({}, Wiki)

	self.name = opts.name
	self.path = vim.fn.expand(opts.path)
	self.command_prefix = opts.command_prefix
	self.prefix = opts.prefix
	self.key = opts.key
	self.date_format = opts.date_format or '%b %d %Y'
	self.todo_heading = opts.todo_heading or 'TODO'
	self.journal = opts.journal
	self.buf_opts = opts.buf_opts or default_buf_opts
	self.actions = self:build_actions()

	self:register_commands()

	if self.prefix then
		vim.keymap.set('n', self.prefix, function() self:menu() end,
			{ desc = 'show the ' .. self.name .. ' menu', silent = true })
	end

	table.insert(Wiki.registry, self)

	return self
end

---readable date, also used by the insert date keymap
---@param time integer|nil
---@return string
function Wiki:date_string(time)
	return os.date(self.date_format, time or os.time())
end

---the wiki a buffer belongs to, if any
---@param buf integer
---@return wiki|nil
function Wiki.owner(buf)
	local name = vim.fs.normalize(vim.api.nvim_buf_get_name(buf))

	for _, wiki in ipairs(Wiki.registry) do
		local dir = vim.fs.normalize(wiki.path) .. '/'
		if name:sub(1, #dir) == dir then
			return wiki
		end
	end

	return nil
end

---@param buf integer
---@return boolean
function Wiki:owns_buffer(buf)
	return Wiki.owner(buf) == self
end

--- notes ---------------------------------------------------------------------

---contents of a fresh note
---@param path string
---@return string[]
function Wiki:note_template(path)
	return { '# ' .. vim.fn.fnamemodify(path, ':t:r') }
end

---open a note by its path, seeding it when it is new
---@param path string
function Wiki:edit_note(path)
	if not ensure_dir(vim.fn.fnamemodify(path, ':h')) then
		return
	end

	vim.cmd.edit(vim.fn.fnameescape(path))

	local buf = vim.api.nvim_get_current_buf()

	if vim.fn.filereadable(path) == 0 and buffer_is_empty(buf) then
		local lines = self:note_template(path)
		vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
		vim.api.nvim_win_set_cursor(0, { #lines, 0 })
	end
end

---open a note referred to by name, looking it up anywhere in the wiki
---@param target string a bare name, or a path relative to the current note
function Wiki:open_note(target)
	local name = with_extension(target)

	-- anything written as a path is taken literally, next to the current note
	if name:find('/') then
		local path = name:match('^[~/]') and name or (vim.fn.expand('%:p:h') .. '/' .. name)
		self:edit_note(vim.fs.normalize(vim.fn.expand(path)))
		return
	end

	local matches = vim.fs.find(name, { path = self.path, type = 'file', limit = math.huge })

	if #matches == 0 then
		-- a link to a note that is not written yet creates it
		self:edit_note(self.path .. '/' .. name)
	elseif #matches == 1 then
		self:edit_note(matches[1])
	else
		vim.ui.select(matches, {
			prompt = self.name .. ': ' .. name,
			format_item = function(item) return relative(item, self.path) end,
		}, function(choice)
			if choice then
				self:edit_note(choice)
			end
		end)
	end
end

---follow the markdown link under the cursor
---@return boolean handled false when the cursor is not on a link
function Wiki:follow_link()
	local target = link_under_cursor(vim.api.nvim_get_current_line(), vim.api.nvim_win_get_cursor(0)[2])
	if not target then
		return false
	end

	-- a link into the current note only carries an anchor
	target = vim.trim((target:gsub('#.*$', '')))
	if target == '' then
		return true
	end

	-- http, mailto and friends belong to the system handler
	if target:match('^%a[%w+.%-]*:') then
		vim.ui.open(target)
		return true
	end

	self:open_note(vim.uri_decode(target))
	return true
end

function Wiki:new_note()
	if not ensure_dir(self.path) then
		return
	end

	vim.ui.input({ prompt = self.name .. ' note: ' }, function(name)
		if name and vim.trim(name) ~= '' then
			self:open_note(vim.trim(name))
		end
	end)
end

function Wiki:open_list()
	if not ensure_dir(self.path) then
		return
	end
	vim.cmd.edit(vim.fn.fnameescape(self.path .. '/'))
end

function Wiki:find_note()
	require('telescope.builtin').find_files({ cwd = self.path, no_ignore = true })
end

function Wiki:grep_notes()
	require('telescope.builtin').live_grep({ cwd = self.path })
end

--- todos ---------------------------------------------------------------------

---@class wiki.todo
---@field path string note the todo was found in
---@field lnum integer line it sits on
---@field text string the todo itself, without the checkbox

---unchecked boxes under the todo heading of a single note
---@param path string
---@return wiki.todo[]
function Wiki:note_todos(path)
	local ok, lines = pcall(vim.fn.readfile, path)
	if not ok then
		return {}
	end

	local wanted = self.todo_heading:lower()
	local todos = {}
	-- the level of the todo heading we are under, nil while outside one
	local level = nil

	for lnum, line in ipairs(lines) do
		local hashes, heading = line:match('^(#+)%s+(.-)%s*$')

		if hashes then
			-- a heading of the same or a higher level ends the section
			if level and #hashes <= level then
				level = nil
			end
			if heading:lower() == wanted then
				level = #hashes
			end
		elseif level then
			local box, text = line:match('^%s*[-*+]%s+%[(.)%]%s*(.*)$')
			if box == ' ' and text ~= '' then
				table.insert(todos, { path = path, lnum = lnum, text = text })
			end
		end
	end

	return todos
end

---every open todo in the wiki, notes in alphabetical order
---@return wiki.todo[]
function Wiki:todos()
	if vim.fn.isdirectory(self.path) == 0 then
		return {}
	end

	local notes = vim.fs.find(function(name) return name:match('%.md$') end,
		{ path = self.path, type = 'file', limit = math.huge })

	table.sort(notes)

	local todos = {}
	for _, note in ipairs(notes) do
		vim.list_extend(todos, self:note_todos(note))
	end

	return todos
end

function Wiki:pick_todos()
	local todos = self:todos()

	if #todos == 0 then
		vim.notify(self.name .. ': nothing open under ' .. self.todo_heading, vim.log.levels.INFO)
		return
	end

	local root = self.path

	require('telescope.pickers').new({}, {
		prompt_title = self.name .. ' todos',
		finder = require('telescope.finders').new_table({
			results = todos,
			---@param todo wiki.todo
			entry_maker = function(todo)
				local note = relative(todo.path, root)
				return {
					value = todo,
					display = ('%s:%d  %s'):format(note, todo.lnum, todo.text),
					ordinal = note .. ' ' .. todo.text,
					filename = todo.path,
					lnum = todo.lnum,
					col = 1,
					text = todo.text,
				}
			end,
		}),
		sorter = require('telescope.config').values.generic_sorter({}),
		previewer = require('telescope.config').values.grep_previewer({}),
	}):find()
end

--- journal -------------------------------------------------------------------

---@param time integer|nil
---@return string
function Wiki:entry_path(time)
	return self.path .. '/' .. os.date(self.journal.file_format, time or os.time()) .. '.md'
end

---contents of a fresh entry
---@param time integer|nil
---@return string[]
function Wiki:template(time)
	local lines = { '# ' .. self:date_string(time) }

	for _, heading in ipairs(self.journal.headings) do
		vim.list_extend(lines, { '', '## ' .. heading, '' })
	end

	return lines
end

---every entry in the journal, oldest first
---@return string[]
function Wiki:entries()
	if vim.fn.isdirectory(self.path) == 0 then
		return {}
	end

	local entries = vim.fn.readdir(self.path, function(name)
		return name:match(self.journal.entry_pattern) and 1 or 0
	end)

	table.sort(entries)
	return entries
end

---@param days integer|nil offset from today in days
function Wiki:open_entry(days)
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
function Wiki:open_adjacent(step)
	local entries = self:entries()
	if #entries == 0 then
		vim.notify(self.name .. ': no entries yet', vim.log.levels.WARN)
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

	-- outside the journal, step in from the end we are heading towards
	if not index then
		index = step < 0 and #entries + 1 or 0
	end

	local target = entries[index + step]
	if not target then
		vim.notify(self.name .. ': no further entry', vim.log.levels.WARN)
		return
	end

	vim.cmd.edit(vim.fn.fnameescape(self.path .. '/' .. target))
end

--- commands ------------------------------------------------------------------

function Wiki:register_commands()
	local function command(action, run, opts)
		vim.api.nvim_create_user_command(self.command_prefix .. action, run, opts)
	end

	if self.journal then
		command('Today', function(opts) self:open_entry(tonumber(opts.args)) end,
			{ nargs = '?', desc = 'open the entry for today, or an offset in days' })
		command('Prev', function() self:open_adjacent(-1) end, { desc = 'previous ' .. self.name .. ' entry' })
		command('Next', function() self:open_adjacent(1) end, { desc = 'next ' .. self.name .. ' entry' })
	end

	command('List', function() self:open_list() end, { desc = 'browse the ' .. self.name })
	command('New', function() self:new_note() end, { desc = 'create a ' .. self.name .. ' note' })
	command('Todo', function() self:pick_todos() end, { desc = 'open todos in the ' .. self.name })
	command('Find', function() self:find_note() end, { desc = 'find a ' .. self.name .. ' note' })
	command('Grep', function() self:grep_notes() end, { desc = 'grep the ' .. self.name })
	command('Menu', function() self:menu() end, { desc = 'show the ' .. self.name .. ' menu' })
end

--- menu ----------------------------------------------------------------------

---@class wiki.action
---@field label string what the action does
---@field cmd string the command it stands for, shown in the menu
---@field run fun() the action itself

---entries of the menu, in the order they are listed and numbered
---@return wiki.action[]
function Wiki:build_actions()
	local prefix = ':' .. self.command_prefix
	local actions = {}

	local function add(label, cmd, run)
		table.insert(actions, { label = label, cmd = prefix .. cmd, run = run })
	end

	if self.journal then
		add('todays entry', 'Today', function() self:open_entry() end)
		add('yesterdays entry', 'Today -1', function() self:open_entry(-1) end)
	end

	add('browse the ' .. self.name, 'List', function() self:open_list() end)

	if self.journal then
		add('previous entry', 'Prev', function() self:open_adjacent(-1) end)
		add('next entry', 'Next', function() self:open_adjacent(1) end)
	end

	add('new note', 'New', function() self:new_note() end)
	add('open todos', 'Todo', function() self:pick_todos() end)
	add('find a note', 'Find', function() self:find_note() end)
	add('grep the notes', 'Grep', function() self:grep_notes() end)

	return actions
end

local menu_ns = vim.api.nvim_create_namespace('wiki_menu')

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

---floating list of the wiki commands, pick one by its number
function Wiki:menu()
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
	vim.bo[buf].filetype = 'wikimenu'

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
		title = ' ' .. self.name .. ' ',
		title_pos = 'center',
	})

	vim.wo[win].cursorline = true

	local function close()
		if vim.api.nvim_win_is_valid(win) then
			vim.api.nvim_win_close(win, true)
		end
	end

	---closes the menu first so the action lands in the window below it
	---@param action wiki.action|nil
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
		desc = 'close the wiki menu when it loses focus',
		buffer = buf,
		once = true,
		callback = close,
	})
end

--- buffer setup --------------------------------------------------------------

vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufWinEnter' }, {
	desc = 'prose friendly options and link following in wiki notes',
	group = vim.api.nvim_create_augroup('UserWiki', {}),
	-- the paths are read on every event so the wikis stay configurable
	pattern = '*.md',
	callback = function(event)
		local wiki = Wiki.owner(event.buf)
		if not wiki then
			return
		end

		for name, value in pairs(wiki.buf_opts) do
			vim.opt_local[name] = value
		end

		vim.keymap.set('n', 'K', function()
			if not wiki:follow_link() then
				vim.lsp.buf.hover()
			end
		end, { buffer = event.buf, silent = true, desc = 'follow the link under the cursor' })
	end,
})

return Wiki
