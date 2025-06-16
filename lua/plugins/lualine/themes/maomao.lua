return function()
	local lualine = require("lualine")

	local colors = {
        bg = '#183539',
        fg = '#eab8bb',

        dark_green = '#165a5d',
        light_green = '#298657',
        bluish_green = '#298677',

        dark_pink = '#c86174',
        pink = '#d47787',
        light_pink = '#cf8592',

        orange = '#c87c61',
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
			n = colors.pink,
			niI = colors.pink,
			niR = colors.pink,
			niV = colors.pink,
			nt = colors.pink,
			ntT = colors.pink,

			-- operator pending variants
			no = colors.pink,
			nov = colors.pink,
			noV = colors.pink,
			["no\22"] = colors.pink,

			-- visual modes
			v = colors.orange,
			vs = colors.orange,
			V = colors.orange,
			Vs = colors.orange,
			--["CTRL-V"] = colors.yellow,
			-- visual block mode for some reason
			["\22"] = colors.orange,
			["\22s"] = colors.orange,

			-- select modes
			s = colors.bluish_green,
			S = colors.bluish_green,
			["\19"] = colors.bluish_green,

			-- all sorts of insert modes
			i = colors.light_green,
			ic = colors.light_green,
			ix = colors.light_green,

			-- all sorts of replace modes
			R = colors.bluish_green,
			Rc = colors.bluish_green,
			Rx = colors.bluish_green,
			Rv = colors.bluish_green,
			Rvc = colors.bluish_green,
			Rvx = colors.bluish_green,

			-- command line(Ex mode)
			c = colors.dark_pink,
			cv = colors.dark_pink,

			-- what does this even mean?
			r = colors.dark_pink,
			rm = colors.dark_pink,
			["r?"] = colors.dark_pink,

			-- i have no idea
			["!"] = colors.pink,

			-- terminal mode
			t = colors.dark_pink,
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
			fg = colors.light_green,
		},
	})

	ins_left({
		--"filename",
		function()
            local buf = vim.api.nvim_get_current_buf()
            local is_modified = vim.api.nvim_buf_get_option(buf, 'modified')
            local status = ""
            if is_modified then
                status = "[+] "
            end
			return status .. vim.api.nvim_buf_get_name(0)
		end,
		color = {
			fg = colors.light_green,
		},
	})

	ins_left({
		"%=",
	})

	--ins_right({
	--	require("music_info").music_info,
	--	color = {
	--		fg = colors.red,
	--	},
	--})

	ins_right({
		"branch",
		icon = "󰊢",
		color = { fg = colors.dark_pink, gui = "bold" },
	})

	ins_right({
		"diagnostics",
		sources = { "nvim_lsp" },
		symbols = { error = " ", warn = " ", info = " ", hint = "󰌶" },
		diagnostics_color = {
			color_error = { fg = colors.dark_pink },
			color_warn = { fg = colors.orange },
			color_info = { fg = colors.bluish_green },
		},
	})

	ins_right({
		require("plugins.lualine.utils.lsp_info"),
		color = { fg = colors.green, gui = "bold" },
	})

	ins_right({
		"location",
		color = {
			fg = colors.light_green,
			gui = "bold",
		},
	})

	lualine.setup(config)
end
