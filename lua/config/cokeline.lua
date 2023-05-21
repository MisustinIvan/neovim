local get_hex = require('cokeline/utils').get_hex

require('cokeline').setup({
  default_hl = {
    fg = function(buffer)
      return
        buffer.is_focused
        and "#181825"
         or "#6C7086"
    end,
    bg = function(buffer)
      return
        buffer.is_focused
        and "#F38BA8"
         or "#313244"
    end
  },

  components = {
    {
      text = ' ',
      bg = get_hex('Normal', 'bg'),
    },
    {
      text = '',
      bg = get_hex('Normal', 'bg'),

      fg = function(buffer)
        return
          buffer.is_focused
          and "#F38BA8"
           or "#313244"
      end
    },
    {
      text = function(buffer)
        return buffer.devicon.icon
      end,
      fg = "#181825",
    },
    {
      text = '',
    },
    {
      text = function(buffer) return buffer.filename .. '  ' end,
      style = function(buffer)
        return buffer.is_focused and 'bold' or nil
      end,
    },
--    {
--      text = '',
--      delete_buffer_on_left_click = true,
--    },
    {
      text = '',
      bg = get_hex('Normal', 'bg'),
      fg = function(buffer)
        return
          buffer.is_focused
          and "#F38BA8"
           or "#313244"
      end
    },
  },
})
