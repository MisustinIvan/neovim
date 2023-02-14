require('bufferline').setup {
    options = {
        mode = "buffers", -- set to "tabs" to only show tabpages instead
        numbers = "none",
        indicator = {
            --icon = '▎', -- this should be omitted if indicator style is not 'icon'
            --style = 'icon' | 'underline' | 'none',
            style = '',
        },
        buffer_close_icon = '',
        modified_icon = '●',
        close_icon = ' ',
        left_trunc_marker = '',
        right_trunc_marker = '',
        truncate_names = true, -- whether or not tab names should be truncated
        tab_size = 18,
        diagnostics = "nvim_lsp",
        diagnostics_update_in_insert = false,
        -- The diagnostics indicator can be set to nil to keep the buffer name highlight but delete the highlighting
        diagnostics_indicator = function(count, level, diagnostics_dict, context)
            return "("..count..")"
        end,

        offsets = { {
                filetype = "neo-tree filesystem",
                text = "neo-tree filesystem",
                text_align = "left",
                separator = true,
            }
        },

        color_icons = true, -- whether or not to add the filetype icon highlights
        show_buffer_icons = true, -- disable filetype icons for buffers
        show_buffer_close_icons = false,
        show_buffer_default_icon = true, -- whether or not an unrecognised filetype should show a default icon
        show_close_icon = true,
        show_tab_indicators = true,
        show_duplicate_prefix = true, -- whether to show duplicate buffer prefix
        persist_buffer_sort = true, -- whether or not custom sorted buffers should persist
        -- can also be a table containing 2 custom separators
        -- [focused and unfocused]. eg: { '|', '|' }
        --separator_style = "slant" | "thick" | "thin" | { 'any', 'any' },
        separator_style = "thin",
        --enforce_regular_tabs = false | true,
        --always_show_bufferline = true | false,
        ---hover = {
        ---    enabled = true,
        ---    delay = 200,
        ---    reveal = {'close'}
        ---},
        sort_by = 'insert_after_current'
    }
}
