
	-- setup lazy --

local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable',
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

	-- set the mapleader because lazy wants it --

vim.g.mapleader = " "

    -- give the plugins to lazy --

require('lazy').setup('plugins')

    -- load up all of the config files --

require('config.keymaps')
require('config.colors')
require('config.lualine')
require('config.bufferline')
require('config.pairs')
require('config.scope')
require('config.toggleterm')
require('config.treesitter')
require('config.trouble')
require('config.nvim-cmp')
require('config.fidget')
require('config.mason')
require('config.lint')
require('config.presence')
