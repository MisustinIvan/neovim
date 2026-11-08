-- the wikis register themselves when they are created
local wikis = require('config.wikis')

local Wiki = require('config.wiki')

local startup_group = vim.api.nvim_create_augroup('CustomStartup', { clear = true })
local homepage_ns = vim.api.nvim_create_namespace('homepage')

---@class homepage.action
---@field key string key opening it
---@field label string what it does
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
				run = function() wiki:menu() end,
			})
		end
	end

	vim.list_extend(list, {
		{ key = 'f', label = 'Open file manager', run = function() vim.cmd.edit('.') end },
		{ key = 'c', label = 'Open config',       run = function() vim.cmd.edit('~/.config/nvim/init.lua') end },
		{ key = 'q', label = 'Quit',              run = function() vim.cmd.quit() end },
	})

	return list
end

vim.api.nvim_create_autocmd('VimEnter', {
	group = startup_group,
	nested = true,
	callback = function()
		if vim.fn.argc() > 0 then
			return
		end

		local buf = vim.api.nvim_create_buf(false, true)

		local lines = { 'Welcome back', '' }
		local list = actions()

		for _, action in ipairs(list) do
			table.insert(lines, ('[%s] %s'):format(action.key, action.label))
		end

		-- the same todos <leader>di 7 lists, <cr> on one opens it
		local diary = wikis.diary
		local todos = diary:todos()
		---@type table<integer, wiki.todo>
		local todo_at = {}
		local todo_heading = nil

		if #todos > 0 then
			vim.list_extend(lines, { '', ('Open todos (%d)'):format(#todos) })
			todo_heading = #lines
			for _, todo in ipairs(todos) do
				table.insert(lines, '  ' .. diary:todo_label(todo))
				todo_at[#lines] = todo
			end
		end

		vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

		if todo_heading then
			vim.api.nvim_buf_set_extmark(buf, homepage_ns, todo_heading - 1, 0, {
				end_col = #lines[todo_heading],
				hl_group = 'Title',
			})
		end

		for lnum in pairs(todo_at) do
			-- the note and line, everything up to the two spaces before the text
			local stop = lines[lnum]:find('  ', 3, true)
			if stop then
				vim.api.nvim_buf_set_extmark(buf, homepage_ns, lnum - 1, 2, {
					end_col = stop - 1,
					hl_group = 'Comment',
				})
			end
		end

		vim.bo[buf].buftype = 'nofile'
		vim.bo[buf].bufhidden = 'wipe'
		vim.bo[buf].swapfile = false
		vim.bo[buf].modifiable = false
		vim.bo[buf].filetype = 'startup'

		vim.api.nvim_win_set_buf(0, buf)

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
