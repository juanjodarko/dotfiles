-- init.lua — Main entry point for Neovim configuration
--
-- Load order:
--   1. Disable netrw (required before nvim-tree loads)
--   2. User settings & keymaps (leader key must be set before plugin keymaps)
--   3. Plugin manager (Lazy.nvim) and LSP/Mason config
--   4. Post-plugin setup (treesitter registration, vim-rest-console globals)
--
-- NOTE: vim-rest-console globals and treesitter registration could be moved
-- into their respective plugin specs for better cohesion.

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- User configurations
require("user.settings")
require("user.keymaps")
require("user.monorepo") -- Monorepo utilities

-- Plugin configurations
require("config.lazy")
require("config.lspconfig")
require("config.mason")

-- Treesitter configuration
vim.treesitter.language.register('markdown', 'octo')

-- vim-rest-console settings
vim.g.vrc_set_default_mapping = 0
vim.g.vrc_response_default_content_type = 'application/json'
vim.g.vrc_output_buffer_name = '_OUTPUT.json'
vim.g.vrc_auto_format_response_patterns = {
  json = 'jq',
}
