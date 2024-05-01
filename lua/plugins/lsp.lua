return {
	"hrsh7th/nvim-cmp",
	dependencies = {
		"hrsh7th/cmp-cmdline",
		"hrsh7th/cmp-path",
		"hrsh7th/cmp-buffer",
		"hrsh7th/cmp-calc",
		"hrsh7th/cmp-nvim-lsp",
		{
			"j-hui/fidget.nvim",
			config = function()
				require("fidget").setup({})
			end,
		},
		"neovim/nvim-lspconfig",
		{
			"folke/neodev.nvim",
			config = function()
				require("neodev").setup()
			end,
		},
		{
			"williamboman/mason.nvim",
			config = function()
				require("mason").setup()
			end,
		},

		{
			"williamboman/mason-lspconfig.nvim",
			config = function()
				require("mason-lspconfig").setup({
					ensure_installed = { "lua_ls", "pyright", "rust_analyzer" },
				})
			end,
		},
		"L3MON4D3/LuaSnip",
		"onsails/lspkind.nvim",
	},
	config = function()
		local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())
		capabilities.textDocument.completion.completionItem.snippetSupport = true

		vim.o.completeopt = "menuone,noinsert,noselect"
		vim.opt.shortmess = vim.opt.shortmess + "c"

		local function on_attach(client, buffer)
			--			vim.api.nvim_set_keymap(
			--				"n",
			--				"K",
			--				"<cmd>lua vim.lsp.buf.hover()<cr>",
			--				{ noremap = true, silent = true, desc = "Hover" }
			--			)
			vim.api.nvim_set_keymap(
				"n",
				"<leader>gd",
				"<cmd>lua vim.lsp.buf.definition()<cr>",
				{ noremap = true, silent = true, desc = "Go to definition" }
			)
			vim.api.nvim_set_keymap(
				"n",
				"<leader>gt",
				"<cmd>vim.lsp.buf.type_definition<cr>",
				{ noremap = true, silent = true, desc = "Go to type definition" }
			)
			vim.api.nvim_set_keymap(
				"n",
				"<leader>do",
				"<cmd>lua vim.diagnostic.open_float()<CR>",
				{ noremap = true, silent = true, desc = "Show diagnostics" }
			)
		end

		local signs = { Error = " ", Warn = " ", Hint = "󰌶 ", Info = " " }
		for type, icon in pairs(signs) do
			local hl = "DiagnosticSign" .. type
			vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
		end

		require("lspconfig").lua_ls.setup({
			capabilities = capabilities,
			settings = {
				Lua = {
					diagnostics = {
						globals = { "vim" },
					},
				},
			},
			on_attach = on_attach,
		})

		require("lspconfig").pyright.setup({
			capabilities = capabilities,
			settings = {
				Lua = {
					diagnostics = {
						globals = { "vim" },
					},
				},
			},
			on_attach = on_attach,
		})

		require("lspconfig").gopls.setup({
			capabilities = capabilities,
			on_attach = on_attach,
		})

		local cmp = require("cmp")

		-- suggestions for searching in cmdline
		cmp.setup.cmdline("/", {
			mapping = cmp.mapping.preset.cmdline(),
			sources = {
				{ name = "buffer" },
			},
		})
		-- suggestions for cmdline [EVALUATING]
		--		cmp.setup.cmdline(":", {
		--			mapping = cmp.mapping.preset.cmdline(),
		--			sources = cmp.config.sources({
		--				{ name = "path" },
		--			}, {
		--				{
		--					name = "cmdline",
		--					option = {
		--						ignore_cmds = { "Man", "!" },
		--					},
		--				},
		--			}),
		--		})

		cmp.setup({
			mapping = {
				-- sure about these ones
				["<C-p>"] = cmp.mapping.select_prev_item(),
				["<C-n>"] = cmp.mapping.select_next_item(),
				["<S-Tab>"] = cmp.mapping.select_prev_item(),
				["<Tab>"] = cmp.mapping.select_next_item(),
				["<CR>"] = cmp.mapping.confirm({
					behavior = cmp.ConfirmBehavior.Insert,
					select = true,
				}),

				-- not sure about these ones
				["<C-d>"] = cmp.mapping.scroll_docs(-4),
				["<C-f>"] = cmp.mapping.scroll_docs(4),
				["<C-Space>"] = cmp.mapping.complete(),
				["<C-e>"] = cmp.mapping.close(),
			},

			snippet = {
				expand = function(args)
					require("luasnip").lsp_expand(args.body)
				end,
			},

			formatting = {
				format = require("lspkind").cmp_format({
					mode = "symbol",
					maxwidth = 50,
					ellipsis_char = "...",
					show_labelDetails = true,
					before = function(entry, vim_item)
						return vim_item
					end,
				}),
			},

			sources = {
				{ name = "nvim_lsp" },
				{ name = "luasnip" },
				{ name = "path" },
				--{ name = "buffer" },
				--{ name = "emoji" },
				--{ name = "neorg" },
				{ name = "nvim_lsp_signature_help" },
				--{ name = "cmp_buffer" },
				{ name = "calc" },
			},
		})
	end,
}
