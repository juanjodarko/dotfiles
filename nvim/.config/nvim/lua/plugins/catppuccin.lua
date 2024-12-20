return {
    'catppuccin/nvim',
    name = 'catppuccin',
    priority = 1,
    config = function()
        require("catppuccin").setup({
            flavour = "mocha",
            background = {
                light = "latte",
                dark = "mocha",
            },
            transparent_background = true,
            show_end_of_buffer = false,
            term_colors = false,
            dim_inactive = {
                enabled = false,
                shade = "dark",
                percentage = 0.15,
            },
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
            integrations = {
                cmp = true,
                gitsigns = true,
                nvimtree = true,
                notify = false,
                mini = false,
                bufferline = true,
                mason = true,
                octo = true,
                lsp_trouble = true,
                telescope = {
                    enabled = true,
                    style = 'nvchad'
                }
            },
        })
        vim.cmd([[colorscheme catppuccin]])
    end,
}
