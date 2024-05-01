return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		local lualine = require("lualine")

		-- orig
		local colors = {
			black = "#16161D",
			white = "#c5c9c5",
			background = "#e7dba0",
			blue = "#6693bf",
			green = "#98c379",
			yellow = "#e5c07b",
			orange = "#e98a00",
			red = "#FF5D62",
			purple = "#c678dd",
			pink = "#D27E99",
			coral = "#f78166",
		}

		local conditions = {
			buffer_not_empty = function()
				return vim.fn.empty(vim.fn.expand("%:t")) ~= 1
			end,
			hide_in_width = function()
				return vim.fn.winwidth(0) > 80
			end,
			check_git_workspace = function()
				local filepath = vim.fn.expand("%:p:h")
				local gitdir = vim.fn.finddir(".git", filepath .. ";")
				return gitdir and #gitdir > 0 and #gitdir < #filepath
			end,
		}

		local config = {
			options = {
				component_separators = "",
				section_separators = "",
			},

			sections = {
				-- these are to remove the defaults
				lualine_a = {},
				lualine_b = {},
				lualine_y = {},
				lualine_z = {},
				-- These will be filled later
				lualine_c = {},
				lualine_x = {},
			},

			inactive_sections = {
				-- these are to remove the defaults
				lualine_a = {},
				lualine_b = {},
				lualine_y = {},
				lualine_z = {},
				lualine_c = {},
				lualine_x = {},
			},
		}

		local mode_color = function()
			-- auto change color according to neovims mode
			local mode_color = {
				-- normal modes
				n = colors.red,
				niI = colors.red,
				niR = colors.red,
				niV = colors.red,
				nt = colors.red,
				ntT = colors.red,

				-- operator pending variants
				no = colors.red,
				nov = colors.red,
				noV = colors.red,
				["no\22"] = colors.red,

				-- visual modes
				v = colors.yellow,
				vs = colors.yellow,
				V = colors.yellow,
				Vs = colors.yellow,
				--["CTRL-V"] = colors.yellow,
				-- visual block mode for some reason
				["\22"] = colors.yellow,
				["\22s"] = colors.yellow,

				-- select modes
				s = colors.pink,
				S = colors.pink,
				["\19"] = colors.pink,

				-- all sorts of insert modes
				i = colors.green,
				ic = colors.green,
				ix = colors.green,

				-- all sorts of replace modes
				R = colors.coral,
				Rc = colors.coral,
				Rx = colors.coral,
				Rv = colors.coral,
				Rvc = colors.coral,
				Rvx = colors.coral,

				-- command line(Ex mode)
				c = colors.purple,
				cv = colors.purple,

				-- what does this even mean?
				r = colors.purple,
				rm = colors.purple,
				["r?"] = colors.purple,

				-- i have no idea
				["!"] = colors.red,

				-- terminal mode
				t = colors.red,
			}
			return { fg = mode_color[vim.fn.mode("test")] }
		end

		-- Inserts a component in lualine_c at left section
		local function ins_left(component)
			table.insert(config.sections.lualine_c, component)
		end

		-- Inserts a component in lualine_x at right section
		local function ins_right(component)
			table.insert(config.sections.lualine_x, component)
		end

		ins_left({
			"mode",
			--function()
			--	return ""
			--end,
			color = mode_color,
		})

		ins_left({
			"%=",
		})

		ins_left({
			"branch",
			icon = "󰊢",
			color = { fg = colors.purple, gui = "bold" },
		})

		ins_left({
			function()
				local filename = vim.api.nvim_buf_get_name(0)
				local extension = filename:match(".+%.(.*)")
				local icon = require("nvim-web-devicons").get_icon(filename, extension)
				if icon ~= nil then
					return icon
				else
					return "󱀶"
				end
			end,
			color = {
				fg = colors.red,
			},
		})

		ins_left({
			"filename",
			color = {
				fg = colors.blue,
			},
		})

		ins_left({
			"diagnostics",
			sources = { "nvim_lsp" },
			symbols = { error = " ", warn = " ", info = " ", hint = "󰌶" },
			diagnostics_color = {
				color_error = { fg = colors.red },
				color_warn = { fg = colors.yellow },
				color_info = { fg = colors.blue },
			},
		})

		ins_right({
			function()
				local msg = " "
				local buf_ft = vim.api.nvim_buf_get_option(0, "filetype")
				local clients = vim.lsp.get_active_clients()
				if next(clients) == nil then
					return msg
				end
				for _, client in ipairs(clients) do
					local filetypes = client.config.filetypes
					if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
						return msg .. " " .. client.name
					end
				end
				return msg
			end,
			color = { fg = colors.purple, gui = "bold" },
		})

		ins_right({
			"location",
			color = {
				fg = colors.purple,
				gui = "bold",
			},
		})

		lualine.setup(config)
	end,
}
