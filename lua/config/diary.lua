---@class diary
---@field path string
local M = { path = vim.fn.expand('~/Documents/Diary') }

---@return string|nil
local function today()
	local handle = io.popen('date +"%b %d %G" 2>/dev/null')
	if not handle then
		return nil
	end

	local date = handle:read('*l')
	handle:close()

	if not date or date == '' then
		return nil
	end

	return date
end

local function ensure_dir(path)
	vim.fn.mkdir(path, "p")
end

local function buffer_is_empty(buf)
	if vim.api.nvim_buf_line_count(buf) ~= 1 then
		return false
	end
	return vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] == ''
end

function M:open_diary_today()
	ensure_dir(self.path)

	local date = today()
	if not date then
		vim.notify("can't open diary", vim.log.levels.ERROR)
		return
	end

	local today_path = self.path .. '/' .. date .. '.md'

	vim.cmd.edit(today_path)

	local buf = vim.api.nvim_get_current_buf()

	if buffer_is_empty(buf) then
		vim.api.nvim_put({ date }, 'l', false, true)
	end
end

function M:open_diary_list()
	ensure_dir(self.path)
	vim.cmd.edit(self.path .. "/")
end

vim.api.nvim_create_user_command('DiaryToday', function() M:open_diary_today() end, {})
vim.api.nvim_create_user_command('DiaryList', function() M:open_diary_list() end, {})
