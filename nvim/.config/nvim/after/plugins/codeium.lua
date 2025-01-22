require('codeium').setup({
    enable_cmp_source = true,
    virtual_text = {
        enabled = true,
        manual = false,
    },
    workspace_root = {
        use_lsp = true,
        find_root = true,
        paths = {
            ".git",
            ".svn",
            ".hg",
            "Makefile",
            "package.json",
            "Cargo.toml",
        },
        disable = {
            "/node_modules",
            "/vendor",
        }
    }
})
