return {
    'catppuccin/nvim',
    lazy = false,
    name = 'catppuccin',
    priority = 1000,
    config = function()
        -- Get flavor from centralized theme system
        local theme = require("user.theme")
        local flavor = theme.get_flavor()

        require("catppuccin").setup({
            flavour = flavor, -- Dynamically loaded from ~/.config/themes/current_flavor.txt
            background = {
                light = "latte",
                dark = "mocha",
            },
            transparent_background = true,
            show_end_of_buffer = false,
            term_colors = true,  -- Enable for better terminal integration
            dim_inactive = {
                enabled = false,
                shade = "dark",
                percentage = 0.15,
            },
            no_italic = false,
            no_bold = false,
            no_underline = false,
            styles = {
                comments = { "italic" },
                conditionals = { "italic" },
                loops = {},
                functions = {},
                keywords = {},
                strings = {},
                variables = {},
                numbers = {},
                booleans = {},
                properties = {},
                types = {},
                operators = {},
            },
            color_overrides = {},
            custom_highlights = {},
            default_integrations = true,  -- Enable default integrations
            integrations = {
                -- ==========================================
                -- CORE INTEGRATIONS
                -- ==========================================
                -- Completion
                cmp = true,

                -- Syntax Highlighting
                treesitter = true,
                treesitter_context = false,

                -- LSP
                native_lsp = {
                    enabled = true,
                    virtual_text = {
                        errors = { "italic" },
                        hints = { "italic" },
                        warnings = { "italic" },
                        information = { "italic" },
                        ok = { "italic" },
                    },
                    underlines = {
                        errors = { "underline" },
                        hints = { "underline" },
                        warnings = { "underline" },
                        information = { "underline" },
                        ok = { "underline" },
                    },
                    inlay_hints = {
                        background = true,
                    },
                },
                lsp_trouble = true,
                mason = true,

                -- ==========================================
                -- UI INTEGRATIONS
                -- ==========================================
                telescope = {
                    enabled = true,
                    style = "nvchad"
                },
                which_key = true,
                nvimtree = true,
                bufferline = true,
                notify = true,
                noice = true,
                dressing = true,
                mini = {
                    enabled = true,
                    indentscope_color = "lavender",
                },

                -- ==========================================
                -- GIT INTEGRATIONS
                -- ==========================================
                gitsigns = true,
                octo = true,

                -- ==========================================
                -- MARKDOWN & NOTES
                -- ==========================================
                markdown = true,

                -- ==========================================
                -- ADDITIONAL TOOLS
                -- ==========================================
                indent_blankline = {
                    enabled = true,
                    scope_color = "lavender",
                    colored_indent_levels = false,
                },
                fzf = true,
                snacks = true,
                colorizer = true,  -- nvim-colorizer.lua
                neoscroll = false,
                flash_nvim = true,  -- Enhanced navigation

                -- ==========================================
                -- AI INTEGRATIONS
                -- ==========================================
                -- Note: avante might not have official integration yet,
                -- but will work with default_integrations = true

                -- ==========================================
                -- DEBUGGING & TESTING
                -- ==========================================
                dap = true,
                dap_ui = true,
                neotest = true,

                -- ==========================================
                -- DISABLED (not installed)
                -- ==========================================
                aerial = false,
                alpha = false,
                barbar = false,
                barbecue = false,
                beacon = false,
                blink_cmp = false,
                coc_nvim = false,
                dashboard = false,
                dap = false,
                dap_ui = false,
                dropbar = false,
                fidget = false,
                flash = false,
                gitgutter = false,
                harpoon = false,
                headlines = false,
                hop = false,
                illuminate = false,
                leap = false,
                lightspeed = false,
                lsp_saga = false,
                navic = false,
                neotest = false,
                neotree = false,
                nvim_surround = false,
                overseer = false,
                pounce = false,
                rainbow_delimiters = false,
                render_markdown = false,
                sandwich = false,
                semantic_tokens = false,
                symbols_outline = false,
                telekasten = false,
                ts_rainbow = false,
                ts_rainbow2 = false,
                ufo = false,
                vim_sneak = false,
                vimwiki = false,
            },
        })

        -- Apply the colorscheme
        vim.cmd([[colorscheme catppuccin]])
    end,
}
