require('mason').setup({
    ui = {
        icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗"
        }
    }
})

-- LSP servers for all target languages (only include stable ones)
local lsp_servers = {
    -- Lua (for Neovim config)
    'lua_ls',
    -- Ruby & Rails
    'solargraph',      -- Ruby LSP
    -- Note: ruby_ls and sorbet might not be available in Mason, removing for stability
    -- JavaScript/TypeScript/Node.js
    'ts_ls',           -- TypeScript/JavaScript (formerly tsserver)
    'eslint',          -- JavaScript/TypeScript linting
    'html',            -- HTML
    'cssls',           -- CSS
    'tailwindcss',     -- Tailwind CSS
    'emmet_ls',        -- Emmet for HTML/CSS
    -- GraphQL
    'graphql',         -- GraphQL LSP
    -- Python
    'pyright',         -- Python LSP
    -- Rust
    'rust_analyzer',   -- Rust LSP
    -- Go
    'gopls',           -- Official Go LSP
    -- Elixir
    'elixirls',        -- Elixir LSP
    -- C++
    'clangd',          -- C/C++ LSP
    -- Additional useful servers
    'jsonls',          -- JSON
    'yamlls',          -- YAML
    'bashls',          -- Bash
    'dockerls',        -- Docker
    'marksman',        -- Markdown
}

-- Additional tools (formatters, linters, etc.)
local tools = {
    -- Ruby
    'standardrb',      -- Ruby formatter/linter
    'rubocop',         -- Ruby linter
    -- JavaScript/TypeScript
    'prettier',        -- Code formatter
    'eslint_d',        -- Fast ESLint daemon
    -- Python
    'black',           -- Python formatter
    'isort',           -- Python import sorter
    'ruff',            -- Python linter
    -- Rust tools - rustfmt comes with rust toolchain
    -- Go tools
    'gofumpt',         -- Go formatter
    'goimports',       -- Go import organizer
    -- C++
    'clang-format',    -- C++ formatter
    -- General
    'shellcheck',      -- Shell script linter
    'yamllint',        -- YAML linter
    'markdownlint',    -- Markdown linter
    -- DAP adapters
    'js-debug-adapter',  -- JavaScript/TypeScript DAP
    'debugpy',           -- Python DAP
}

require('mason-lspconfig').setup({
    ensure_installed = lsp_servers,
    automatic_installation = true,
})

-- Also install additional tools via mason-tool-installer if available
local has_mason_tool_installer, mason_tool_installer = pcall(require, 'mason-tool-installer')
if has_mason_tool_installer then
    mason_tool_installer.setup({
        ensure_installed = tools,
        auto_update = false,
        run_on_start = true,
        -- Add error handling for missing packages
        integrations = {
            ['mason-lspconfig'] = true,
            ['mason-null-ls'] = false,
            ['mason-nvim-dap'] = false,
        },
    })
end
