-- MAOMAO
-- created on https://nvimcolors.com

-- Clear existing highlights and reset syntax
vim.cmd('highlight clear')
vim.cmd('syntax reset')

-- Basic UI elements
vim.cmd('highlight Normal guibg=#183539 guifg=#eab8bb')
vim.cmd('highlight NonText guibg=#183539 guifg=#183539')
vim.cmd('highlight CursorLine guibg=#2d4246')
vim.cmd('highlight LineNr guifg=#81777a')
vim.cmd('highlight CursorLineNr guifg=#cf8592')
vim.cmd('highlight SignColumn guibg=#183539')
vim.cmd('highlight StatusLine gui=bold guibg=#165a5d guifg=#eab8bb')
vim.cmd('highlight StatusLineNC gui=bold guibg=#eab8bb guifg=#80898c')
vim.cmd('highlight Directory guifg=#eab8bb')
vim.cmd('highlight Visual guibg=#575c60')
vim.cmd('highlight Search guibg=#81777a guifg=#eab8bb')
vim.cmd('highlight CurSearch guibg=#cf8592 guifg=#183539')
vim.cmd('highlight IncSearch gui=None guibg=#cf8592 guifg=#183539')
vim.cmd('highlight MatchParen guibg=#81777a guifg=#eab8bb')
vim.cmd('highlight Pmenu guibg=#465d61 guifg=#eab8bb')
vim.cmd('highlight PmenuSel guibg=#77787c guifg=#cf8592')
vim.cmd('highlight PmenuSbar guibg=#77787c guifg=#eab8bb')
vim.cmd('highlight VertSplit guifg=#eab8bb')
vim.cmd('highlight MoreMsg guifg=#c86174')
vim.cmd('highlight Question guifg=#c86174')
vim.cmd('highlight Title guifg=#d47787')

-- Syntax highlighting
vim.cmd('highlight Comment guifg=#81777a gui=italic')
vim.cmd('highlight Constant guifg=#298657')
vim.cmd('highlight Identifier guifg=#d47787')
vim.cmd('highlight Statement guifg=#eab8bb')
vim.cmd('highlight PreProc guifg=#eab8bb')
vim.cmd('highlight Type guifg=#da9aa5 gui=None')
vim.cmd('highlight Special guifg=#c86174')

-- Refined syntax highlighting
vim.cmd('highlight String guifg=#298657')
vim.cmd('highlight Number guifg=#eab8bb')
vim.cmd('highlight Boolean guifg=#298657')
vim.cmd('highlight Function guifg=#e1a0ab')
vim.cmd('highlight Keyword guifg=#cb6a7b gui=italic')

-- Html syntax highlighting
vim.cmd('highlight Tag guifg=#c86174')
vim.cmd('highlight @tag.delimiter guifg=#eab8bb')
vim.cmd('highlight @tag.attribute guifg=#298657')

-- Messages
vim.cmd('highlight ErrorMsg guifg=#c86174')
vim.cmd('highlight Error guifg=#c86174')
vim.cmd('highlight DiagnosticError guifg=#c86174')
vim.cmd('highlight DiagnosticVirtualTextError guibg=#2a393f guifg=#c86174')
vim.cmd('highlight WarningMsg guifg=#c87c61')
vim.cmd('highlight DiagnosticWarn guifg=#c87c61')
vim.cmd('highlight DiagnosticVirtualTextWarn guibg=#2a3c3d guifg=#c87c61')
vim.cmd('highlight DiagnosticInfo guifg=#165a5d')
vim.cmd('highlight DiagnosticVirtualTextInfo guibg=#18393d guifg=#165a5d')
vim.cmd('highlight DiagnosticHint guifg=#298677')
vim.cmd('highlight DiagnosticVirtualTextHint guibg=#1a3d3f guifg=#298677')
vim.cmd('highlight DiagnosticOk guifg=#298657')

-- Common plugins
vim.cmd('highlight CopilotSuggestion guifg=#81777a') -- Copilot suggestion
vim.cmd('highlight TelescopeSelection guibg=#575c60') -- Telescope selection
