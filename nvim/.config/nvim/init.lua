vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- User configurations
require("user.settings")
require("user.keymaps")

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

-- Notification setup
require("notify").setup({
  background_colour = "#000000",
})

-- Key mappings
vim.api.nvim_set_keymap('n', '<leader>cc', ':Gen<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '<leader>ce', ':GenExplain<CR>', { noremap = true, silent = true })
