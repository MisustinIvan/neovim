return {
	"hrsh7th/nvim-cmp",
	dependencies = {
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
			"williamboman/mason-lspconfig.nvim",
			dependencies = {
				{
					"williamboman/mason.nvim",
					config = function()
						require("mason").setup()
					end,
				},
			},
			config = function()
				require("mason-lspconfig").setup({
					ensure_installed = { "lua_ls" },
				})
			end,
		},
        {
            "MattiasMTS/cmp-dbee",
            dependencies = {
                {"kndndrj/nvim-dbee"}
            },
            ft = "sql", -- optional but good to have
            opts = {}, -- needed
        },
		{
			--"github/copilot.vim",
			--config = function()
			--	vim.g.copilot_no_tab_map = true
			--	vim.api.nvim_set_keymap(
			--		"i",
			--		"<C-J>",
			--		'copilot#Accept("<CR>")',
			--		{ silent = true, expr = true, desc = "accept copilot suggestion" }
			--	)
			--end,
		},
		{
			"L3MON4D3/LuaSnip",
		},
		"onsails/lspkind.nvim",
	},
	config = function()
		local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())
		capabilities.textDocument.completion.completionItem.snippetSupport = true

		vim.o.completeopt = "menuone,noinsert,noselect"
		vim.opt.shortmess = vim.opt.shortmess + "c"

		local function on_attach(client, buffer)
			vim.api.nvim_set_keymap(
				"i",
				"<c-k>",
				"<cmd>lua vim.lsp.buf.signature_help()<cr>",
				{ noremap = true, silent = true, desc = "Hover" }
			)
			vim.api.nvim_set_keymap(
				"n",
				"K",
				"<cmd>lua vim.lsp.buf.hover()<cr>",
				{ noremap = true, silent = true, desc = "Hover" }
			)
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
			vim.api.nvim_set_keymap(
				"n",
				"<leader>ca",
				"<cmd>lua vim.lsp.buf.code_action()<CR>",
				{ noremap = true, silent = true, desc = "Code actions" }
			)
		end

		local signs = { Error = " ", Warn = " ", Hint = "󰌶 ", Info = " " }
		for type, icon in pairs(signs) do
			local hl = "DiagnosticSign" .. type
			vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
		end

		local lspconfig = require("lspconfig")

		lspconfig.lua_ls.setup({
			capabilities = capabilities,
			settings = {
				Lua = {
					workspace = {
						library = vim.tbl_deep_extend("force", vim.api.nvim_get_runtime_file("", true), {
							"${3rd}/luv/library",
							"${3rd}/busted/library",
							"/usr/share/awesome/lib",
							"/usr/share/lua",
						}),
					},
					diagnostics = {
						globals = {
							"vim",
							"awesome",
							"awful",
							"client",
							"screen",
							"tag",
							"root",
						},
					},
				},
			},
			on_attach = on_attach,
		})

		lspconfig.omnisharp.setup({
			capabilities = capabilities,
			on_attach = on_attach,
		})

		lspconfig.gopls.setup({
			capabilities = capabilities,
			on_attach = on_attach,
		})

		lspconfig.ocamllsp.setup({
			capabilities = capabilities,
			on_attach = on_attach,
		})

		lspconfig.zls.setup({
			capabilities = capabilities,
			on_attach = on_attach,
		})

		lspconfig.hls.setup({
			capabilities = capabilities,
			on_attach = on_attach,
		})

		lspconfig.elixirls.setup({
			capabilities = capabilities,
			on_attach = on_attach,
		})

		lspconfig.rust_analyzer.setup({
			capabilities = capabilities,
			on_attach = on_attach,
		})

		lspconfig.denols.setup({
			capabilities = capabilities,
			on_attach = on_attach,
		})

		lspconfig.texlab.setup({})

		lspconfig.clangd.setup({
			capabilities = capabilities,
			on_attach = on_attach,
		})

		lspconfig.jdtls.setup({
			capabilities = capabilities,
			on_attach = on_attach,
		})

		lspconfig.html.setup({
			capabilities = capabilities,
			on_attach = on_attach,
		})

		lspconfig.ols.setup({
			capabilities = capabilities,
			on_attach = on_attach,
		})

		lspconfig.basedpyright.setup({
			capabilities = capabilities,
			on_attach = on_attach,
		})

		local cmp = require("cmp")

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

			window = {
				completion = {
					border = "rounded",
				},
				documentation = {
					border = "rounded",
				},
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
				{ name = "nvim_lsp_signature_help" },
				{ name = "calc" },
                { name = "cmp-dbee"},
			},
		})
	end,
}

--return {
--	"neovim/nvim-lspconfig",
--	version = "*",
--	dependencies = {
--		"saghen/blink.cmp",
--		{
--			"williamboman/mason.nvim",
--			config = function()
--				require("mason").setup()
--			end,
--		},
--		{
--			"j-hui/fidget.nvim",
--			config = function()
--				require("fidget").setup({})
--			end,
--		},
--		{
--			"folke/neodev.nvim",
--			config = function()
--				require("neodev").setup()
--			end,
--		},
--		{
--			"github/copilot.vim",
--			config = function()
--				vim.g.copilot_no_tab_map = true
--				vim.api.nvim_set_keymap(
--					"i",
--					"<C-J>",
--					'copilot#Accept("<CR>")',
--					{ silent = true, expr = true, desc = "accept copilot suggestion" }
--				)
--			end,
--		},
--	},
--	config = function()
--		local capabilities = require("blink.cmp").get_lsp_capabilities()
--		local lspconfig = require("lspconfig")
--
--		lspconfig.lua_ls.setup({ capabilities = capabilities })
--		lspconfig.gopls.setup({ capabilities = capabilities })
--
--		require("blink.cmp").setup({ signature = { enabled = true } })
--	end,
--}
