-- basic settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.wrap = false
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.clipboard = 'unnamedplus'

-- indentation
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = false
vim.opt.smartindent = true
vim.opt.autoindent = true

-- search settings
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.incsearch = true

-- visual settings
vim.opt.termguicolors = true
vim.opt.signcolumn = 'yes'
vim.opt.colorcolumn = '80'
vim.opt.showmatch = false
vim.opt.matchtime = 0
vim.opt.cmdheight = 1
vim.opt.completeopt = 'menuone,noinsert,noselect'
vim.opt.showmode = true
vim.opt.pumheight = 10
vim.opt.pumblend = 0
vim.opt.winblend = 0
vim.opt.conceallevel = 0
vim.opt.concealcursor = ''
vim.opt.synmaxcol = 300
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣', eol = '󱞥' }
vim.opt.list = true
vim.opt.laststatus = 3

-- file handling
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.swapfile = false
vim.opt.undofile = true
vim.opt.undodir = vim.fn.expand('~/.nvim/undodir')
vim.opt.autoread = true

-- behavior settings
vim.opt.hidden = true
vim.opt.errorbells = false
vim.opt.backspace = 'indent,eol,start'
vim.opt.mouse = ''
vim.opt.modifiable = true
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.shell = 'fish'

-- create a command to update plugins
vim.api.nvim_create_user_command('PackUpdate', function()
	vim.pack.update()
end, { desc = 'update all plugins installed via vim.pack.add' })
