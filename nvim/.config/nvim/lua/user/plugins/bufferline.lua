local mocha = require("catppuccin.palettes").get_palette "mocha"

require('bufferline').setup({
  options = {
    highlights = require('catppuccin.groups.integrations.bufferline').get({
      styles = { "italic", "bold" },
      custom = {
        mocha = {
            background = { fg = mocha.text },
        },
      }
    }),
    diagnostics = "nvim_lsp",
    diagnostics_indicator = function(count, level, diagnostics_dict, context)
      local icon = level:match("error") and  " " or " "
      return " " .. icon .. count
    end,
    indicator = {
      icon = ' ',
    },
    show_close_icon = false,
    tab_size = 0,
    max_name_length = 25,
    offsets = {
      {
        filetype = 'NvimTree',
        text = '  Files',
        highlight = 'StatusLine',
        text_align = 'left',
      },
    },
    separator_style = 'thick',
    modified_icon = '',
    custom_areas = {
      left = function()
        return {
          { text = '    ', fg = '#8fff6d' },
        }
      end,
    },
    items = {
      {
        name = 'Tests',
        highlight = { underline = true, sp = 'blue' },
        priority = 2,
        icon = "",
        matcher = function(buf)
          return buf.filename:match('%_test') or buf.filename:match('%_spec')
        end,
      }
    },
  },
})
