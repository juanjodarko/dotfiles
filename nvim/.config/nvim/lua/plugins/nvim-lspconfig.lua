  return {
        "neovim/nvim-lspconfig", -- Configuración de LSP
        dependencies = {
            "hrsh7th/nvim-cmp",          -- Autocompletado
            "hrsh7th/cmp-nvim-lsp",      -- Fuente LSP para autocompletado
            "hrsh7th/cmp-path",          -- Autocompletado de rutas
            "hrsh7th/cmp-buffer",        -- Autocompletado de buffers
            "saadparwaiz1/cmp_luasnip",  -- Integración de snippets con cmp
            "onsails/lspkind-nvim",      -- Íconos en el menú de autocompletado
            "L3MON4D3/LuaSnip",          -- Snippets
        },
    }
