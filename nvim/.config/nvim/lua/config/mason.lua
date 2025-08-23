require('mason').setup({
    ui = {
        icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗"
        }
    }
})

-- LSP servers for all target languages
local lsp_servers = {
    -- Lua (for Neovim config)
    'lua_ls',
    -- Ruby & Rails  
    'solargraph',      -- Ruby LSP
    'ruby_ls',         -- Alternative Ruby LSP
    'sorbet',          -- Shopify's Ruby type checker (optional)
    -- JavaScript/TypeScript/Node.js
    'tsserver',        -- TypeScript/JavaScript
    'eslint',          -- JavaScript/TypeScript linting
    'html',            -- HTML
    'cssls',           -- CSS
    'tailwindcss',     -- Tailwind CSS
    'emmet_ls',        -- Emmet for HTML/CSS
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
    -- Go
    'gofumpt',         -- Go formatter
    'golangci-lint',   -- Go linter
    -- C++
    'clang-format',    -- C++ formatter
    'cppcheck',        -- C++ static analysis
    -- General
    'shellcheck',      -- Shell script linter
    'yamllint',        -- YAML linter
    'markdownlint',    -- Markdown linter
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
    })
end
