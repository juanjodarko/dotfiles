return {
    'nvim-tree/nvim-tree.lua',
    dependencies = {
        'nvim-tree/nvim-web-devicons'
    },
    config = function()
        require('nvim-tree').setup({
            git = {
                ignore = false
            },
            renderer = {
                highlight_opened_files = 'icon',
                group_empty = true,
                icons = {
                    show = {
                        folder_arrow = false
                    },
                },
                indent_markers = {
                    enable = true
                }
            }
        })

        vim.cmd([[
      highligh NvimTreeIndentMarket guifg=#30323E
      augroup NvimTreeHighlights
        autocmd ColorScheme * highlight NvimTreeIndentMarker guifg=#30323E
      augroup end
    ]])

        -- Standard keymap helper
        local function map(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { desc = desc, silent = true })
        end

        map('n', '<leader>n', ':NvimTreeFindFileToggle<CR>', "Toggle file tree")
    end,
}
