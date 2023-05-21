local lualine = require('lualine')

--previous colors
--bg       = '#202328',

--local colors = {
--    bg       = '#1e1e2e',
--    fg       = '#bbc2cf',
--    yellow   = '#ECBE7B',
--    cyan     = '#008080',
--    darkblue = '#081633',
--    green    = '#98be65',
--    orange   = '#FF8800',
--    violet   = '#a9a1e1',
--    magenta  = '#c678dd',
--    blue     = '#51afef',
--    red      = '#ec5f67',
--}

local colors = {
    rosewater = "#F5E0DC",
	flamingo = "#F2CDCD",
	pink = "#F5C2E7",
	mauve = "#CBA6F7",
	red = "#F38BA8",
	maroon = "#EBA0AC",
	peach = "#FAB387",
	yellow = "#F9E2AF",
	green = "#A6E3A1",
	teal = "#94E2D5",
	sky = "#89DCEB",
	sapphire = "#74C7EC",
	blue = "#89B4FA",
	lavender = "#B4BEFE",

	text = "#CDD6F4",
	subtext1 = "#BAC2DE",
	subtext0 = "#A6ADC8",
	overlay2 = "#9399B2",
	overlay1 = "#7F849C",

	overlay0 = "#6C7086",
	surface2 = "#585B70",
	surface1 = "#45475A",
	surface0 = "#313244",

	base = "#1E1E2E",
	mantle = "#181825",
	crust = "#11111B",
}

local conditions = {
  buffer_not_empty = function()
    return vim.fn.empty(vim.fn.expand('%:t')) ~= 1
  end,
  hide_in_width = function()
    return vim.fn.winwidth(0) > 80
  end,
  check_git_workspace = function()
    local filepath = vim.fn.expand('%:p:h')
    local gitdir = vim.fn.finddir('.git', filepath .. ';')
    return gitdir and #gitdir > 0 and #gitdir < #filepath
  end,
}

