-- Auto-insert `end` for Ruby/Lua/sh/etc. Standalone replacement for
-- nvim-treesitter-endwise, which was dropped because it requires the archived
-- nvim-treesitter plugin (we use tree-sitter-manager.nvim now).
return {
  "tpope/vim-endwise",
  event = "InsertEnter",
}
