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

        -- Standard keymap helper
        local function map(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { desc = desc, silent = true })
        end

        local builtin = require('telescope.builtin')
        map('n', '<leader>f', builtin.find_files, "Find files")
        map('n', '<leader>b', builtin.buffers, "Find buffers")
        map('n', '<leader>g', builtin.live_grep, "Live grep")
        map('n', '<leader>h', builtin.help_tags, "Help tags")
        map('n', '<leader>s', builtin.lsp_document_symbols, "Document symbols")
        map('n', '<leader>sk', builtin.keymaps, "Search keymaps")

        -- Git pickers (using <leader>gt* prefix for "git telescope")
        map('n', '<leader>gtc', builtin.git_commits, "Git: Commits (Telescope)")
        map('n', '<leader>gtb', builtin.git_branches, "Git: Branches (Telescope)")
        map('n', '<leader>gts', builtin.git_status, "Git: Status (Telescope)")
        map('n', '<leader>gtS', builtin.git_stash, "Git: Stash (Telescope)")
        map('n', '<leader>gtf', builtin.git_bcommits, "Git: Buffer commits (Telescope)")
    end,
}
