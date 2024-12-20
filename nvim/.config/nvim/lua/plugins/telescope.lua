return {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.2',
    dependencies = {
        'nvim-lua/plenary.nvim',
        'nvim-tree/nvim-web-devicons',
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make'
    },
    config = function()
        local telescope = require('telescope')
        -- local actions = require('actions')

        vim.cmd([[
          highlight link TelescopePromptTitle PMenuSel
          highlight link TelescopePreviewTitle PMenuSel
          highlight link TelescopePromptNormal NormalFloat
          highlight link TelescopePromptBorder FloatBorder
          highlight link TelescopeNormal CursorLine
          highlight link TelescopeBorder CursorLineBg
        ]])

        telescope.setup({
            defaults = {
                path_display = { truncate = 1 },
                prompt_prefix = '   ',
                selection_caret = '  ',
                layout_config = {
                    prompt_position = 'top',
                },
                sorting_strategy = 'ascending',
                file_ignore_patterns = { '.git/' },
                preview = {
                    treesitter = true,
                },
            },
            pickers = {
                find_files = {
                    hidden = true,
                },
                buffers = {
                    previewer = false,
                    layout_config = {
                        width = 80,
                    },
                },
                oldfiles = {
                    prompt_title = 'History',
                },
                lsp_references = {
                    previewer = true,
                },
            },
        })
        local builtin = require('telescope.builtin')
        vim.keymap.set('n', '<leader>f', builtin.find_files, {})
        -- vim.keymap.set('n', '<leader>F', builtin.find_files, { no_ignore = true, prompt_title = 'All files' })
        vim.keymap.set('n', '<leader>b', builtin.buffers, {})
        vim.keymap.set('n', '<leader>g', builtin.live_grep, {})
        vim.keymap.set('n', '<leader>h', builtin.help_tags, {})
        vim.keymap.set('n', '<leader>s', builtin.lsp_document_symbols, {})
    end,
}
