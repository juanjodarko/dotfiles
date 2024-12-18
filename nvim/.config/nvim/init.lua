local hostname = vim.loop.os_gethostname()
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
require("user.settings")
require('user.keymaps')
require("config.lazy")

require("config.lspconfig")
require("config.mason")
--require('lazy').setup({
--  { 'diepm/vim-rest-console' },
--  -- { 'juanjodarko/nvim-gtd-planner' }
--})
--
--require('plugins.pomodoro')
--
--
--local lsp = require('lsp-zero').preset({})
--
--lsp.on_attach(function(client, bufnr)
--  -- see :help lsp-zero-keybindings
--  -- to learn the available actions
--  lsp.default_keymaps({ buffer = bufnr })
--end)
--
--lsp.ensure_installed({
--  'angularls',
--  'bashls',
--  'clangd',
--  'cmake',
--  'cssls',
--  'dockerls',
--  'eslint',
--  'grammarly',
--  'html',
--  'jsonls',
--  'tsserver',
--  'ltex',
--  'lua_ls',
--  'marksman',
--  'puppet',
--  'jedi_language_server',
--  'solargraph',
--  'rust_analyzer',
--  'sqlls',
--  'svelte',
--  'tailwindcss',
--  'terraformls',
--  'vuels',
--})
--
--lsp.format_on_save({
--  format_opts = {
--    async = false,
--    timeout_ms = 10000,
--  },
--  servers = {
--    ['lua_ls'] = { 'lua' },
--    ['rust_analyzer'] = { 'rust' },
--    ['prettierd'] = { 'svelte' },
--    ['eslint'] = { 'typescript', 'javascript', 'svelte' }
--    -- if you have a working setup with null-ls
--    -- you can specify filetypes it can format.
--    -- ['null-ls'] = {'javascript', 'typescript'},
--  }
--})
--
--lsp.on_attach(function(client, bufnr)
--  lsp.default_keymaps({ buffer = bufnr })
--  local opts = { buffer = bufnr }
--
--  vim.keymap.set({ 'n', 'x' }, 'gq', function()
--    vim.lsp.buf.format({ async = false, timeout_ms = 10000 })
--  end, opts)
--end)
--
--lsp.setup()
--require 'colorizer'.setup()
--
--require "octo".setup({
--})
