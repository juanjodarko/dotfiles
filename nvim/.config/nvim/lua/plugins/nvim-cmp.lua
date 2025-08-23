return {
    'hrsh7th/nvim-cmp',
    dependencies = {
        'hrsh7th/cmp-nvim-lsp',
        'hrsh7th/cmp-path',
        'hrsh7th/cmp-buffer',
        'onsails/lspkind-nvim',
    },
    config = function()
        local cmp = require('cmp')
        
        cmp.setup({
            sources = {
                { name = "codeium" },
                { name = "nvim_lsp" },
                { name = "path" },
                { name = "buffer" },
            },
            snippet = {
                expand = function(args)
                    -- You need Neovim v0.10 to use vim.snippet
                    vim.snippet.expand(args.body)
                end,
            },
            mapping = cmp.mapping.preset.insert({}),
            formatting = {
                format = require('lspkind').cmp_format({
                    mode = "symbol",
                    maxwidth = 50,
                    ellipsis_char = '...',
                    symbol_map = { 
                        Codeium = "",
                        Text = "",
                        Method = "ƒ",
                        Function = "",
                        Constructor = "",
                        Field = "",
                        Variable = "",
                        Class = "",
                        Interface = "ﰮ",
                        Module = "",
                        Property = "",
                        Unit = "",
                        Value = "",
                        Enum = "",
                        Keyword = "",
                        Snippet = "",
                        Color = "",
                        File = "",
                        Reference = "",
                        Folder = "",
                        EnumMember = "",
                        Constant = "",
                        Struct = "",
                    }
                })
            }
        })
    end
}