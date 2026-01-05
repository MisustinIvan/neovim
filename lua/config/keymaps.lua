-- set leader
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- set normal people keybinds
vim.keymap.set('n', 'j', 'h', { silent = true })
vim.keymap.set('n', 'k', 'j', { silent = true })
vim.keymap.set('n', 'l', 'k', { silent = true })
vim.keymap.set('n', ';', 'l', { silent = true })
vim.keymap.set('v', 'j', 'h', { silent = true })
vim.keymap.set('v', 'k', 'j', { silent = true })
vim.keymap.set('v', 'l', 'k', { silent = true })
vim.keymap.set('v', ';', 'l', { silent = true })

-- changing window focus
vim.keymap.set('n', '<leader>j', '<cmd>wincmd h<cr>', { desc = 'focus window to the left', silent = true })
vim.keymap.set('n', '<leader>k', '<cmd>wincmd j<cr>', { desc = 'focus window to the bottom', silent = true })
vim.keymap.set('n', '<leader>l', '<cmd>wincmd k<cr>', { desc = 'focus window to the top', silent = true })
vim.keymap.set('n', '<leader>;', '<cmd>wincmd l<cr>', { desc = 'focus window to the right', silent = true })

-- moving windows around
vim.keymap.set('n', '<leader>J', '<cmd>wincmd H<cr>', { desc = 'move window left', silent = true })
vim.keymap.set('n', '<leader>K', '<cmd>wincmd J<cr>', { desc = 'move window down', silent = true })
vim.keymap.set('n', '<leader>L', '<cmd>wincmd K<cr>', { desc = 'move widnow up', silent = true })
vim.keymap.set('n', '<leader>:', '<cmd>wincmd L<cr>', { desc = 'move window right', silent = true })

-- opening new windows
vim.keymap.set('n', '<leader>sk', '<cmd>new<cr>', { desc = 'open new window split horizontally', silent = true })
vim.keymap.set('n', '<leader>sl', '<cmd>new<cr>', { desc = 'open new window split horizontally', silent = true })
vim.keymap.set('n', '<leader>sj', '<cmd>vnew<cr>', { desc = 'open new window split vertically', silent = true })
vim.keymap.set('n', '<leader>s;', '<cmd>vnew<cr>', { desc = 'open new window split vertically', silent = true })

-- closing windows
vim.keymap.set('n', '<leader>dd', '<cmd>bd<cr>', { desc = 'delete current buffer', silent = true })
vim.keymap.set('n', '<leader>DD', '<cmd>bd!<cr>', { desc = 'delete current buffer by force', silent = true })
vim.keymap.set('n', '<leader>sc', '<cmd>wincmd c<cr>', { desc = 'close current window', silent = true })

-- resizing windows
vim.keymap.set('n', '<C-left>', '<cmd>vertical resize -5<cr>', { desc = 'decrease width', silent = true })
vim.keymap.set('n', '<C-down>', '<cmd>resize -5<cr>', { desc = 'decrease height', silent = true })
vim.keymap.set('n', '<C-up>', '<cmd>resize +5<cr>', { desc = 'increase height', silent = true })
vim.keymap.set('n', '<C-right>', '<cmd>vertical resize +5<cr>', { desc = 'increase width', silent = true })

-- moving text around
vim.keymap.set('n', '<A-l>', '<cmd>m .-2<CR>==', { desc = 'move line up', silent = true })
vim.keymap.set('n', '<A-k>', '<cmd>m .+1<CR>==', { desc = 'move line down', silent = true })
vim.keymap.set('v', '<A-l>', ':m \'<-2<CR>gv=gv', { desc = 'move selection up', silent = true })
vim.keymap.set('v', '<A-k>', ':m \'>+1<CR>gv=gv', { desc = 'move selection down', silent = true })

-- better visual mode indenting
vim.keymap.set('v', '>', '>gv', { desc = 'move selection right and reselect', silent = true })
vim.keymap.set('v', '<', '<gv', { desc = 'move selection left and reselect', silent = true })

-- edit config file
vim.keymap.set('n', '<leader>rc', '<cmd>e ~/.config/nvim/init.lua<CR>', { desc = 'open config file', silent = true })

-- copy file path
vim.keymap.set('n', '<leader>pa', function()
	local path = vim.fn.expand('%:p')
	vim.fn.setreg('+', path)
	print('file: ' .. path)
end)

-- insert current date
vim.keymap.set('n', '<leader>td', function()
	local handle = io.popen('date +"%b %d %G" 2>/dev/null')
	if not handle then
		print('can\'t insert date')
		return
	end

	local date = handle:read('*l')
	handle:close()

	if not date or date == '' then
		print('can\'t insert date')
		return
	end

	vim.api.nvim_put({ date .. ' ' }, 'c', false, true)
end)

-- terminal keymaps
vim.keymap.set('t', '<esc>', '<C-\\><C-n>')

vim.keymap.set('n', '<leader>nt', '<cmd>terminal<cr>',
	{ desc = 'opens a new terminal in the current buffer', silent = true })

-- working with tabs
vim.api.nvim_set_keymap('n', '<leader>tN', '<cmd>tabnew<cr>', { desc = 'create tab' })
vim.api.nvim_set_keymap('n', '<leader>tC', '<cmd>tabclose<cr>', { desc = 'delete tab' })
vim.api.nvim_set_keymap('n', '<leader>tn', '<cmd>tabnext<cr>', { desc = 'next tab' })
vim.api.nvim_set_keymap('n', '<leader>tp', '<cmd>tabprevious<cr>', { desc = 'prev tab' })
vim.api.nvim_set_keymap('n', '<leader>t<', '<cmd>tabm -1<cr>', { desc = 'move tab left' })
vim.api.nvim_set_keymap('n', '<leader>t>', '<cmd>tabm +1<cr>', { desc = 'move tab right' })

-- lsp
vim.keymap.set(
	'i',
	'<c-k>',
	'<cmd>lua vim.lsp.buf.signature_help()<cr>',
	{ noremap = true, silent = true, desc = 'Hover' }
)
vim.keymap.set(
	'n',
	'K',
	'<cmd>lua vim.lsp.buf.hover()<cr>',
	{ noremap = true, silent = true, desc = 'Hover' }
)
vim.keymap.set(
	'n',
	'<leader>gd',
	'<cmd>lua vim.lsp.buf.definition()<cr>',
	{ noremap = true, silent = true, desc = 'Go to definition' }
)
vim.keymap.set(
	'n',
	'<leader>gt',
	'<cmd>lua vim.lsp.buf.type_definition()<cr>',
	{ noremap = true, silent = true, desc = 'Go to type definition' }
)
vim.keymap.set(
	'n',
	'<leader>do',
	'<cmd>lua vim.diagnostic.open_float()<CR>',
	{ noremap = true, silent = true, desc = 'Show diagnostics' }
)
vim.keymap.set(
	'n',
	'<leader>ca',
	'<cmd>lua vim.lsp.buf.code_action()<CR>',
	{ noremap = true, silent = true, desc = 'Code actions' }
)
