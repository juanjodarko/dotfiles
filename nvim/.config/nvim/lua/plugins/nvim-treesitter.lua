return {
    'nvim-treesitter/nvim-treesitter',
    build = ":TSUpdate",
    dependencies = {
        'nvim-treesitter/nvim-treesitter-textobjects',
        'JoosepAlviste/nvim-ts-context-commentstring',
        'RRethy/nvim-treesitter-endwise'
    },
    config = function()
        local configs = require('nvim-treesitter.configs')
        configs.setup({
            ensure_installed = {
                "c",
                "lua",
                "vim",
                "query",
                "ruby",
                "javascript",
                "typescript",
                "html",
                "css",
                "dockerfile",
                "markdown",
                "rust",
                "svelte"
            },
            sync_install = true,
            auto_install = true,
            highlight = { enable = true, disable = { 'NvimTree' } },
            indent = { enable = true },
        })
    end,
}
