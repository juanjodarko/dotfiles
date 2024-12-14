return {
    'akinsho/bufferline.nvim',
    version = "*",
    dependencies = 'nvim-tree/nvim-web-devicons',
    config = function()
        local mocha = require("catppuccin.palettes").get_palette("mocha")

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
                mode = "buffers",                    -- set to "tabs" to only show tabpages instead
                themable = true,                     -- allows highlight groups to be overriden i.e. sets highlights as default
                numbers = "ordinal",
                close_command = "bdelete! %d",       -- can be a string | function, | false see "Mouse actions"
                right_mouse_command = "bdelete! %d", -- can be a string | function | false, see "Mouse actions"
                left_mouse_command = "buffer %d",    -- can be a string | function, | false see "Mouse actions"
                middle_mouse_command = nil,          -- can be a string | function, | false see "Mouse actions"
                indicator = {
                    icon = ' ',                      -- this should be omitted if indicator style is not 'icon'
                    style = 'icon',
                },
                buffer_close_icon = '',
                modified_icon = '●',
                close_icon = '',
                left_trunc_marker = '',
                right_trunc_marker = '',
                max_name_length = 18,
                max_prefix_length = 15, -- prefix used when a buffer is de-duplicated
                truncate_names = true,  -- whether or not tab names should be truncated
                tab_size = 18,
                diagnostics = "nvim_lsp",
                diagnostics_update_in_insert = false,
                diagnostics_indicator = function(count, level, diagnostics_dict, context)
                    local icon = level:match("error") and " " or " "
                    return " " .. icon .. count
                end,
                offsets = {
                    {
                        filetype = 'NvimTree',
                        text = '  Files',
                        highlight = 'StatusLine',
                        text_align = 'left',
                    }
                },
                color_icons = true, -- whether or not to add the filetype icon highlights
                get_element_icon = function(element)
                    local icon, hl = require('nvim-web-devicons').get_icon_by_filetype(element.filetype,
                        { default = false })
                    return icon, hl
                end,
                show_buffer_icons = true, -- disable filetype icons for buffers
                show_buffer_close_icons = true,
                show_close_icon = true,
                show_tab_indicators = true,
                show_duplicate_prefix = true, -- whether to show duplicate buffer prefix
                persist_buffer_sort = true,   -- whether or not custom sorted buffers should persist
                move_wraps_at_ends = false,   -- whether or not the move command "wraps" at the first or last position
                -- can also be a table containing 2 custom separators
                -- [focused and unfocused]. eg: { '|', '|' }
                separator_style = "thick",
                enforce_regular_tabs = false,
                always_show_bufferline = true,
                hover = {
                    enabled = true,
                    delay = 200,
                    reveal = { 'close' }
                },
                sort_by = 'insert_at_end',
                groups = {
                    options = {
                        toggle_hidden_on_enter = true -- when you re-enter a hidden group this options re-opens that group so the buffer is visible
                    },
                    items = {
                        {
                            name = "Tests", -- Mandatory
                            highlight = { underline = true, sp = mocha.blue }, -- Optional
                            priority = 2, -- determines where it will appear relative to other groups (Optional)
                            icon = "", -- Optional
                            matcher = function(buf) -- Mandatory
                                return buf.name:match('%_test') or buf.name:match('%_spec')
                            end,
                        },
                    }
                },
                --custom_areas = {
                --  left = function()
                --    return {
                --      { text = '    ', fg = '#8fff6d' },
                --    }
                --  end,
                --},
            },
        })
    end,
}
