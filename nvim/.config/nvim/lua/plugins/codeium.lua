return {
    'Exafunction/windsurf.nvim',
    event = 'BufEnter',
    dependencies = {
        'nvim-lua/plenary.nvim',
        'hrsh7th/nvim-cmp',
    },
    config = function()
        require('codeium').setup({
            -- Enable nvim-cmp integration
            enable_cmp_source = true,

            -- Virtual text configuration
            virtual_text = {
                enabled = true,
                manual = false,
                -- Disable in certain file types
                filetypes = {
                    help = false,
                    gitcommit = false,
                    gitrebase = false,
                    ["."] = false,
                },
            },

            -- Workspace detection for better context
            workspace_root = {
                use_lsp = true,  -- Use LSP for workspace detection
                paths = {
                    ".git",
                    ".svn",
                    ".hg",
                    "Makefile",
                    "package.json",
                    "Gemfile",
                    "Cargo.toml",
                    "go.mod",
                    "mix.exs",
                }
            }
        })
    end,
}
