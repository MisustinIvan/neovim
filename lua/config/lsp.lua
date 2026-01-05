local signs = { Error = ' ', Warn = ' ', Hint = ' ', Info = ' ' }
for type, icon in pairs(signs) do
	local hl = 'DiagnosticSign' .. type
	vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

vim.diagnostic.config({
	virtual_text = true,
	underline = true,
	update_in_insert = false,
	severity_sort = true,
})

vim.api.nvim_create_autocmd('BufWritePre', {
	desc = 'Format the current file',
	callback = function()
		vim.lsp.buf.format({ async = false })
	end,
})

vim.pack.add({
	'https://github.com/neovim/nvim-lspconfig',
	'https://github.com/saghen/blink.cmp',
	'https://github.com/j-hui/fidget.nvim',
	'https://github.com/folke/neodev.nvim',
	'https://github.com/mini-nvim/mini.icons',
})

require('mini.icons').setup({})
require('fidget').setup({})
require('neodev').setup({})
--local lspconfig = require('lspconfig')
local capabilities = require('blink.cmp').get_lsp_capabilities()

vim.lsp.config("*", { capabilities = capabilities })
vim.lsp.config("elixirls", { cmd = { "/usr/bin/elixir-ls" } })

local language_servers = {
	"lua_ls",
	"gopls",
	"clangd",
	"arduino_language_server",
	"tinymist",
	"ts_ls",
	"ols",
	"pyright",
	"rust_analyzer",
	"zls",
	"elp", -- erlang language platform
	"elixirls",
}

for _, server in pairs(language_servers) do
	vim.lsp.enable(server)
end


require('blink.cmp').setup({
	appearance = {
		nerd_font_variant = 'mono',
		use_nvim_cmp_as_default = false,
	},
	keymap = {
		preset = 'enter',
	},
	signature = {
		enabled = true
	},
	fuzzy = {
		implementation = 'lua',
		sorts = {
			'exact',
			'score',
		}
	},
	sources = {
		default = { 'lsp', 'path', 'snippets' }
	},
	completion = {
		menu = {
			scrollbar = true,
			draw = {
				components = {
					kind_icon = {
						text = function(ctx)
							local kind_icon, _, _ = require('mini.icons').get('lsp', ctx.kind)
							return kind_icon
						end,
						-- (optional) use highlights from mini.icons
						highlight = function(ctx)
							local _, hl, _ = require('mini.icons').get('lsp', ctx.kind)
							return hl
						end,
					},
					kind = {
						-- (optional) use highlights from mini.icons
						highlight = function(ctx)
							local _, hl, _ = require('mini.icons').get('lsp', ctx.kind)
							return hl
						end,
					}
				}
			}
		},
		documentation = {
			auto_show = true,
			treesitter_highlighting = true,
		},
		accept = {
			auto_brackets = {
				enabled = true,
			},
			create_undo_point = true,
		}
	},
})
