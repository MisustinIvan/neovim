local set = vim.opt

set.termguicolors = true

set.expandtab = true
set.smarttab = true

set.shiftwidth = 4
set.tabstop = 4

set.hlsearch = true
set.incsearch = true
set.ignorecase = true
set.smartcase = true

set.wrap = false

set.scrolloff = 5

--set.fileencoding = 'utf-8'

set.relativenumber = true
set.number = true

set.hidden = true

set.splitbelow = true

set.autoindent = true

set.cursorline = true

set.mouse = 'a'

vim.keymap.set("x", "<leader>p", "\"_dP")

vim.keymap.set("n", "<leader>y", "\"+y")
vim.keymap.set("v", "<leader>y", "\"+y")
vim.keymap.set("n", "<leader>Y", "\"+Y")

vim.keymap.set("n", "<leader>rr", ":RunCode<CR>")

function _G.set_terminal_keymaps()
  local opts = {buffer = 0}
  vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
  vim.keymap.set('t', 'kl', [[<C-\><C-n>]], opts)
  vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd h<CR>]], opts)
  vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd j<CR>]], opts)
  vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd k<CR>]], opts)
  vim.keymap.set('t', '<C-;>', [[<Cmd>wincmd l<CR>]], opts)
end

vim.cmd([[
augroup FileTypeTSX
    autocmd!
    autocmd FileType typescriptreact setlocal tabstop=2 shiftwidth=2 softtabstop=2
augroup END
]])


-- if you only want these mappings for toggle term use term://*toggleterm#* instead
vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')

vim.cmd([[

    syntax on

    nmap <F3> :NeoTreeFocusToggle<CR>
    nmap <F4> :NeoTreeShowToggle<CR>
    nmap tt :ToggleTerm direction=float<CR>clear<CR>
    nmap th :ToggleTerm direction=horizontal<CR>clear<CR>
    
    nmap <Space>a :vnew<CR>
    nmap <Space>s :new<CR>
    
    nmap <Space>dd :bd<CR>

	nnoremap j h
	nnoremap k j
	nnoremap l k
	nnoremap ; l

    vnoremap j h
    vnoremap k j
    vnoremap l k
    vnoremap ; l

    nmap <Space>gl :Telescope live_grep<CR>
    nmap <Space>ff :Telescope find_files<CR>
    nmap <Space>gc :Telescope git_commits<CR>
    nmap <Space>gr :Telescope lsp_references<CR>
    nmap <Space>of :Telescope oldfiles<CR>
    
    nmap <Space>q :bp<CR>
    nmap <Space>w :bn<CR>
    nmap <Space>e :tabprevious<CR>
    nmap <Space>r :tabnext<CR>
    nmap <Space>t :tabclose<CR>
    nmap <Space>y :tabnew<CR>
    
    nmap <Space>j :wincmd h<CR>
    nmap <Space>k :wincmd j<CR>
    nmap <Space>l :wincmd k<CR>
    nmap <Space>; :wincmd l<CR>
    
    nmap <Space>J :wincmd h<CR>
    nmap <Space>K :wincmd j<CR>
    nmap <Space>L :wincmd k<CR>
    nmap <Space>: :wincmd l<CR>
    
    nmap <Space>rj :vertical resize -5<CR>
    nmap <Space>rk :resize -5<CR>
    nmap <Space>rl :resize +5<CR>
    nmap <Space>r; :vertical resize +5<CR>
]])
