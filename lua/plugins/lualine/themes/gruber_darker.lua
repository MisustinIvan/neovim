return function()
	local lualine = require("lualine")

	local colors = {
		black = "#000000",
		white = "#ffffff",
		fg = "#e4e4e4",
		["fg1"] = "#f4f4ff",
		["fg2"] = "#f5f5f5",

		["bg-1"] = "#101010",
		bg = "#181818",
		["bg+1"] = "#282828",
		["bg2"] = "#453d41",
		["bg3"] = "#484848",
		["bg4"] = "#52494e",

		["red-1"] = "#c73c3f",
		red = "#f43841",
		["red+1"] = "#ff4f58",

		green = "#73d936",
		yellow = "#ffdd33",
		brown = "#cc8c3c",
		quartz = "#95a99f",

		["niagara-2"] = "#303540",
		["niagara-1"] = "#565f73",
		niagara = "#96a6c8",
		wisteria = "#9e95c7",
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
			s = colors.niagara,
			S = colors.niagara,
			["\19"] = colors.niagara,

			-- all sorts of insert modes
			i = colors.green,
			ic = colors.green,
			ix = colors.green,

			-- all sorts of replace modes
			R = colors.quartz,
			Rc = colors.quartz,
			Rx = colors.quartz,
			Rv = colors.quartz,
			Rvc = colors.quartz,
			Rvx = colors.quartz,

			-- command line(Ex mode)
			c = colors.wisteria,
			cv = colors.wisteria,

			-- what does this even mean?
			r = colors.wisteria,
			rm = colors.wisteria,
			["r?"] = colors.wisteria,

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
			fg = colors.yellow,
		},
	})

	ins_left({
		--"filename",
		function()
			return vim.api.nvim_buf_get_name(0)
		end,
		color = {
			fg = colors.green,
		},
	})

	ins_left({
		"%=",
	})

	ins_right({
		require("music_info").music_info,
		color = {
			fg = colors.red,
		},
	})

	ins_right({
		"branch",
		icon = "󰊢",
		color = { fg = colors.wisteria, gui = "bold" },
	})

	ins_right({
		"diagnostics",
		sources = { "nvim_lsp" },
		symbols = { error = " ", warn = " ", info = " ", hint = "󰌶" },
		diagnostics_color = {
			color_error = { fg = colors.red },
			color_warn = { fg = colors.yellow },
			color_info = { fg = colors.niagara },
		},
	})

	ins_right({
		require("plugins.lualine.utils.lsp_info"),
		color = { fg = colors.green, gui = "bold" },
	})

	ins_right({
		"location",
		color = {
			fg = colors.wisteria,
			gui = "bold",
		},
	})

	lualine.setup(config)
end
