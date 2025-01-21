return {
    'hrsh7th/nvim-cmp',
    config = function()
        require('cmp').setup({
            sources = {
                { name = "codeium" },
                { name = "nvim_lsp" },
                { name = "path" },
            },
            symbol_map = {
                Codeium = "",
                Text = "",
                Method = "ƒ",
                Function = "",
                Constructor = "",
                Field = "",
                Variable = "",
                Class = "",
                Interface = "ﰮ",
                Module = "",
                Property = "",
                Unit = "",
                Value = "",
                Enum = "",
                Keyword = "",
                Snippet = "",
                Color = "",
                File = "",
                Reference = "",
                Folder = "",
                EnumMember = "",
                Constant = "",
                Struct = "",
            },
            formatting = {
                format = require('lspkind').cmp_format({
                    mode = "symbol",
                    maxwidth = 50,
                    ellipsis_char = '...',
                    symbol_map = { Codeium = "", }
                })
            }
        })
    end
}
