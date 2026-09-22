-- the wikis register themselves when they are created
require('config.wikis')

local Wiki = require('config.wiki')

local startup_group = vim.api.nvim_create_augroup('CustomStartup', { clear = true })

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

		vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

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
	end,
})
