-- Parser management via tree-sitter-manager.nvim (classic nvim-treesitter is
-- archived). Requires the `tree-sitter` CLI and a C compiler on the system.
-- NOTE: this plugin provides :TSManager / :TSInstall / :TSUninstall (NOT :TSUpdate)
-- and does not expose `nvim-treesitter.configs`, so the old textobjects/endwise/
-- context-commentstring deps were removed (they require the archived plugin).
-- Replacements: vim-endwise (endwise), standalone ts-context-commentstring (set
-- via vim.g.skip_ts_context_commentstring_module in user/settings.lua).
return {
    'romus204/tree-sitter-manager.nvim',
    config = function()
        require('tree-sitter-manager').setup({
            ensure_installed = {
                "c", "lua", "vim", "vimdoc", "query",
                "ruby", "javascript", "typescript", "tsx",
                "html", "css", "dockerfile", "markdown", "markdown_inline",
                "rust", "svelte", "regex", "graphql",
                "python", "go", "elixir",
            },
            auto_install = true,
            highlight = true,
        })
    end,
}
