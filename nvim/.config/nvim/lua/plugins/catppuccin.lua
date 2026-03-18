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
                -- Completion & LSP
                cmp = true,
                treesitter = true,
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

                -- UI
                telescope = {
                    enabled = true,
                    style = "nvchad",
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
                snacks = true,

                -- Git
                gitsigns = true,
                octo = true,
                diffview = true,

                -- Navigation
                flash = true,
                harpoon = true,

                -- Markdown & Notes
                markdown = true,
                render_markdown = true,

                -- AI
                avante = true,

                -- Debugging & Testing
                dap = true,
                dap_ui = true,
                neotest = true,

                -- Misc
                fzf = true,
                colorizer = true,
            },
        })

        -- Apply the colorscheme
        vim.cmd([[colorscheme catppuccin]])
    end,
}
