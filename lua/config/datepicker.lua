-- floating calendar date picker laid out like `cal`
local M = {}

local ns = vim.api.nvim_create_namespace('datepicker')
local WIDTH = 20 -- 7 columns of 2 chars, separated by single spaces
local HEIGHT = 8 -- title, weekday header and up to 6 weeks

---@param y integer
---@param m integer
---@param d integer
---@return osdate
local function normalize(y, m, d)
	-- midday keeps a daylight saving shift from moving the date
	return os.date('*t', os.time({ year = y, month = m, day = d, hour = 12 })) --[[@as osdate]]
end

---@param y integer
---@param m integer
---@return integer
local function days_in_month(y, m)
	return normalize(y, m + 1, 0).day
end

---@param s string
---@return string
local function center(s)
	local pad = WIDTH - vim.fn.strdisplaywidth(s)
	local left = math.floor(pad / 2)
	return string.rep(' ', left) .. s .. string.rep(' ', pad - left)
end

---@param date osdate
---@return string[] lines
---@return integer row 0-based line of `date`
---@return integer col 0-based byte column of `date`
local function render(date)
	local lines = { center(os.date('%B %Y', os.time(date)) --[[@as string]]) }

	-- weekday names abbreviated to two characters, Monday first
	local names = {}
	for i = 0, 6 do
		-- 2023-01-02 was a Monday
		local name = os.date('%a', os.time({ year = 2023, month = 1, day = 2 + i, hour = 12 })) --[[@as string]]
		table.insert(names, vim.fn.strcharpart(name, 0, 2))
	end
	table.insert(lines, table.concat(names, ' '))

	local first = normalize(date.year, date.month, 1)
	-- wday is 1 for Sunday, shift so Monday is column 0
	local offset = (first.wday + 5) % 7
	local cells = {}
	for _ = 1, offset do
		table.insert(cells, '  ')
	end
	for d = 1, days_in_month(date.year, date.month) do
		table.insert(cells, string.format('%2d', d))
	end

	for week = 0, 5 do
		local row = {}
		for i = 1, 7 do
			table.insert(row, cells[week * 7 + i] or '  ')
		end
		table.insert(lines, table.concat(row, ' '))
	end

	local index = offset + date.day - 1
	return lines, 2 + math.floor(index / 7), (index % 7) * 3
end

---open the picker; `on_select` receives the chosen date as os.time()
---@param on_select fun(time: integer)
---@param opts { time: integer|nil, title: string|nil }|nil
function M.pick(on_select, opts)
	opts = opts or {}
	local date = os.date('*t', opts.time or os.time()) --[[@as osdate]]
	date = normalize(date.year, date.month, date.day)
	local today = os.date('*t') --[[@as osdate]]

	local buf = vim.api.nvim_create_buf(false, true)
	vim.bo[buf].bufhidden = 'wipe'

	local win = vim.api.nvim_open_win(buf, true, {
		relative = 'cursor',
		row = 1,
		col = 0,
		width = WIDTH,
		height = HEIGHT,
		style = 'minimal',
		border = 'rounded',
		title = opts.title or ' pick a date ',
		title_pos = 'center',
		footer = ' ^u/^d month ',
		footer_pos = 'center',
	})
	vim.wo[win].cursorline = false
	-- the global scrolloffs would shift the viewport near the edges
	vim.wo[win].scrolloff = 0
	vim.wo[win].sidescrolloff = 0
	vim.wo[win].winhighlight = 'Normal:NormalFloat'

	local function draw()
		local lines, row, col = render(date)
		vim.bo[buf].modifiable = true
		vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
		vim.bo[buf].modifiable = false

		vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
		vim.hl.range(buf, ns, 'Title', { 0, 0 }, { 0, #lines[1] })
		vim.hl.range(buf, ns, 'Comment', { 1, 0 }, { 1, #lines[2] })

		if date.year == today.year and date.month == today.month and date.day ~= today.day then
			local _, trow, tcol = render(normalize(today.year, today.month, today.day))
			vim.hl.range(buf, ns, 'Special', { trow, tcol }, { trow, tcol + 2 })
		end
		vim.hl.range(buf, ns, 'PmenuSel', { row, col }, { row, col + 2 })
		vim.api.nvim_win_set_cursor(win, { row + 1, col + 1 })
	end

	local function close()
		if vim.api.nvim_win_is_valid(win) then
			vim.api.nvim_win_close(win, true)
		end
	end

	---@param days integer
	local function shift_days(days)
		date = normalize(date.year, date.month, date.day + days)
		draw()
	end

	---@param months integer
	local function shift_months(months)
		local first = normalize(date.year, date.month + months, 1)
		local day = math.min(date.day, days_in_month(first.year, first.month))
		date = normalize(first.year, first.month, day)
		draw()
	end

	local function map(keys, fn)
		for _, key in ipairs(keys) do
			vim.keymap.set('n', key, fn, { buffer = buf, nowait = true, silent = true })
		end
	end

	-- movement follows the jkl; layout from keymaps.lua
	map({ 'j', 'h', '<left>' }, function() shift_days(-1) end)
	map({ ';', '<right>' }, function() shift_days(1) end)
	map({ 'l', '<up>' }, function() shift_days(-7) end)
	map({ 'k', '<down>' }, function() shift_days(7) end)
	map({ '<C-u>' }, function() shift_months(-1) end)
	map({ '<C-d>' }, function() shift_months(1) end)
	map({ 't' }, function()
		date = normalize(today.year, today.month, today.day)
		draw()
	end)
	map({ 'q', '<esc>' }, close)
	map({ '<cr>' }, function()
		local time = os.time(date)
		close()
		on_select(time)
	end)

	-- close when focus leaves the picker
	vim.api.nvim_create_autocmd('WinLeave', {
		buffer = buf,
		once = true,
		callback = function() vim.schedule(close) end,
	})

	draw()
end

return M
