-- set normal people keybinds
vim.keymap.set("n", "j", "h")
vim.keymap.set("n", "k", "j")
vim.keymap.set("n", "l", "k")
vim.keymap.set("n", ";", "l")
vim.keymap.set("v", "j", "h")
vim.keymap.set("v", "k", "j")
vim.keymap.set("v", "l", "k")
vim.keymap.set("v", ";", "l")

vim.api.nvim_set_keymap("n", "<leader>j", "<cmd>wincmd h<cr>", { desc = "go left" })
vim.api.nvim_set_keymap("n", "<leader>k", "<cmd>wincmd j<cr>", { desc = "go down" })
vim.api.nvim_set_keymap("n", "<leader>l", "<cmd>wincmd k<cr>", { desc = "go up" })
vim.api.nvim_set_keymap("n", "<leader>;", "<cmd>wincmd l<cr>", { desc = "go right" })

vim.api.nvim_set_keymap("n", "<leader>J", "<cmd>wincmd H<cr>", { desc = "move left" })
vim.api.nvim_set_keymap("n", "<leader>K", "<cmd>wincmd J<cr>", { desc = "move down" })
vim.api.nvim_set_keymap("n", "<leader>L", "<cmd>wincmd K<cr>", { desc = "move up" })
vim.api.nvim_set_keymap("n", "<leader>:", "<cmd>wincmd L<cr>", { desc = "move right" })

vim.api.nvim_set_keymap("n", "<leader>rj", "<cmd>vertical resize -5<cr>", { desc = "decrease width" })
vim.api.nvim_set_keymap("n", "<leader>rk", "<cmd>resize -5<cr>", { desc = "decrease height" })
vim.api.nvim_set_keymap("n", "<leader>rl", "<cmd>resize +5<cr>", { desc = "increase height" })
vim.api.nvim_set_keymap("n", "<leader>r;", "<cmd>vertical resize +5<cr>", { desc = "increase width" })

vim.api.nvim_set_keymap("n", "<leader>s", "<cmd>new<cr>", { desc = "split horizontal" })
vim.api.nvim_set_keymap("n", "<leader>a", "<cmd>vnew<cr>", { desc = "split vertical" })

vim.api.nvim_set_keymap("n", "<leader>dd", "<cmd>bd<cr>", { desc = "kill window" })
vim.api.nvim_set_keymap("n", "<leader>DD", "<cmd>bd!<cr>", { desc = "kill window" })

vim.api.nvim_set_keymap("n", "<leader>tN", "<cmd>tabnew<cr>", { desc = "create tab" })
vim.api.nvim_set_keymap("n", "<leader>tC", "<cmd>tabclose<cr>", { desc = "delete tab" })
vim.api.nvim_set_keymap("n", "<leader>tn", "<cmd>tabnext<cr>", { desc = "next tab" })
vim.api.nvim_set_keymap("n", "<leader>tp", "<cmd>tabprevious<cr>", { desc = "prev tab" })
vim.api.nvim_set_keymap("n", "<leader>t<", "<cmd>tabm -1<cr>", { desc = "move tab left" })
vim.api.nvim_set_keymap("n", "<leader>t>", "<cmd>tabm +1<cr>", { desc = "move tab right" })

vim.api.nvim_set_keymap("n", "<leader>nt", "<cmd>terminal<cr>", { desc = "open terminal" })