local config = {
    options = {
        -- Disable sections and component separators
        component_separators = '',
        section_separators = '',
        theme = {
          -- We are going to use lualine_c an lualine_x as left and
          -- right section. Both are highlighted by c theme .  So we
          -- are just setting default looks o statusline
          normal = { c = { fg = colors.fg, bg = colors.bg } },
          inactive = { c = { fg = colors.fg, bg = colors.bg } },
        },
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

-- Inserts a component in lualine_c at left section
local function ins_left(component)
    table.insert(config.sections.lualine_c, component)
end

-- Inserts a component in lualine_x at right section
local function ins_right(component)
    table.insert(config.sections.lualine_x, component)
end


--ins_left {
--    function()
--        return '▊'
--    end,
--    color = { fg = colors.blue}, -- Sets highlighting of component
--    padding = { left = 0, right = 1 }, -- We don't need space before this
--}

ins_left {
    function ()
        return ' '
    end,
    padding = { right = 0 , left = 0 },
}

ins_left {
    --'mode',
    --function()
    --    return ''
    --end,
    function ()
        return ''
    end,
    color = function()
    -- auto change color according to neovims mode
        local mode_color = {
            n = colors.red,
            i = colors.green,
            v = colors.blue,
            [''] = colors.blue,
            V = colors.blue,
            c = colors.mauve,
            no = colors.red,
            s = colors.peach,
            S = colors.peach,
            [''] = colors.peach,
            ic = colors.yellow,
            R = colors.mauve,
            Rv = colors.mauve,
            cv = colors.red,
            ce = colors.red,
            r = colors.sapphire,
            rm = colors.sapphire,
            ['r?'] = colors.sapphire,
            ['!'] = colors.red,
            t = colors.red,
        }
        return { fg = mode_color[vim.fn.mode()], bg = colors.surface0 }
    end,
    separator = { right = "", left = "" },
    padding = { right = 0 , left = 0 },
}

ins_left {
    function ()
        return ' '
    end,
    padding = { right = 0 , left = 0 },
    color = { bg = colors.teal }
}

ins_left {
    'filesize',
    color = { fg = colors.mantle, bg = colors.teal },
    separator = { right = "", left = "" },
    padding = { right = 1 , left = 0 },
}

--ins_left {
--    function ()
--        return ' '
--    end,
--    padding = { right = 0 , left = 0 },
--}

ins_left {
    'filename',
    color = { fg = colors.mantle, gui = 'bold', bg = colors.red },
    separator = { right = "", left = "" },
    padding = { right = 0 , left = 0 },
}

ins_left {
    function ()
        return '|'
    end,
    padding = { right = 0 , left = 0 },
    color = { bg = colors.red, fg = colors.mantle }
}

ins_left {
    'location',
    color = { fg = colors.mantle, gui = 'bold', bg = colors.red },
    separator = { right = "", left = "" },
    padding = { right = 0 , left = 0 },
}

--ins_left {
--    function ()
--        return ' '
--    end,
--    padding = { right = 0 , left = 0 },
--}

ins_left {
    'progress',
    color = { bg = colors.sky, fg = colors.mantle },
    separator = { right = "", left = "" },
    padding = { right = 0 , left = 1 },
}

ins_left {
    function ()
        return ' '
    end,
    padding = { right = 0 , left = 0 },
    separator = { right = "", left = "" },
    color = { bg = colors.surface0 }
}

ins_left {
    'diagnostics',
    sources = { 'nvim_lsp' },
    symbols = { error = ' ', warn = ' ', info = ' ' },
    color = { bg = colors.surface0 },
    diagnostics_color = {
        color_error = { fg = colors.red },
        color_warn = { fg = colors.flamingo },
        color_info = { fg = colors.sapphire },
    },
    separator = { right = "", left = "" },
    padding = { right = 0 , left = 0 },
}

ins_left {
    function()
        return '%='
    end,
}

ins_right {
    function()
        local msg = 'None'
        local buf_ft = vim.api.nvim_buf_get_option(0, 'filetype')
        local clients = vim.lsp.get_active_clients()
        if next(clients) == nil then
            return msg
        end
        for _, client in ipairs(clients) do
            local filetypes = client.config.filetypes
            if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
                return client.name
            end
        end
        return msg
    end,
    icon = '',
    color = { bg = colors.sky, gui = 'bold', fg = colors.mantle },
    separator = { right = "", left = "" },
    padding = { right = 0 , left = 0 },
}

ins_right{
    function ()
        return ' '
    end,
    padding = { right = 0 , left = 0 },
    color = { bg = colors.surface0 }
}

ins_right {
    'o:encoding', -- option component same as &encoding in viml
    color = { bg = colors.teal, gui = 'bold', fg = colors.mantle },
    separator = { right = "", left = "" },
    padding = { right = 1 , left = 0 },
}

--ins_right{
--    function ()
--        return ' '
--    end,
--    padding = { right = 0 , left = 0 },
--}

ins_right {
    'fileformat',
    icons_enabled = false, -- I think icons are cool but Eviline doesn't have them. sigh
    color = { bg = colors.maroon, gui = 'bold', fg = colors.mantle },
    separator = { right = "", left = "" },
    padding = { right = 0 , left = 0 },
}

ins_right{
    function ()
        return ' '
    end,
    padding = { right = 0 , left = 0 },
    color = { bg = colors.mauve },
    separator = { right = "", left = "" },
}

ins_right {
    'branch',
    icon = '',
    color = { bg = colors.mauve, gui = 'bold', fg = colors.mantle },
    separator = { right = "", left = "" },
    padding = { right = 0 , left = 0 },
}

--ins_right{
--    function ()
--        return ' '
--    end,
--    padding = { right = 0 , left = 0 },
--}

ins_right {
    'diff',
    -- Is it me or the symbol for modified is really weird
    symbols = { added = ' ', modified = '柳', removed = ' ' },
    diff_color = {
        added = { fg = colors.green },
        modified = { fg = colors.orange },
        removed = { fg = colors.red },
    },
    color = { bg = colors.surface0 },
    separator = { right = "", left = "" },
    padding = { right = 0 , left = 1 },
}

ins_right{
    function ()
        return ' '
    end,
    padding = { right = 0 , left = 0 },
}
--ins_right {
--    function()
--        return '▊'
--    end,
--    color = { fg = colors.blue},
--    padding = { left = 1 },
--}

require('lualine').setup(config)
