return {
    'lukas-reineke/indent-blankline.nvim',
    config = function()
        require('ibl').setup({
            exclude = {
                filetypes = {
                    'help',
                    'terminal',
                    'dashboard',
                    'lazy',
                    'lspinfo',
                    'TelescopePrompt',
                    'TelescopeResults',
                },
                buftypes = {
                    'terminal',
                    'NvimTree',
                }
            },
            scope = {
                enabled = true,
                show_start = true,
            },
            indent = {
                char = '|',
                smart_indent_cap = true,
                priority = 2
            },
        })
        vim.opt.list = true
    end,
}
