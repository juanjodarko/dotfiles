return {
    'nvim-lualine/lualine.nvim',
    dependencies = {
        'nvim-tree/nvim-web-devicons'
    },
    config = function()
        require('lualine').setup({
            options = {
                icons_enabled = true,
                theme = 'catppuccin',
                component_separators = { left = '', right = '' },
                section_separators = { left = '', right = '' },
                disabled_filetypes = {
                    statusline = {},
                    winbar = {},
                },
                ignore_focus = {},
                always_divide_middle = true,
                globalstatus = false,
                refresh = {
                    statusline = 1000,
                    tabline = 1000,
                    winbar = 1000,
                }
            },
            sections = {
                lualine_a = { 'mode' },
                lualine_b = { 'branch', 'diff' },
                lualine_c = {
                    -- Noice integration: show recording, search count, and command
                    {
                        require("noice").api.statusline.mode.get,
                        cond = require("noice").api.statusline.mode.has,
                        color = { fg = "#ff9e64" },
                    },
                    {
                        require("noice").api.status.command.get,
                        cond = require("noice").api.status.command.has,
                        color = { fg = "#7dcfff" },
                    },
                    -- Claude collab: show editing activity
                    {
                        require("claude-collab.statusline").get,
                        cond = require("claude-collab.statusline").has,
                        color = { fg = "#cba6f7" },
                    },
                    -- Claude sessions: animated cue when a session waits for input
                    {
                        require("claude-collab.statusline").sessions,
                        cond = require("claude-collab.statusline").sessions_has,
                        color = { fg = "#f9e2af" },
                    },
                },
                lualine_x = { 'encoding', 'fileformat', 'filetype' },
                lualine_y = {
                    -- Noice integration: show search count
                    {
                        require("noice").api.statusline.search.get,
                        cond = require("noice").api.statusline.search.has,
                        color = { fg = "#9ece6a" },
                    },
                },
                lualine_z = { 'location' }
            },
            inactive_sections = {
                lualine_a = {},
                lualine_b = {},
                lualine_c = { 'filename' },
                lualine_x = { 'location' },
                lualine_y = {},
                lualine_z = {}
            },
            tabline = {},
            winbar = {
                lualine_a = {},
                lualine_b = {
                    {
                        'diagnostics',
                        sources = { 'nvim_lsp', 'vim_lsp' },
                        sections = { 'error', 'warn', 'info', 'hint' },
                        diagnostics_color = {
                            error = 'DiagnosticError',
                            warn = 'DiagnosticWarn',
                            info = 'DiagnosticInfo',
                            hint = 'DiagnosticHint'
                        },
                        symbols = {
                            error = ' ',
                            warn = ' ',
                            info = ' ',
                            hint = ' '
                        },
                        colored = true,
                        update_in_insert = true,
                        always_visible = false
                    }
                },
                lualine_c = {},
                lualine_x = {},
                lualine_y = {},
                lualine_z = { { 'datetime', style = 'default' } }
            },
            inactive_winbar = {
                lualine_a = {
                    {
                        'filename',
                        file_status = true,
                        newfile_status = false,
                        path = 0,
                        shorting_target = 40,
                        symbols = {
                            modified = '[+]',
                            readonly = '[-]',
                            unnamed = '[No name]',
                            newfile = '[New]'
                        }
                    }
                }
            },
            extensions = {}
        })
    end,
}
